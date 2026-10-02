-- 01. 01_overall_kpis
SELECT COUNT(*) raw_claim_rows,COUNT(DISTINCT Claim_ID) unique_claims,COUNT(DISTINCT Patient_ID) unique_patients,COUNT(DISTINCT Provider_ID) unique_providers,ROUND(SUM(Claim_Amount),2) total_claim_amount,ROUND(SUM(Allowed_Amount),2) total_allowed_amount,ROUND(SUM(Paid_Amount),2) total_paid_amount,ROUND(AVG(Claim_Amount),2) avg_claim_amount FROM claims;

-- 02. 02_monthly_trend
SELECT substr(Service_Date,1,7) month,COUNT(*) claims,COUNT(DISTINCT Patient_ID) unique_patients,ROUND(SUM(Claim_Amount),2) billed,ROUND(SUM(Allowed_Amount),2) allowed,ROUND(SUM(Paid_Amount),2) paid FROM claims GROUP BY substr(Service_Date,1,7) ORDER BY month;

-- 03. 03_mom_growth
WITH m AS (SELECT substr(Service_Date,1,7) month,COUNT(*) claims FROM claims GROUP BY substr(Service_Date,1,7)) SELECT month,claims,LAG(claims) OVER(ORDER BY month) prior_month_claims,ROUND(100.0*(claims-LAG(claims) OVER(ORDER BY month))/NULLIF(LAG(claims) OVER(ORDER BY month),0),2) mom_growth_pct FROM m ORDER BY month;

-- 04. 04_payer_performance
SELECT Payer,COUNT(*) claims,COUNT(DISTINCT Patient_ID) patients,ROUND(SUM(Claim_Amount),2) billed,ROUND(SUM(Allowed_Amount),2) allowed,ROUND(SUM(Paid_Amount),2) paid,ROUND(100.0*SUM(Paid_Amount)/NULLIF(SUM(Allowed_Amount),0),2) payment_rate_pct,ROUND(100.0*AVG(CASE WHEN Claim_Status IN('Denied','Rejected') THEN 1.0 ELSE 0.0 END),2) denial_rejection_rate_pct FROM claims GROUP BY Payer ORDER BY claims DESC;

-- 05. 05_status_mix
SELECT Claim_Status,COUNT(*) claims,ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) share_pct,ROUND(SUM(Claim_Amount),2) billed FROM claims GROUP BY Claim_Status ORDER BY claims DESC;

-- 06. 06_claim_type_mix
SELECT Claim_Type,COUNT(*) claims,COUNT(DISTINCT Patient_ID) patients,ROUND(AVG(Claim_Amount),2) avg_claim_amount,ROUND(SUM(Claim_Amount),2) billed,ROUND(SUM(Paid_Amount),2) paid FROM claims GROUP BY Claim_Type ORDER BY claims DESC;

-- 07. 07_specialty_summary
SELECT p.Specialty,COUNT(*) claims,COUNT(DISTINCT c.Patient_ID) patients,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount,ROUND(SUM(c.Claim_Amount),2) billed,ROUND(SUM(c.Paid_Amount),2) paid,ROUND(100.0*AVG(CASE WHEN c.Claim_Status IN('Denied','Rejected') THEN 1.0 ELSE 0.0 END),2) denial_rejection_rate_pct FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY p.Specialty ORDER BY billed DESC;

-- 08. 08_top_providers_volume
SELECT c.Provider_ID,p.Provider_Display_Name,p.Specialty,COUNT(*) claims,ROUND(SUM(c.Claim_Amount),2) billed,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY c.Provider_ID,p.Provider_Display_Name,p.Specialty ORDER BY claims DESC LIMIT 20;

-- 09. 09_provider_financial_intensity
SELECT c.Provider_ID,p.Provider_Display_Name,p.Specialty,COUNT(*) claims,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount,ROUND(AVG(c.Allowed_Amount),2) avg_allowed_amount,ROUND(AVG(c.Paid_Amount),2) avg_paid_amount,ROUND(100.0*SUM(c.Paid_Amount)/NULLIF(SUM(c.Allowed_Amount),0),2) payment_rate_pct FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY c.Provider_ID,p.Provider_Display_Name,p.Specialty HAVING COUNT(*)>=50 ORDER BY avg_claim_amount DESC;

-- 10. 10_facility_performance
SELECT f.Facility_ID,f.Facility_Name,f.Facility_Type,f.Facility_Size,COUNT(c.Claim_ID) claims,COUNT(DISTINCT c.Patient_ID) patients,ROUND(SUM(c.Claim_Amount),2) billed,ROUND(SUM(c.Paid_Amount),2) paid,ROUND(100.0*SUM(c.Paid_Amount)/NULLIF(SUM(c.Allowed_Amount),0),2) payment_rate_pct FROM claims c JOIN facilities f ON c.Facility_ID=f.Facility_ID GROUP BY f.Facility_ID,f.Facility_Name,f.Facility_Type,f.Facility_Size ORDER BY billed DESC;

