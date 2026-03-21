{{ config(materialized='view') }}

with pde as (
    select
        desynpuf_id,
        pde_id,
        srvc_date,
        product_service_id,
        regexp_replace(coalesce(product_service_id, ''), '[^0-9]', '') as product_service_id_digits,
        quantity_dispensed_num,
        days_supply_num,
        patient_pay_amount,
        total_rx_cost_amount,
        sample_id,
        source_table_name
    from {{ ref('stg_synpuf__pde_sample_01') }}
    where srvc_date is not null
),

code_map as (
    select
        cast(product_code_digits as varchar) as product_code_digits,
        concept_name,
        concept_token
    from {{ ref('sitagliptin_product_code_prefixes') }}
),

matched as (
    select
        pde.desynpuf_id,
        pde.pde_id,
        pde.srvc_date as fill_date,
        pde.product_service_id,
        pde.product_service_id_digits,
        pde.quantity_dispensed_num,
        pde.days_supply_num,
        pde.patient_pay_amount,
        pde.total_rx_cost_amount,
        code_map.concept_name,
        code_map.concept_token,
        pde.sample_id,
        pde.source_table_name
    from pde
    inner join code_map
        on left(pde.product_service_id_digits, 7) = left(code_map.product_code_digits, 7)
    where coalesce(pde.days_supply_num, 0) > 0
      and coalesce(pde.quantity_dispensed_num, 0) > 0
)

select *
from matched
