# Synthetic Healthcare Claims Dataset — Innovaccer Project 2

This dataset is synthetic, but designed to behave like an operational healthcare claims environment.

## Volume
- 20,000 patients
- 75,000 unique generated claims
- 75,025 raw claim rows (25 intentional duplicates for data-quality testing)
- 123,343 claim lines
- 450 providers
- 25 facilities
- 25 diagnosis codes
- 25 procedure codes
- 2024-01-01 to 2026-09-30

## Non-uniform design
Category frequencies are deliberately unequal: patient utilization is long-tailed, provider activity is right-skewed, payer shares differ, facility types/sizes differ, procedures/diagnoses have very different frequencies, and claim amounts have a heavy right tail. Claim type also depends partly on provider specialty.

## Fairness / bias design
Race/ethnicity is not included. Gender is descriptive only and is not used to mechanically set claim cost, denial status, or provider activity. Utilization and claim amounts are driven primarily by care setting, specialty, procedure mix, payer rules, age-related utilization patterns, and stochastic variation. The dataset is not evidence about any real population.

## Intentional issues
A very small number of rows contain missing providers, missing claim-line diagnoses, duplicate claim rows, paid amounts above allowed amounts, extreme claim amounts, late/invalid service dates, and provider volume-spike patterns. These are included only to support QA/anomaly-analysis practice.

`anomaly_ground_truth.csv` is a separate validation file. Do not use its labels in the production dashboard; use it after building your detection logic to measure precision/recall.
