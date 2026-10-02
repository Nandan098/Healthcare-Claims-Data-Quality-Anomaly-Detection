from pathlib import Path
import sqlite3
import pandas as pd
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "01_data_raw" / "innovaccer_claims.db"
OUT = ROOT / "05_outputs"

conn = sqlite3.connect(DB)
claims = pd.read_sql_query("SELECT * FROM claims", conn)
patients = pd.read_sql_query("SELECT * FROM patients", conn)
providers = pd.read_sql_query("SELECT * FROM providers", conn)
facilities = pd.read_sql_query("SELECT * FROM facilities", conn)
diagnosis = pd.read_sql_query("SELECT * FROM diagnosis_catalog", conn)
procedure = pd.read_sql_query("SELECT * FROM procedure_catalog", conn)
conn.close()

claims["Service_Date"] = pd.to_datetime(claims["Service_Date"], errors="coerce")
claims["Submission_Date"] = pd.to_datetime(claims["Submission_Date"], errors="coerce")
for col in ["Claim_Amount", "Allowed_Amount", "Paid_Amount", "Member_Responsibility"]:
    claims[col] = pd.to_numeric(claims[col], errors="coerce")

fact = (
    claims
    .merge(patients[["Patient_ID", "Age", "Gender", "Payer", "Region"]], on="Patient_ID", how="left")
    .merge(providers[["Provider_ID", "Provider_Display_Name", "Specialty"]], on="Provider_ID", how="left")
    .merge(facilities[["Facility_ID", "Facility_Name", "Facility_Type", "Facility_Size"]], on="Facility_ID", how="left")
    .merge(diagnosis[["Diagnosis_Code", "Diagnosis_Name", "Clinical_Group"]], on="Diagnosis_Code", how="left")
    .merge(procedure[["Procedure_Code", "Procedure_Name", "Procedure_Group"]], left_on="Primary_Procedure_Code", right_on="Procedure_Code", how="left")
)

fact["Submission_Lag_Days"] = (fact["Submission_Date"] - fact["Service_Date"]).dt.days
fact["Month"] = fact["Service_Date"].dt.to_period("M").astype(str)
fact["Week_Start"] = (fact["Service_Date"] - pd.to_timedelta(fact["Service_Date"].dt.weekday, unit="D")).dt.date.astype(str)
fact["Financial_Exception"] = (fact["Paid_Amount"] > fact["Allowed_Amount"]).astype(int)

p99 = fact["Claim_Amount"].quantile(0.99)
fact["High_Value_P99"] = (fact["Claim_Amount"] >= p99).astype(int)
fact["Missing_Provider"] = fact["Provider_ID"].fillna("").eq("").astype(int)

weekly = fact[fact["Provider_ID"].fillna("").ne("")].groupby(["Provider_ID", "Week_Start"]).size().reset_index(name="Weekly_Claims")
stats = weekly.groupby("Provider_ID")["Weekly_Claims"].agg(["mean", "std"]).reset_index()
stats = stats.rename(columns={"mean": "Mean_Weekly_Claims", "std": "Std_Weekly_Claims"})
weekly = weekly.merge(stats, on="Provider_ID", how="left")
weekly["Volume_Z"] = (weekly["Weekly_Claims"] - weekly["Mean_Weekly_Claims"]) / weekly["Std_Weekly_Claims"].replace(0, np.nan)
spikes = weekly[(weekly["Volume_Z"] >= 3) & (weekly["Weekly_Claims"] >= 8)]
spike_keys = set(zip(spikes["Provider_ID"], spikes["Week_Start"]))
fact["Provider_Week_Spike"] = [int((p, w) in spike_keys) for p, w in zip(fact["Provider_ID"], fact["Week_Start"])]

fact["Anomaly_Flag"] = ((fact["High_Value_P99"] == 1) | (fact["Financial_Exception"] == 1) | (fact["Missing_Provider"] == 1) | (fact["Provider_Week_Spike"] == 1)).astype(int)

OUT.mkdir(exist_ok=True)
fact.to_csv(OUT / "fact_claims_enriched.csv", index=False)
fact[fact["Anomaly_Flag"] == 1].to_csv(OUT / "claim_anomaly_flags.csv", index=False)
print("Saved Power BI-ready and anomaly outputs to", OUT)
