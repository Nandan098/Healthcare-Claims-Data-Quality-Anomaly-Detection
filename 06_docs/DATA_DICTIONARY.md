# Data Dictionary

`patients`: Patient_ID, Birth_Date, Age, Gender, Payer, Region

`providers`: Provider_ID, Provider_Display_Name, Facility_ID, Specialty, Activity_Weight

`facilities`: Facility_ID, Facility_Name, Facility_Type, Facility_Size, Region

`claims`: Claim_ID, Patient_ID, Service_Date, Submission_Date, Provider_ID, Facility_ID, Payer, Claim_Type, Claim_Status, Diagnosis_Code, Primary_Procedure_Code, Claim_Amount, Allowed_Amount, Paid_Amount, Member_Responsibility, Quality_Issue

`claim_lines`: Claim_Line_ID, Claim_ID, Line_Number, Diagnosis_Code, Procedure_Code, Line_Charge, Line_Allowed, Line_Paid, Billing_Level

`diagnosis_catalog`: Diagnosis_Code, Diagnosis_Name, Clinical_Group, Synthetic_Prevalence_Weight

`procedure_catalog`: Procedure_Code, Procedure_Name, Procedure_Group, Synthetic_Prevalence_Weight, Typical_Min_Charge, Typical_Max_Charge

`anomaly_ground_truth`: validation-only synthetic labels.
