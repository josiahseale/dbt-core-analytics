{{ config(materialized='view') }}

with first_fill as (
    select
        desynpuf_id,
        min(fill_date) as index_date
    from {{ ref('int_synpuf__rx_sitagliptin_fills') }}
    group by 1
),

index_fill as (
    select
        f.*,
        row_number() over (
            partition by f.desynpuf_id
            order by f.fill_date, f.pde_id
        ) as rn
    from {{ ref('int_synpuf__rx_sitagliptin_fills') }} f
),

bene_at_index as (
    select
        ff.desynpuf_id,
        b.claim_year,
        b.bene_birth_date,
        b.bene_death_date,
        b.bene_sex_ident_cd,
        b.bene_race_cd,
        b.state_code,
        b.bene_esrd_ind,
        b.sp_alzhdmta,
        b.sp_chf,
        b.sp_chrnkidn,
        b.sp_cncr,
        b.sp_copd,
        b.sp_depressn,
        b.sp_diabetes,
        b.sp_ischmcht,
        b.sp_osteoprs,
        b.sp_ra_oa,
        b.sp_strketia,
        row_number() over (
            partition by ff.desynpuf_id
            order by case when b.claim_year <= year(ff.index_date) then 0 else 1 end,
                     abs(b.claim_year - year(ff.index_date))
        ) as rn
    from first_fill ff
    left join {{ ref('int_synpuf__bene_sample_01') }} b
      on ff.desynpuf_id = b.desynpuf_id
)

select
    ff.desynpuf_id,
    ff.index_date,
    dateadd(day, -365, ff.index_date) as baseline_start_date,
    dateadd(day, -1, ff.index_date) as baseline_end_date,
    ff.index_date as followup_start_date,
    dateadd(day, 365, ff.index_date) as followup_end_date,
    iff(bi.bene_birth_date is not null, datediff(year, bi.bene_birth_date, ff.index_date), null) as age_at_index,
    case
        when bi.bene_sex_ident_cd = '1' then 'M'
        when bi.bene_sex_ident_cd = '2' then 'F'
        else 'U'
    end as sex,
    bi.bene_birth_date,
    bi.bene_death_date,
    bi.bene_race_cd,
    bi.state_code,
    bi.bene_esrd_ind,
    bi.sp_alzhdmta,
    bi.sp_chf,
    bi.sp_chrnkidn,
    bi.sp_cncr,
    bi.sp_copd,
    bi.sp_depressn,
    bi.sp_diabetes,
    bi.sp_ischmcht,
    bi.sp_osteoprs,
    bi.sp_ra_oa,
    bi.sp_strketia,
    idx.pde_id as index_pde_id,
    idx.product_service_id as index_product_service_id,
    idx.quantity_dispensed_num as index_quantity_dispensed_num,
    idx.days_supply_num as index_days_supply_num,
    1 as new_user_flag,
    iff(bi.bene_birth_date is not null and datediff(year, bi.bene_birth_date, ff.index_date) >= 18, 1, 0) as age_18_plus_flag
from first_fill ff
left join bene_at_index bi
  on ff.desynpuf_id = bi.desynpuf_id
 and bi.rn = 1
left join index_fill idx
  on ff.desynpuf_id = idx.desynpuf_id
 and idx.rn = 1
