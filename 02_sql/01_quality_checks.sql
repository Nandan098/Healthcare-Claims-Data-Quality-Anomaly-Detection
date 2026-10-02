-- Data quality checks
SELECT Claim_ID,COUNT(*) row_count FROM claims GROUP BY Claim_ID HAVING COUNT(*)>1;
SELECT COUNT(*) missing_provider_rows FROM claims WHERE Provider_ID IS NULL OR TRIM(Provider_ID)='';
SELECT COUNT(*) missing_line_diagnosis FROM claim_lines WHERE Diagnosis_Code IS NULL OR TRIM(Diagnosis_Code)='';
SELECT COUNT(*) paid_gt_allowed FROM claims WHERE Paid_Amount>Allowed_Amount;
SELECT COUNT(*) submission_before_service FROM claims WHERE Submission_Date<Service_Date;
SELECT COUNT(*) negative_claim_amount FROM claims WHERE Claim_Amount<0;
SELECT COUNT(*) orphan_patients FROM claims c LEFT JOIN patients p ON c.Patient_ID=p.Patient_ID WHERE p.Patient_ID IS NULL;
SELECT COUNT(*) orphan_facilities FROM claims c LEFT JOIN facilities f ON c.Facility_ID=f.Facility_ID WHERE f.Facility_ID IS NULL;
