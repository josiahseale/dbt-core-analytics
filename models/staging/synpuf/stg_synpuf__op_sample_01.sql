select
    DESYNPUF_ID as desynpuf_id,
    CLM_ID as claim_id,
    SEGMENT as claim_line_segment,
    try_to_date(CLM_FROM_DT::varchar, 'YYYYMMDD') as claim_from_date,
    try_to_date(CLM_THRU_DT::varchar, 'YYYYMMDD') as claim_thru_date,
    PRVDR_NUM as provider_number,
    CLM_PMT_AMT as claim_payment_amount,
    NCH_PRMRY_PYR_CLM_PD_AMT as nch_primary_payer_claim_paid_amount,
    AT_PHYSN_NPI as attending_physician_npi,
    OP_PHYSN_NPI as operating_physician_npi,
    OT_PHYSN_NPI as other_physician_npi,
    NCH_BENE_BLOOD_DDCTBL_LBLTY_AM as nch_beneficiary_blood_deductible_liability_amount

    {% for i in range(1, 11) %}
    , ICD9_DGNS_CD_{{ i }} as icd9_diagnosis_code_{{ i }}
    {% endfor %}

    {% for i in range(1, 7) %}
    , ICD9_PRCDR_CD_{{ i }} as icd9_procedure_code_{{ i }}
    {% endfor %}

    , NCH_BENE_PTB_DDCTBL_AMT as nch_beneficiary_part_b_deductible_amount
    , NCH_BENE_PTB_COINSRNC_AMT as nch_beneficiary_part_b_coinsurance_amount
    , ADMTNG_ICD9_DGNS_CD as admitting_icd9_diagnosis_code

    {% for i in range(1, 46) %}
    , HCPCS_CD_{{ i }} as hcpcs_cd_{{ i }}
    {% endfor %}

    , 1 as sample_id
    , 'DE1_0_2008_TO_2010_OUTPATIENT_CLAIMS_SAMPLE_1' as source_table_name
from {{ source('synpuf_prestaging', 'DE1_0_2008_TO_2010_OUTPATIENT_CLAIMS_SAMPLE_1') }}