-- 11. 11_facility_type
SELECT f.Facility_Type,COUNT(*) claims,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount,ROUND(SUM(c.Claim_Amount),2) billed,ROUND(SUM(c.Paid_Amount),2) paid FROM claims c JOIN facilities f ON c.Facility_ID=f.Facility_ID GROUP BY f.Facility_Type ORDER BY billed DESC;

-- 12. 12_diagnosis_mix
SELECT dc.Diagnosis_Code,dc.Diagnosis_Name,dc.Clinical_Group,COUNT(*) claims,COUNT(DISTINCT c.Patient_ID) patients,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount,ROUND(SUM(c.Claim_Amount),2) billed FROM claims c JOIN diagnosis_catalog dc ON c.Diagnosis_Code=dc.Diagnosis_Code GROUP BY dc.Diagnosis_Code,dc.Diagnosis_Name,dc.Clinical_Group ORDER BY claims DESC;

-- 13. 13_procedure_mix
SELECT pc.Procedure_Code,pc.Procedure_Name,pc.Procedure_Group,COUNT(*) claims,ROUND(AVG(c.Claim_Amount),2) avg_claim_amount,ROUND(SUM(c.Claim_Amount),2) billed,ROUND(SUM(c.Paid_Amount),2) paid FROM claims c JOIN procedure_catalog pc ON c.Primary_Procedure_Code=pc.Procedure_Code GROUP BY pc.Procedure_Code,pc.Procedure_Name,pc.Procedure_Group ORDER BY claims DESC;

-- 14. 14_payer_status_matrix
SELECT Payer,Claim_Status,COUNT(*) claims,ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(PARTITION BY Payer),2) payer_status_share_pct FROM claims GROUP BY Payer,Claim_Status ORDER BY Payer,claims DESC;

-- 15. 15_denial_rate_by_payer
SELECT Payer,COUNT(*) total_claims,SUM(CASE WHEN Claim_Status IN('Denied','Rejected') THEN 1 ELSE 0 END) denied_rejected,ROUND(100.0*SUM(CASE WHEN Claim_Status IN('Denied','Rejected') THEN 1 ELSE 0 END)/COUNT(*),2) denial_rejection_rate_pct FROM claims GROUP BY Payer ORDER BY denial_rejection_rate_pct DESC;

-- 16. 16_p99_high_value
WITH ranked AS (SELECT Claim_ID,Claim_Amount,ROW_NUMBER() OVER(ORDER BY Claim_Amount) rn,COUNT(*) OVER() n FROM claims) SELECT Claim_ID,Claim_Amount FROM ranked WHERE Claim_Amount >= (SELECT Claim_Amount FROM ranked WHERE rn=CAST(0.99*n AS INTEGER)) ORDER BY Claim_Amount DESC;

-- 17. 17_provider_weekly_volume
SELECT Provider_ID,substr(Service_Date,1,4)||'-W'||printf('%02d',CAST(strftime('%W',Service_Date) AS INTEGER)) year_week,COUNT(*) claims FROM claims WHERE Provider_ID IS NOT NULL AND TRIM(Provider_ID)<>'' GROUP BY Provider_ID,year_week ORDER BY Provider_ID,year_week;

-- 18. 18_provider_vs_specialty_volume
WITH pc AS (SELECT c.Provider_ID,p.Specialty,COUNT(*) claims FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY c.Provider_ID,p.Specialty),b AS (SELECT Specialty,AVG(claims) specialty_avg_claims FROM pc GROUP BY Specialty) SELECT pc.Provider_ID,pc.Specialty,pc.claims,ROUND(b.specialty_avg_claims,1) specialty_avg_claims,ROUND(pc.claims/NULLIF(b.specialty_avg_claims,0),2) volume_vs_peer_ratio FROM pc JOIN b ON pc.Specialty=b.Specialty WHERE pc.claims>=50 ORDER BY volume_vs_peer_ratio DESC;

-- 19. 19_provider_denial_rate
SELECT c.Provider_ID,p.Provider_Display_Name,p.Specialty,COUNT(*) claims,SUM(CASE WHEN c.Claim_Status IN('Denied','Rejected') THEN 1 ELSE 0 END) denied_rejected,ROUND(100.0*SUM(CASE WHEN c.Claim_Status IN('Denied','Rejected') THEN 1 ELSE 0 END)/COUNT(*),2) denial_rejection_rate_pct FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY c.Provider_ID,p.Provider_Display_Name,p.Specialty HAVING COUNT(*)>=100 ORDER BY denial_rejection_rate_pct DESC;

