{{ config(materialized='view') }}

with pde as (
    select
        desynpuf_id,
        pde_id,
        srvc_dt,
        prod_srvc_id,
        regexp_replace(coalesce(prod_srvc_id, ''), '[^0-9]', '') as product_service_id_digits,
        qty_dspnsd_num,
        days_suply_num,
        ptnt_pay_amt,
        tot_rx_cst_amt,
        sample_id,
        source_table_name
    from {{ ref('stg_synpuf__pde_sample_01') }}
    where srvc_dt is not null
),

code_map as (
    select
        cast(product_code_digits as {{ type_string() }}) as product_code_digits,
        concept_name,
        concept_token
    from {{ ref('sitagliptin_product_code_prefixes') }}
),

matched as (
    select
        pde.desynpuf_id,
        pde.pde_id,
        pde.srvc_dt as fill_date,
        pde.prod_srvc_id,
        pde.product_service_id_digits,
        pde.qty_dspnsd_num as quantity_dispensed_num,
        pde.days_suply_num as days_supply_num,
        pde.ptnt_pay_amt as patient_pay_amount,
        pde.tot_rx_cst_amt as total_rx_cost_amount,
        code_map.concept_name,
        code_map.concept_token,
        pde.sample_id,
        pde.source_table_name
    from pde
    inner join code_map
        on left(pde.product_service_id_digits, 7) = left(code_map.product_code_digits, 7)
    where coalesce(pde.days_suply_num, 0) > 0
      and coalesce(pde.qty_dspnsd_num, 0) > 0
)

select *
from matched