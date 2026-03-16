select * from {{ ref('stg_synpuf__bene_2008_sample_01') }}
union all
select * from {{ ref('stg_synpuf__bene_2009_sample_01') }}
union all
select * from {{ ref('stg_synpuf__bene_2010_sample_01') }}
