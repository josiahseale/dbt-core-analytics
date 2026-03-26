with carrier_dx_long as (
    select desynpuf_id, claim_from_date as event_date, dx.dx_code
    from {{ ref('int_synpuf__car_sample_01') }} c
    cross join lateral (
        select stack(21,
            icd9_diagnosis_code_1,
            icd9_diagnosis_code_2,
            icd9_diagnosis_code_3,
            icd9_diagnosis_code_4,
            icd9_diagnosis_code_5,
            icd9_diagnosis_code_6,
            icd9_diagnosis_code_7,
            icd9_diagnosis_code_8,
            line_icd9_diagnosis_code_1,
            line_icd9_diagnosis_code_2,
            line_icd9_diagnosis_code_3,
            line_icd9_diagnosis_code_4,
            line_icd9_diagnosis_code_5,
            line_icd9_diagnosis_code_6,
            line_icd9_diagnosis_code_7,
            line_icd9_diagnosis_code_8,
            line_icd9_diagnosis_code_9,
            line_icd9_diagnosis_code_10,
            line_icd9_diagnosis_code_11,
            line_icd9_diagnosis_code_12,
            line_icd9_diagnosis_code_13
        ) as dx_code
    ) dx
    where dx.dx_code is not null and trim(dx.dx_code) <> ''
),

op_dx_long as (
    select desynpuf_id, claim_from_date as event_date, dx.dx_code
    from {{ ref('int_synpuf__op_sample_01') }} o
    cross join lateral (
        select stack(11,
            admitting_icd9_diagnosis_code,
            icd9_diagnosis_code_1,
            icd9_diagnosis_code_2,
            icd9_diagnosis_code_3,
            icd9_diagnosis_code_4,
            icd9_diagnosis_code_5,
            icd9_diagnosis_code_6,
            icd9_diagnosis_code_7,
            icd9_diagnosis_code_8,
            icd9_diagnosis_code_9,
            icd9_diagnosis_code_10
        ) as dx_code
    ) dx
    where dx.dx_code is not null and trim(dx.dx_code) <> ''
),

all_dx as (
    select dx_code from carrier_dx_long
    union all
    select dx_code from op_dx_long
)

select
    dx_code,
    count(*) as occurrences
from all_dx
group by 1
order by occurrences desc, dx_code
limit 100