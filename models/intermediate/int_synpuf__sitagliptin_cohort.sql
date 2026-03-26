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
        b.bene_birth_dt,
        b.bene_death_dt,
        b.bene_sex_ident_cd,
        b.bene_race_cd,
        b.sp_state_code,
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
            order by
                case when b.claim_year <= year(ff.index_date) then 0 else 1 end,
                abs(b.claim_year - year(ff.index_date))
        ) as rn
    from first_fill ff
    left join {{ ref('stg_synpuf__bene_2008_sample_01') }} b
      on ff.desynpuf_id = b.desynpuf_id

    union all

    select
        ff.desynpuf_id,
        b.claim_year,
        b.bene_birth_dt,
        b.bene_death_dt,
        b.bene_sex_ident_cd,
        b.bene_race_cd,
        b.sp_state_code,
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
            order by
                case when b.claim_year <= year(ff.index_date) then 0 else 1 end,
                abs(b.claim_year - year(ff.index_date))
        ) as rn
    from first_fill ff
    left join {{ ref('stg_synpuf__bene_2009_sample_01') }} b
      on ff.desynpuf_id = b.desynpuf_id

    union all

    select
        ff.desynpuf_id,
        b.claim_year,
        b.bene_birth_dt,
        b.bene_death_dt,
        b.bene_sex_ident_cd,
        b.bene_race_cd,
        b.sp_state_code,
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
            order by
                case when b.claim_year <= year(ff.index_date) then 0 else 1 end,
                abs(b.claim_year - year(ff.index_date))
        ) as rn
    from first_fill ff
    left join {{ ref('stg_synpuf__bene_2010_sample_01') }} b
      on ff.desynpuf_id = b.desynpuf_id
),

bene_best as (
    select *
    from (
        select
            desynpuf_id,
            claim_year,
            bene_birth_dt,
            bene_death_dt,
            bene_sex_ident_cd,
            bene_race_cd,
            sp_state_code,
            bene_esrd_ind,
            sp_alzhdmta,
            sp_chf,
            sp_chrnkidn,
            sp_cncr,
            sp_copd,
            sp_depressn,
            sp_diabetes,
            sp_ischmcht,
            sp_osteoprs,
            sp_ra_oa,
            sp_strketia,
            row_number() over (
                partition by desynpuf_id
                order by rn
            ) as final_rn
        from bene_at_index
    ) x
    where final_rn = 1
)

select
    ff.desynpuf_id,
    ff.index_date,
    date_add(ff.index_date, -365) as baseline_start_date,
    date_add(ff.index_date, -1) as baseline_end_date,
    ff.index_date as followup_start_date,
    date_add(ff.index_date, 365) as followup_end_date,

    case
        when bb.bene_birth_dt is not null then datediff(ff.index_date, bb.bene_birth_dt) / 365.25
        else null
    end as age_at_index,

    case
        when bb.bene_sex_ident_cd = '1' then 'M'
        when bb.bene_sex_ident_cd = '2' then 'F'
        else 'U'
    end as sex,

    bb.claim_year as beneficiary_reference_year,
    bb.bene_birth_dt as beneficiary_birth_date,
    bb.bene_death_dt as beneficiary_death_date,
    bb.bene_race_cd as beneficiary_race_code,
    bb.sp_state_code as beneficiary_state_code,
    bb.bene_esrd_ind as beneficiary_esrd_indicator,

    bb.sp_alzhdmta as chronic_condition_alzheimers_or_dementia_flag,
    bb.sp_chf as chronic_condition_congestive_heart_failure_flag,
    bb.sp_chrnkidn as chronic_condition_chronic_kidney_disease_flag,
    bb.sp_cncr as chronic_condition_cancer_flag,
    bb.sp_copd as chronic_condition_copd_flag,
    bb.sp_depressn as chronic_condition_depression_flag,
    bb.sp_diabetes as chronic_condition_diabetes_flag,
    bb.sp_ischmcht as chronic_condition_ischemic_heart_disease_flag,
    bb.sp_osteoprs as chronic_condition_osteoporosis_flag,
    bb.sp_ra_oa as chronic_condition_rheumatoid_arthritis_or_osteoarthritis_flag,
    bb.sp_strketia as chronic_condition_stroke_or_tia_flag,

    idx.pde_id as index_prescription_drug_event_id,
    idx.prod_srvc_id as index_product_service_id,
    idx.quantity_dispensed_num as index_quantity_dispensed,
    idx.days_supply_num as index_days_supply,

    1 as new_user_flag,

    case
        when bb.bene_birth_dt is not null
         and datediff(ff.index_date, bb.bene_birth_dt) / 365.25 >= 18 then 1
        else 0
    end as age_18_plus_flag

from first_fill ff
left join bene_best bb
  on ff.desynpuf_id = bb.desynpuf_id
left join index_fill idx
  on ff.desynpuf_id = idx.desynpuf_id
 and idx.rn = 1