# Healthcare Claims Data Quality & Anomaly Detection

An end-to-end healthcare analytics project built with **SQL, Python, MySQL, and Power BI**.


##  Project Overview

Healthcare claims data can contain millions of records coming from different providers, facilities, payers, and billing systems. Before such data can be used for reporting, analysts need to answer two questions:

1. **Can we trust the data?**
2. **Are there unusual patterns that deserve further investigation?**

This project addresses both questions through a complete analytics workflow:

```text
Raw Claims Data
      ↓
SQL Data Validation
      ↓
SQL Business Analysis
      ↓
Python Data Cleaning & Enrichment
      ↓
Anomaly Detection
      ↓
Model Evaluation
      ↓
Power BI Reporting
```

---

## Business Objectives

The project is designed to answer questions such as:

- How is claim volume changing over time?
- Which payers generate the largest claim volumes?
- Which providers and specialties handle the most claims?
- Which payers have higher denial/rejection rates?
- How much is billed, allowed, and paid?
- Which providers have unusually high claim activity?
- Which claims have unusually high amounts?
- Where are data-quality exceptions occurring?
- Which procedures are highly concentrated among individual providers?
- How quickly are claims submitted after the service date?

---

##  Dataset


### Dataset scale

| Entity | Volume |
|---|---:|
| Patients | 20K+ |
| Claims | 75K+ |
| Claim Lines | 100K+ |
| Providers | 450 |
| Facilities | 25 |
| Diagnosis Categories | 25 |
| Procedure Categories | 25 |

### Data period

**January 2024 – September 2026**

### Main tables

| Table | Purpose |
|---|---|
| `patients` | Patient demographics and payer information |
| `providers` | Provider, specialty, and facility assignment |
| `facilities` | Facility type, size, and region |
| `claims` | Main claim-level fact table |
| `claim_lines` | Line-level billing detail |
| `diagnosis_catalog` | Diagnosis reference table |
| `procedure_catalog` | Procedure reference table |

---

---

## Data Quality Checks

Before performing business analysis, the project validates the raw data.

### Identifier checks

- Duplicate `Claim_ID`
- Duplicate patient identifiers
- Duplicate provider identifiers
- Duplicate claim-line identifiers

### Completeness checks

- Missing provider IDs
- Missing diagnosis codes
- Missing claim-line diagnosis information

### Financial checks

- `Paid_Amount > Allowed_Amount`
- Negative claim amounts
- Negative paid amounts

### Date checks

- Submission date before service date
- Service dates outside the study period
- Unusual submission lag

### Referential integrity

The project checks whether claim records correctly map to:

- Patients
- Providers
- Facilities
- Diagnosis codes
- Procedure codes

---

## SQL Analysis

The project contains **36 SQL business analyses** using:

- `JOIN`
- `GROUP BY`
- `HAVING`
- `CASE`
- `CTE`
- Window functions
- `LAG()`
- `ROW_NUMBER()`
- Peer benchmarking
- Percentile-style analysis
- Reconciliation logic

### Analysis areas

**Claims performance**
- Overall claims KPIs
- Monthly trends
- Month-over-month growth
- Claim type mix
- Claim status mix

**Payer analysis**
- Payer volume
- Payment rate
- Denial/rejection rate
- Payer × claim status
- Payer × claim type performance

**Provider analysis**
- Top providers by volume
- Provider financial intensity
- Provider denial rates
- Provider volume compared with specialty peers
- Provider average claim compared with specialty benchmark
- Procedure concentration

**Facility analysis**
- Facility performance
- Facility type comparison
- Facility-month volume patterns

**Clinical/service analysis**
- Diagnosis mix
- Procedure mix
- Top diagnoses by specialty

**Data-quality analysis**
- Duplicate claims
- Duplicate patient/provider/procedure/date patterns
- Missing providers
- Missing diagnoses
- Financial exceptions
- Submission lag
- Claim header vs. claim-line reconciliation

**Utilization analysis**
- Patient utilization buckets
- High-utilization patients
- Provider weekly claim volume

---

