{{ config(materialized='view') }}

with cohort as (
    select *
    from {{ ref('int_synpuf__sitagliptin_cohort') }}
),

baseline_rx as (
    select
        c.desynpuf_id,
        c.index_date,
        f.fill_date as event_date,
        datediff(day, c.index_date, f.fill_date) as days_from_index,
        'drug_exposure' as event_type,
        case
            when f.fill_date = c.index_date then 'drug_sitagliptin_index'
            else 'drug_sitagliptin_baseline'
        end as event_token,
        'PDE' as source_family,
        f.pde_id as source_record_id,
        case when f.fill_date = c.index_date then 1 else 0 end as is_index_event,
        1.0 as event_weight
    from cohort c
    inner join {{ ref('int_synpuf__rx_sitagliptin_fills') }} f
      on c.desynpuf_id = f.desynpuf_id
     and f.fill_date between c.baseline_start_date and c.index_date
),

carrier_util as (
    select
        c.desynpuf_id,
        c.index_date,
        car.claim_from_date as event_date,
        datediff(day, c.index_date, car.claim_from_date) as days_from_index,
        'utilization' as event_type,
        'util_carrier_claim' as event_token,
        'CAR' as source_family,
        car.claim_id as source_record_id,
        0 as is_index_event,
        1.0 as event_weight
    from cohort c
    inner join {{ ref('int_synpuf__car_sample_01') }} car
      on c.desynpuf_id = car.desynpuf_id
     and car.claim_from_date between c.baseline_start_date and c.index_date
),

outpatient_util as (
    select
        c.desynpuf_id,
        c.index_date,
        op.claim_from_date as event_date,
        datediff(day, c.index_date, op.claim_from_date) as days_from_index,
        'utilization' as event_type,
        'util_outpatient_claim' as event_token,
        'OP' as source_family,
        op.claim_id as source_record_id,
        0 as is_index_event,
        1.0 as event_weight
    from cohort c
    inner join {{ ref('int_synpuf__op_sample_01') }} op
      on c.desynpuf_id = op.desynpuf_id
     and op.claim_from_date between c.baseline_start_date and c.index_date
),

carrier_dx_long as (
    select
        c.desynpuf_id,
        c.index_date,
        car.claim_from_date as event_date,
        datediff(day, c.index_date, car.claim_from_date) as days_from_index,
        'diagnosis' as event_type,
        dx.diagnosis_code,
        'CAR' as source_family,
        car.claim_id as source_record_id
    from cohort c
    inner join {{ ref('int_synpuf__car_sample_01') }} car
      on c.desynpuf_id = car.desynpuf_id
     and car.claim_from_date between c.baseline_start_date and c.index_date
    cross join lateral (
        select car.icd9_diagnosis_code_1  as diagnosis_code where car.icd9_diagnosis_code_1  is not null
        union all select car.icd9_diagnosis_code_2  where car.icd9_diagnosis_code_2  is not null
        union all select car.icd9_diagnosis_code_3  where car.icd9_diagnosis_code_3  is not null
        union all select car.icd9_diagnosis_code_4  where car.icd9_diagnosis_code_4  is not null
        union all select car.icd9_diagnosis_code_5  where car.icd9_diagnosis_code_5  is not null
        union all select car.icd9_diagnosis_code_6  where car.icd9_diagnosis_code_6  is not null
        union all select car.icd9_diagnosis_code_7  where car.icd9_diagnosis_code_7  is not null
        union all select car.icd9_diagnosis_code_8  where car.icd9_diagnosis_code_8  is not null
        union all select car.line_icd9_diagnosis_code_1  where car.line_icd9_diagnosis_code_1  is not null
        union all select car.line_icd9_diagnosis_code_2  where car.line_icd9_diagnosis_code_2  is not null
        union all select car.line_icd9_diagnosis_code_3  where car.line_icd9_diagnosis_code_3  is not null
        union all select car.line_icd9_diagnosis_code_4  where car.line_icd9_diagnosis_code_4  is not null
        union all select car.line_icd9_diagnosis_code_5  where car.line_icd9_diagnosis_code_5  is not null
        union all select car.line_icd9_diagnosis_code_6  where car.line_icd9_diagnosis_code_6  is not null
        union all select car.line_icd9_diagnosis_code_7  where car.line_icd9_diagnosis_code_7  is not null
        union all select car.line_icd9_diagnosis_code_8  where car.line_icd9_diagnosis_code_8  is not null
        union all select car.line_icd9_diagnosis_code_9  where car.line_icd9_diagnosis_code_9  is not null
        union all select car.line_icd9_diagnosis_code_10 where car.line_icd9_diagnosis_code_10 is not null
        union all select car.line_icd9_diagnosis_code_11 where car.line_icd9_diagnosis_code_11 is not null
        union all select car.line_icd9_diagnosis_code_12 where car.line_icd9_diagnosis_code_12 is not null
        union all select car.line_icd9_diagnosis_code_13 where car.line_icd9_diagnosis_code_13 is not null
    ) dx
),

