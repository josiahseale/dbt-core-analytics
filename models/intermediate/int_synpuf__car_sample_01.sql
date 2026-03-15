select * from {{ ref('stg_synpuf__car_sample_01a') }}
union all
select * from {{ ref('stg_synpuf__car_sample_01b') }}
