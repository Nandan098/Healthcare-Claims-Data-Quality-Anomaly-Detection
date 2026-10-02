# Power BI Build Guide

## Main fact
Use `05_outputs/fact_claims_enriched.csv`.

## Model
Fact relationships: Patients[Patient_ID], Providers[Provider_ID], Facilities[Facility_ID], Diagnosis[Diagnosis_Code], Procedure[Procedure_Code], and a Date table linked to Service_Date.

## Page 1 — Claims Overview
KPI cards: Total Claims, Unique Patients, Total Billed, Total Paid, Payment Rate, Average Claim Amount.

Charts: monthly claims trend, payer mix, claim type, billed by specialty, claim status.

## Page 2 — Data Quality
Show duplicate rows, missing Provider_ID, missing claim-line diagnosis, Paid > Allowed, submission-before-service. Add exception detail table.

## Page 3 — Provider & Anomaly Monitoring
Show flagged claims, high-value claims, provider weekly spikes, financial exceptions, provider volume, provider average claim vs specialty baseline, and procedure concentration.

Use wording such as "flagged for review" and "unusual pattern" rather than calling an anomaly fraud.
