{{ config(materialized='table') }}

with ordered_events as (
    select
        e.desynpuf_id,
        e.index_date,
        e.event_date,
        e.event_type,
        e.event_token,
        e.source_family,
        e.is_index_event,
        row_number() over (
            partition by e.desynpuf_id
            order by e.event_date, e.is_index_event desc, e.event_type, e.event_token
        ) as token_ordinal
    from {{ ref('int_topic__patient_events') }} e
),

aggregated as (
    select
        desynpuf_id,
        min(index_date) as index_date,
        count(*) as token_count,
        sum(case when event_type = 'diagnosis' then 1 else 0 end) as diagnosis_token_count,
        sum(case when event_type = 'drug_exposure' then 1 else 0 end) as drug_token_count,
        sum(case when event_type = 'utilization' then 1 else 0 end) as utilization_token_count,
        sum(case when event_type = 'demographic' then 1 else 0 end) as demographic_token_count,
        listagg(event_token, ' ') within group (order by token_ordinal) as document_text,
        listagg(
            concat(cast(event_date as string), '|', event_type, '|', event_token),
            ' '
        ) within group (order by token_ordinal) as document_trace
    from ordered_events
    group by desynpuf_id
)

select
    cast(c.desynpuf_id as string) as desynpuf_id,
    c.index_date,
    c.baseline_start_date,
    c.baseline_end_date,
    c.followup_start_date,
    c.followup_end_date,
    c.age_at_index,
    c.sex,
    c.beneficiary_death_date,
    coalesce(a.token_count, 0) as token_count,
    coalesce(a.diagnosis_token_count, 0) as diagnosis_token_count,
    coalesce(a.drug_token_count, 0) as drug_token_count,
    coalesce(a.utilization_token_count, 0) as utilization_token_count,
    coalesce(a.demographic_token_count, 0) as demographic_token_count,
    coalesce(a.document_text, '') as document_text,
    coalesce(a.document_trace, '') as document_trace
from {{ ref('int_synpuf__sitagliptin_cohort') }} c
left join aggregated a
  on cast(c.desynpuf_id as string) = cast(a.desynpuf_id as string)