# 90-Second Interview Walkthrough

## Situation
A healthcare claims team needs better visibility into claim volume, financial performance, data-quality issues and unusual operating patterns.

## Task
Build an analyst workflow that validates the claims, creates useful KPIs, identifies reviewable anomalies and prepares stakeholder reporting.

## Action
I used SQL first for data-quality checks and 36 business analyses. I then used Python/Pandas to enrich the claims with patient, provider, facility, diagnosis and procedure attributes. I built explainable anomaly rules for P99 claim amounts, provider weekly volume spikes, financial exceptions and missing provider attribution. Finally, I prepared a Power BI-ready fact table and DAX measures.

## Result
The result is a reproducible claims analytics package with raw data, SQLite database, SQL scripts, query outputs, a readable Python notebook, anomaly outputs and Power BI instructions.

## Important caveat
The data and anomalies are synthetic. Anomaly flags are screening signals for review and should not be described as proof of fraud or misconduct.
