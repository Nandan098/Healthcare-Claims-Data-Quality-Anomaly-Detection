# Project 2 — Healthcare Claims Data Quality & Anomaly Detection

## Business objective
Monitor claims operations, payer/provider performance, data quality and unusual patterns using a reproducible analytics workflow.

## Dataset
- 20,000 patients
- 75,025 raw claim rows
- 123,343 claim lines
- 450 providers
- 25 facilities
- 25 diagnosis codes
- 25 procedure codes
- 2024-01-01 to 2026-09-30

## SQL
36 business analyses are included, covering trends, payer performance, claim status/type, specialty/provider/facility analysis, diagnosis/procedure mix, peer benchmarks, denial/rejection, concentration, duplicates, missing data, submission lag, utilization buckets, claim-line reconciliation, and month-by-status patterns.

## Python
The notebook performs data typing, validation, enrichment, distribution analysis, P99/IQR screening, provider weekly spike detection, financial exception detection, procedure concentration, anomaly combination and evaluation.

## Anomaly rules
- P99 high-value claim
- Provider weekly volume spike (>=3 SD above provider baseline, min 8 claims)
- Paid Amount > Allowed Amount
- Missing Provider_ID

## Interpretation
An anomaly is a screening signal for review; it is not proof of fraud, error, or misconduct.

## Portfolio deliverables
SQL scripts, 36 SQL result CSVs, readable Jupyter notebook, Python script, Power BI DAX and guide, enriched fact table, anomaly outputs, documentation, interview Q&A, and resume bullets.
