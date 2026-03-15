select
    DESYNPUF_ID as desynpuf_id,
    PDE_ID as pde_id,
    cast(SRVC_DT as date) as srvc_date,
    PROD_SRVC_ID as product_service_id,
    QTY_DSPNSD_NUM as quantity_dispensed_num,
    DAYS_SUPLY_NUM as days_supply_num,
    PTNT_PAY_AMT as patient_pay_amount,
    TOT_RX_CST_AMT as total_rx_cost_amount,
    1 as sample_id,
    'DE1_0_2008_TO_2010_PRESCRIPTION_DRUG_EVENTS_SAMPLE_1' as source_table_name
from {{ source('synpuf_prestaging', 'DE1_0_2008_TO_2010_PRESCRIPTION_DRUG_EVENTS_SAMPLE_1') }}