-- 20. 20_procedure_concentration
WITH pp AS (SELECT Provider_ID,Primary_Procedure_Code,COUNT(*) proc_claims FROM claims WHERE Provider_ID IS NOT NULL AND TRIM(Provider_ID)<>'' GROUP BY Provider_ID,Primary_Procedure_Code),pt AS (SELECT Provider_ID,SUM(proc_claims) total_claims FROM pp GROUP BY Provider_ID) SELECT pp.Provider_ID,pp.Primary_Procedure_Code,pp.proc_claims,pt.total_claims,ROUND(100.0*pp.proc_claims/pt.total_claims,2) procedure_share_pct FROM pp JOIN pt ON pp.Provider_ID=pt.Provider_ID WHERE pt.total_claims>=50 ORDER BY procedure_share_pct DESC;

-- 21. 21_duplicate_claim_ids
SELECT Claim_ID,COUNT(*) row_count,MIN(Service_Date) first_service_date,MAX(Service_Date) last_service_date FROM claims GROUP BY Claim_ID HAVING COUNT(*)>1 ORDER BY row_count DESC,Claim_ID;

-- 22. 22_duplicate_patient_provider_procedure_date
SELECT Patient_ID,Provider_ID,Primary_Procedure_Code,Service_Date,COUNT(*) rows_for_same_key FROM claims GROUP BY Patient_ID,Provider_ID,Primary_Procedure_Code,Service_Date HAVING COUNT(*)>1 ORDER BY rows_for_same_key DESC;

-- 23. 23_financial_exceptions
SELECT COUNT(*) paid_gt_allowed_rows,ROUND(SUM(CASE WHEN Paid_Amount>Allowed_Amount THEN Paid_Amount-Allowed_Amount ELSE 0 END),2) excess_paid_amount FROM claims WHERE Paid_Amount>Allowed_Amount;

-- 24. 24_missing_provider_by_payer
SELECT Payer,Claim_Type,COUNT(*) missing_provider_claims FROM claims WHERE Provider_ID IS NULL OR TRIM(Provider_ID)='' GROUP BY Payer,Claim_Type ORDER BY missing_provider_claims DESC;

-- 25. 25_claim_line_completeness
SELECT COUNT(*) total_lines,SUM(CASE WHEN Diagnosis_Code IS NULL OR TRIM(Diagnosis_Code)='' THEN 1 ELSE 0 END) missing_diagnosis_lines,ROUND(100.0*SUM(CASE WHEN Diagnosis_Code IS NULL OR TRIM(Diagnosis_Code)='' THEN 1 ELSE 0 END)/COUNT(*),2) missing_diagnosis_pct FROM claim_lines;

-- 26. 26_submission_lag_by_month
SELECT substr(Service_Date,1,7) month,ROUND(AVG(julianday(Submission_Date)-julianday(Service_Date)),2) avg_lag_days,ROUND(MAX(julianday(Submission_Date)-julianday(Service_Date)),2) max_lag_days,SUM(CASE WHEN julianday(Submission_Date)-julianday(Service_Date)>30 THEN 1 ELSE 0 END) over_30_days FROM claims GROUP BY substr(Service_Date,1,7) ORDER BY month;

-- 27. 27_long_submission_lag
SELECT Claim_ID,Patient_ID,Provider_ID,Service_Date,Submission_Date,ROUND(julianday(Submission_Date)-julianday(Service_Date),1) submission_lag_days,Claim_Amount FROM claims WHERE julianday(Submission_Date)-julianday(Service_Date)>30 ORDER BY submission_lag_days DESC LIMIT 100;

-- 28. 28_patient_utilization_buckets
WITH pc AS (SELECT Patient_ID,COUNT(*) claims FROM claims GROUP BY Patient_ID) SELECT CASE WHEN claims=1 THEN '1 claim' WHEN claims BETWEEN 2 AND 3 THEN '2-3 claims' WHEN claims BETWEEN 4 AND 6 THEN '4-6 claims' WHEN claims BETWEEN 7 AND 10 THEN '7-10 claims' ELSE '11+ claims' END utilization_bucket,COUNT(*) patients,ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) patient_share_pct FROM pc GROUP BY utilization_bucket ORDER BY patients DESC;

-- 29. 29_high_utilization_patients
SELECT c.Patient_ID,p.Age,p.Payer,COUNT(*) claims,ROUND(SUM(c.Claim_Amount),2) total_billed,ROUND(SUM(c.Paid_Amount),2) total_paid,COUNT(DISTINCT c.Provider_ID) distinct_providers FROM claims c JOIN patients p ON c.Patient_ID=p.Patient_ID GROUP BY c.Patient_ID,p.Age,p.Payer HAVING COUNT(*)>=8 ORDER BY claims DESC,total_billed DESC LIMIT 100;