op_dx_long as (
    select
        c.desynpuf_id,
        c.index_date,
        op.claim_from_date as event_date,
        datediff(day, c.index_date, op.claim_from_date) as days_from_index,
        'diagnosis' as event_type,
        dx.diagnosis_code,
        'OP' as source_family,
        op.claim_id as source_record_id
    from cohort c
    inner join {{ ref('int_synpuf__op_sample_01') }} op
      on c.desynpuf_id = op.desynpuf_id
     and op.claim_from_date between c.baseline_start_date and c.index_date
    cross join lateral (
        select op.admitting_icd9_diagnosis_code as diagnosis_code where op.admitting_icd9_diagnosis_code is not null
        union all select op.icd9_diagnosis_code_1  where op.icd9_diagnosis_code_1  is not null
        union all select op.icd9_diagnosis_code_2  where op.icd9_diagnosis_code_2  is not null
        union all select op.icd9_diagnosis_code_3  where op.icd9_diagnosis_code_3  is not null
        union all select op.icd9_diagnosis_code_4  where op.icd9_diagnosis_code_4  is not null
        union all select op.icd9_diagnosis_code_5  where op.icd9_diagnosis_code_5  is not null
        union all select op.icd9_diagnosis_code_6  where op.icd9_diagnosis_code_6  is not null
        union all select op.icd9_diagnosis_code_7  where op.icd9_diagnosis_code_7  is not null
        union all select op.icd9_diagnosis_code_8  where op.icd9_diagnosis_code_8  is not null
        union all select op.icd9_diagnosis_code_9  where op.icd9_diagnosis_code_9  is not null
        union all select op.icd9_diagnosis_code_10 where op.icd9_diagnosis_code_10 is not null
    ) dx
),

dx_grouped as (
    select
        desynpuf_id,
        index_date,
        event_date,
        days_from_index,
        event_type,
        case
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '250%' then 'dx_diabetes'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '401%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '402%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '403%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '404%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '405%'
                then 'dx_hypertension'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '272%' then 'dx_hyperlipidemia'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '585%' then 'dx_ckd'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '428%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '410%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '411%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '412%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '413%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '414%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '430%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '431%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '432%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '433%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '434%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '435%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '436%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '437%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '438%'
                then 'dx_cardiovascular'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '2780%' then 'dx_obesity'
            
            when regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '2962%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '2963%'
              or regexp_replace(diagnosis_code, '[^0-9VvEe]', '') like '311%'
                then 'dx_depression'
            
            else null
        end as event_token,
        source_family,
        source_record_id,
        0 as is_index_event,
        1.0 as event_weight
    from (
        select * from carrier_dx_long
        union all
        select * from op_dx_long
    ) dx
),

demographic_events as (
    select
        c.desynpuf_id,
        c.index_date,
        c.index_date as event_date,
        0 as days_from_index,
        'demographic' as event_type,
        demo.event_token,
        'BENE' as source_family,
        null as source_record_id,
        0 as is_index_event,
        1.0 as event_weight
    from cohort c
    cross join lateral (
        select
            case
                when c.sex = 'F' then 'demo_female'
                when c.sex = 'M' then 'demo_male'
                else 'demo_sex_unknown'
            end as event_token
        union all
        select
            case
                when c.age_at_index between 18 and 54 then 'demo_age_18_54'
                when c.age_at_index between 55 and 64 then 'demo_age_55_64'
                when c.age_at_index between 65 and 69 then 'demo_age_65_69'
                when c.age_at_index between 70 and 74 then 'demo_age_70_74'
                when c.age_at_index between 75 and 79 then 'demo_age_75_79'
                when c.age_at_index >= 80 then 'demo_age_80_plus'
                else 'demo_age_unknown'
            end
        union all select 'comorb_chf'                   where c.chronic_condition_congestive_heart_failure_flag = 1
        union all select 'comorb_ckd'                   where c.chronic_condition_chronic_kidney_disease_flag = 1
        union all select 'comorb_copd'                  where c.chronic_condition_copd_flag = 1
        union all select 'comorb_depression'            where c.chronic_condition_depression_flag = 1
        union all select 'comorb_ischemic_heart_disease' where c.chronic_condition_ischemic_heart_disease_flag = 1
        union all select 'comorb_stroke_tia'            where c.chronic_condition_stroke_or_tia_flag = 1
    ) demo
),

combined as (
    select * from baseline_rx
    union all
    select * from carrier_util
    union all
    select * from outpatient_util
    union all
    select * from dx_grouped where event_token is not null
    union all
    select * from demographic_events
)

select
    desynpuf_id,
    index_date,
    event_date,
    days_from_index,
    event_type,
    event_token,
    source_family,
    source_record_id,
    is_index_event,
    event_weight
from combined
qualify row_number() over (
    partition by desynpuf_id, event_date, event_type, event_token, source_family, coalesce(source_record_id, '__null__')
    order by event_date
) = 1