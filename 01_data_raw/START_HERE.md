# Start Here

1. Open `innovaccer_claims.db` in SQLite/DBeaver.
2. Run SQL QA checks first: duplicate Claim_ID, missing Provider_ID/Diagnosis_Code, Paid_Amount > Allowed_Amount, date validity, and referential checks.
3. Enrich claims by joining patients, providers, facilities, diagnosis and procedure catalogs.
4. In Python calculate provider weekly volume, median/average claim amount, payer denial rate, procedure concentration, P95/P99 screening thresholds, rolling volume and duplicate patterns.
5. Build Power BI pages: Claims Overview, Data Quality, Provider/Procedure Anomalies.
6. Finally compare your detector to `anomaly_ground_truth.csv` for evaluation.
