{{ config(materialized='view') }}

select
    cast(DESYNPUF_ID as {{ type_string() }}) as desynpuf_id,
    cast(PDE_ID as {{ type_string() }}) as pde_id,
    {{ type_date('SRVC_DT') }} as srvc_dt,
    cast(PROD_SRVC_ID as {{ type_string() }}) as prod_srvc_id,
    cast(QTY_DSPNSD_NUM as {{ type_decimal(38, 3) }}) as qty_dspnsd_num,
    cast(DAYS_SUPLY_NUM as integer) as days_suply_num,
    cast(PTNT_PAY_AMT as {{ type_decimal(38, 2) }}) as ptnt_pay_amt,
    cast(TOT_RX_CST_AMT as {{ type_decimal(38, 2) }}) as tot_rx_cst_amt,
    1 as sample_id,
    'DE1_0_2008_TO_2010_PRESCRIPTION_DRUG_EVENTS_SAMPLE_1' as source_table_name
from {{ source('synpuf_prestaging', 'DE1_0_2008_TO_2010_PRESCRIPTION_DRUG_EVENTS_SAMPLE_1') }}