##  Anomaly Detection

The project uses **explainable, rule-based anomaly detection**.

The objective is not to build a black-box model. The objective is to create screening logic that an analyst can explain to a business stakeholder.

### 1. High-Value Claim

Claims at or above the **99th percentile** of claim amount are flagged.

Why?

A percentile-based threshold adapts to the distribution instead of using an arbitrary fixed dollar amount.

---

### 2. Provider Weekly Volume Spike

For each provider:

```text
Weekly claim volume
        ↓
Calculate provider's baseline
        ↓
Calculate standard deviation
        ↓
Flag unusually high weeks
```

A provider-week is flagged when it is:

- At least **3 standard deviations above the provider's baseline**
- And has a minimum claim volume threshold

This reduces the chance of treating a small-volume provider's normal fluctuation as a meaningful anomaly.

---

### 3. Financial Exception

A claim is flagged when:

```text
Paid Amount > Allowed Amount
```

This is treated as a **data/financial exception requiring review**.

---

### 4. Missing Provider Attribution

Claims without provider attribution are separately flagged because provider-level analytics cannot be reliably performed on those records.

---

### 5. Procedure Concentration

The project also identifies providers where one procedure represents an unusually large share of their total claims.

This can be useful as a **review signal**, but concentration by itself is not proof that anything is wrong.

---

## Power BI Dashboard

The project is designed around three dashboard pages.

### Page 1 — Claims Overview

**KPI cards**

- Total Claims
- Unique Patients
- Total Billed
- Total Allowed
- Total Paid
- Payment Rate
- Average Claim Amount

**Charts**

- Monthly claim trend
- Claims by payer
- Claims by claim type
- Billed amount by specialty
- Claim status distribution

---

### Page 2 — Data Quality

**KPIs**

- Duplicate Claim Rows
- Missing Provider Claims
- Missing Diagnosis
- Paid > Allowed
- Submission Before Service

**Visuals**

- Data-quality issues by month
- Issues by payer
- Issues by facility
- Exception detail table

---

### Page 3 — Provider & Anomaly Monitoring

**KPIs**

- Flagged Claims
- High-Value Claims
- Provider Volume Spikes
- Financial Exceptions

**Visuals**

- Top providers by claim volume
- Provider average claim vs specialty benchmark
- Weekly provider volume
- Procedure concentration
- High-value claim detail table

---

## Tech Stack

| Tool | Usage |
|---|---|
| **SQL** | Data extraction, validation, aggregation, benchmarking |
| **SQLite** | Relational database |
| **Python** | Cleaning, enrichment, statistical analysis |
| **Pandas** | Data manipulation |
| **NumPy** | Numerical calculations |
| **Jupyter Notebook** | Reproducible analysis |
| **Power BI** | Dashboard and business reporting |
| **DAX** | KPI measures |

---

## Recommended Project Structure

```text
healthcare-claims-anomaly-detection/
│
├── data/
│   ├── patients.csv
│   ├── providers.csv
│   ├── facilities.csv
│   ├── claims.csv
│   ├── claim_lines.csv
│   ├── diagnosis_catalog.csv
│   ├── procedure_catalog.csv
│   └── anomaly_ground_truth.csv
│
├── database/
│   └── innovaccer_claims.db
│
├── sql/
│   ├── 01_quality_checks.sql
│   ├── 02_business_analysis_36_queries.sql
│   └── 03_reporting_view.sql
│
├── python/
│   ├── healthcare_claims_anomaly_analysis.ipynb
│   ├── analysis.py
│   └── requirements.txt
│
├── powerbi/
│   ├── measures.dax
│   └── POWER_BI_BUILD_GUIDE.md
│
├── outputs/
│   ├── fact_claims_enriched.csv
│   ├── payer_summary.csv
│   ├── provider_summary.csv
│   ├── monthly_financial_trends.csv
│   ├── claim_anomaly_flags.csv
│   ├── provider_weekly_volume.csv
│   ├── provider_procedure_concentration.csv
│   └── anomaly_model_evaluation.csv
│
└── README.md
```

---

