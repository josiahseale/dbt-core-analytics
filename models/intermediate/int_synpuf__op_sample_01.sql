{{ config(materialized='view') }}

select
    desynpuf_id,

    -- claim grain and timing
    clm_id as claim_id,
    segment,
    clm_from_dt as claim_from_date,
    clm_thru_dt as claim_through_date,

    -- provider / physician identifiers
    prvdr_num as provider_number,
    at_physn_npi as attending_physician_npi,
    op_physn_npi as operating_physician_npi,
    ot_physn_npi as other_physician_npi,

    -- financial fields
    clm_pmt_amt as claim_payment_amount,
    nch_prmry_pyr_clm_pd_amt as nch_primary_payer_claim_paid_amount,
    nch_bene_blood_ddctbl_lblty_am as nch_beneficiary_blood_deductible_liability_amount,
    nch_bene_ptb_ddctbl_amt as nch_beneficiary_part_b_deductible_amount,
    nch_bene_ptb_coinsrnc_amt as nch_beneficiary_part_b_coinsurance_amount,

    -- admitting diagnosis
    admtng_icd9_dgns_cd as admitting_icd9_diagnosis_code,

    -- diagnosis codes
    icd9_dgns_cd_1  as icd9_diagnosis_code_1,
    icd9_dgns_cd_2  as icd9_diagnosis_code_2,
    icd9_dgns_cd_3  as icd9_diagnosis_code_3,
    icd9_dgns_cd_4  as icd9_diagnosis_code_4,
    icd9_dgns_cd_5  as icd9_diagnosis_code_5,
    icd9_dgns_cd_6  as icd9_diagnosis_code_6,
    icd9_dgns_cd_7  as icd9_diagnosis_code_7,
    icd9_dgns_cd_8  as icd9_diagnosis_code_8,
    icd9_dgns_cd_9  as icd9_diagnosis_code_9,
    icd9_dgns_cd_10 as icd9_diagnosis_code_10,

    -- procedure codes
    icd9_prcdr_cd_1 as icd9_procedure_code_1,
    icd9_prcdr_cd_2 as icd9_procedure_code_2,
    icd9_prcdr_cd_3 as icd9_procedure_code_3,
    icd9_prcdr_cd_4 as icd9_procedure_code_4,
    icd9_prcdr_cd_5 as icd9_procedure_code_5,
    icd9_prcdr_cd_6 as icd9_procedure_code_6,

    -- HCPCS / procedure lines
    hcpcs_cd_1  as hcpcs_code_1,
    hcpcs_cd_2  as hcpcs_code_2,
    hcpcs_cd_3  as hcpcs_code_3,
    hcpcs_cd_4  as hcpcs_code_4,
    hcpcs_cd_5  as hcpcs_code_5,
    hcpcs_cd_6  as hcpcs_code_6,
    hcpcs_cd_7  as hcpcs_code_7,
    hcpcs_cd_8  as hcpcs_code_8,
    hcpcs_cd_9  as hcpcs_code_9,
    hcpcs_cd_10 as hcpcs_code_10,
    hcpcs_cd_11 as hcpcs_code_11,
    hcpcs_cd_12 as hcpcs_code_12,
    hcpcs_cd_13 as hcpcs_code_13,
    hcpcs_cd_14 as hcpcs_code_14,
    hcpcs_cd_15 as hcpcs_code_15,
    hcpcs_cd_16 as hcpcs_code_16,
    hcpcs_cd_17 as hcpcs_code_17,
    hcpcs_cd_18 as hcpcs_code_18,
    hcpcs_cd_19 as hcpcs_code_19,
    hcpcs_cd_20 as hcpcs_code_20,
    hcpcs_cd_21 as hcpcs_code_21,
    hcpcs_cd_22 as hcpcs_code_22,
    hcpcs_cd_23 as hcpcs_code_23,
    hcpcs_cd_24 as hcpcs_code_24,
    hcpcs_cd_25 as hcpcs_code_25,
    hcpcs_cd_26 as hcpcs_code_26,
    hcpcs_cd_27 as hcpcs_code_27,
    hcpcs_cd_28 as hcpcs_code_28,
    hcpcs_cd_29 as hcpcs_code_29,
    hcpcs_cd_30 as hcpcs_code_30,
    hcpcs_cd_31 as hcpcs_code_31,
    hcpcs_cd_32 as hcpcs_code_32,
    hcpcs_cd_33 as hcpcs_code_33,
    hcpcs_cd_34 as hcpcs_code_34,
    hcpcs_cd_35 as hcpcs_code_35,
    hcpcs_cd_36 as hcpcs_code_36,
    hcpcs_cd_37 as hcpcs_code_37,
    hcpcs_cd_38 as hcpcs_code_38,
    hcpcs_cd_39 as hcpcs_code_39,
    hcpcs_cd_40 as hcpcs_code_40,
    hcpcs_cd_41 as hcpcs_code_41,
    hcpcs_cd_42 as hcpcs_code_42,
    hcpcs_cd_43 as hcpcs_code_43,
    hcpcs_cd_44 as hcpcs_code_44,
    hcpcs_cd_45 as hcpcs_code_45,

    sample_id,
    source_table_name

from {{ ref('stg_synpuf__op_sample_01') }}