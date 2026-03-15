select
    DESYNPUF_ID as desynpuf_id,
    CLM_ID as claim_id,
    try_to_date(CLM_FROM_DT::varchar, 'YYYYMMDD') as claim_from_date,
    try_to_date(CLM_THRU_DT::varchar, 'YYYYMMDD') as claim_thru_date

    {% for i in range(1, 9) %}
    , ICD9_DGNS_CD_{{ i }} as icd9_diagnosis_code_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , PRF_PHYSN_NPI_{{ i }} as provider_physician_npi_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , TAX_NUM_{{ i }} as tax_num_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , HCPCS_CD_{{ i }} as hcpcs_cd_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_NCH_PMT_AMT_{{ i }} as line_nch_payment_amount_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_BENE_PTB_DDCTBL_AMT_{{ i }} as line_beneficiary_part_b_deductible_amount_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_BENE_PRMRY_PYR_PD_AMT_{{ i }} as line_beneficiary_primary_payer_paid_amount_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_COINSRNC_AMT_{{ i }} as line_coinsurance_amount_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_ALOWD_CHRG_AMT_{{ i }} as line_allowed_charge_amount_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_PRCSG_IND_CD_{{ i }} as line_processing_indicator_code_{{ i }}
    {% endfor %}

    {% for i in range(1, 14) %}
    , LINE_ICD9_DGNS_CD_{{ i }} as line_icd9_diagnosis_code_{{ i }}
    {% endfor %}

    , 1 as sample_id
    , 'B' as carrier_file_part
    , 'DE1_0_2008_TO_2010_CARRIER_CLAIMS_SAMPLE_1B' as source_table_name
from {{ source('synpuf_prestaging', 'DE1_0_2008_TO_2010_CARRIER_CLAIMS_SAMPLE_1B') }}