-- 30. 30_header_line_reconciliation
WITH lt AS (SELECT Claim_ID,ROUND(SUM(Line_Charge),2) total_line_charge FROM claim_lines GROUP BY Claim_ID) SELECT c.Claim_ID,ROUND(c.Claim_Amount,2) header_charge,ROUND(lt.total_line_charge,2) line_charge,ROUND(c.Claim_Amount-lt.total_line_charge,2) reconciliation_difference FROM claims c JOIN lt ON c.Claim_ID=lt.Claim_ID WHERE ABS(c.Claim_Amount-lt.total_line_charge)>0.01 ORDER BY ABS(c.Claim_Amount-lt.total_line_charge) DESC LIMIT 100;

-- 31. 31_provider_avg_vs_specialty
WITH ps AS (SELECT c.Provider_ID,p.Specialty,COUNT(*) claims,AVG(c.Claim_Amount) provider_avg_claim FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY c.Provider_ID,p.Specialty),ss AS (SELECT p.Specialty,AVG(c.Claim_Amount) specialty_avg_claim FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY p.Specialty) SELECT ps.Provider_ID,ps.Specialty,ps.claims,ROUND(ps.provider_avg_claim,2) provider_avg_claim,ROUND(ss.specialty_avg_claim,2) specialty_avg_claim,ROUND(ps.provider_avg_claim/NULLIF(ss.specialty_avg_claim,0),2) avg_claim_vs_peer_ratio FROM ps JOIN ss ON ps.Specialty=ss.Specialty WHERE ps.claims>=100 ORDER BY avg_claim_vs_peer_ratio DESC;

-- 32. 32_payer_claim_type_payment
SELECT Payer,Claim_Type,COUNT(*) claims,ROUND(AVG(Allowed_Amount),2) avg_allowed,ROUND(AVG(Paid_Amount),2) avg_paid,ROUND(100.0*SUM(Paid_Amount)/NULLIF(SUM(Allowed_Amount),0),2) payment_rate_pct FROM claims GROUP BY Payer,Claim_Type HAVING COUNT(*)>=20 ORDER BY Payer,payment_rate_pct DESC;

-- 33. 33_facility_month_spikes
WITH fm AS (SELECT Facility_ID,substr(Service_Date,1,7) month,COUNT(*) claims FROM claims GROUP BY Facility_ID,substr(Service_Date,1,7)),fb AS (SELECT Facility_ID,AVG(claims) avg_monthly_claims FROM fm GROUP BY Facility_ID) SELECT fm.Facility_ID,f.Facility_Name,fm.month,fm.claims,ROUND(fb.avg_monthly_claims,1) avg_monthly_claims,ROUND(fm.claims/NULLIF(fb.avg_monthly_claims,0),2) volume_ratio FROM fm JOIN fb ON fm.Facility_ID=fb.Facility_ID JOIN facilities f ON fm.Facility_ID=f.Facility_ID ORDER BY volume_ratio DESC LIMIT 100;

-- 34. 34_member_responsibility
SELECT Payer,COUNT(*) claims,ROUND(AVG(Member_Responsibility),2) avg_member_responsibility,ROUND(100.0*SUM(Member_Responsibility)/NULLIF(SUM(Allowed_Amount),0),2) member_share_pct FROM claims GROUP BY Payer ORDER BY member_share_pct DESC;

-- 35. 35_month_status_mix
SELECT substr(Service_Date,1,7) month,Claim_Status,COUNT(*) claims,ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(PARTITION BY substr(Service_Date,1,7)),2) month_status_share_pct FROM claims GROUP BY substr(Service_Date,1,7),Claim_Status ORDER BY month,claims DESC;

-- 36. 36_top_diagnoses_by_specialty
WITH ranked AS (SELECT p.Specialty,c.Diagnosis_Code,dc.Diagnosis_Name,COUNT(*) claims,ROW_NUMBER() OVER(PARTITION BY p.Specialty ORDER BY COUNT(*) DESC) rn FROM claims c JOIN providers p ON c.Provider_ID=p.Provider_ID JOIN diagnosis_catalog dc ON c.Diagnosis_Code=dc.Diagnosis_Code WHERE c.Provider_ID IS NOT NULL AND TRIM(c.Provider_ID)<>'' GROUP BY p.Specialty,c.Diagnosis_Code,dc.Diagnosis_Name) SELECT * FROM ranked WHERE rn<=3 ORDER BY Specialty,rn;
