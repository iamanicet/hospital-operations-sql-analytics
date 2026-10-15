# 🏥 Hospital Operations & Patient Flow Analytics (MySQL)

![MySQL](https://img.shields.io/badge/Database-MySQL%208.0.16%2B-blue?style=flat-square&logo=mysql)
![Data Analytics](https://img.shields.io/badge/Field-Healthcare%20Analytics-green?style=flat-square)
![Data](https://img.shields.io/badge/Data-Synthetic-lightgrey?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-orange?style=flat-square)

A SQL portfolio project that analyzes emergency department wait times, physician workload, repeat-visit patterns, and payer mix across a simulated multi-specialty hospital. Every analysis pairs the SQL with the business question it answers and the action hospital leadership should take.

> [!NOTE]
> All patients, doctors, encounters, charges, and reimbursement figures are **synthetic**. No real patient data is used. Charges and expected reimbursement are modeled values (see [Methodology](#-methodology--definitions)), so the findings demonstrate analytical method rather than describe a real hospital.

| | |
|---|---|
| **Prepared by** | Anicet Baraka Ciza, Data Analyst ([@iamanicet](https://github.com/iamanicet)) |
| **Database** | MySQL 8.0.16+ (`hospital_analytics`) |
| **Scope** | 246 encounters, 60 patients, 10 doctors, 4 departments (Emergency, Cardiology, Orthopedics, General Medicine) |
| **Period** | 1 January to 30 June 2025 |

## 📑 Contents

1. [Project Overview](#-project-overview)
2. [Executive Summary](#-executive-summary)
3. [Headline Metrics](#-headline-metrics)
4. [Detailed Findings](#-detailed-findings)
5. [Recommendations & Action Plan](#-recommendations--action-plan)
6. [Database Architecture & Schema](#database-architecture--schema)
7. [Repository Structure](#-repository-structure)
8. [Getting Started](#-getting-started)
9. [Analyses](#-analyses)
10. [Methodology & Definitions](#-methodology--definitions)
11. [Limitations](#limitations)

---

## 📌 Project Overview

Hospital administrators have to balance patient care quality with financial sustainability. This repository covers the full workflow: relational schema design with strict data-integrity rules, a reproducible synthetic dataset, and analytical queries built on CTEs, window functions, conditional aggregation, and multi-table joins.

### Key Objectives
- **Emergency Throughput**: Split ED waits into door-to-triage and triage-to-provider time, flag target breaches, and track patients who leave without being seen (LWBS).
- **Resource Management**: Audit doctor workload across active staff and identify high-utilizer patients and 30-day returns.
- **Financial Exposure**: Break down encounters, charges, and expected reimbursement by payer type (Medicare, Medicaid, Commercial, Self-Pay).

---

## 📌 Executive Summary

This project evaluates emergency department (ED) flow, physician workload, patient return patterns, and payer-driven financial exposure using relational SQL analytics. Four issues stand out for clinical and executive leadership:

1. **The ED has a post-triage bottleneck that worsens at the evening peak.** Triage takes about 10 minutes, but patients then wait about 38 more minutes for a provider. 17 of 71 patients seen waited over an hour, and 5 patients left without being seen.
2. **Physician workload is badly uneven.** One orthopedic surgeon handled 50 encounters while a second, active orthopedic surgeon handled none.
3. **A small group of patients drives a large share of activity.** 10 patients account for 39% of all encounters, and 43% of ED visits came within 30 days of a prior discharge.
4. **Payer mix drives reimbursement more than volume does.** Self-Pay and Medicaid represent 31% of billed charges but only 19% of expected reimbursement.

---

## 📊 Headline Metrics

| Metric | Value |
|---|---|
| Total encounters | **246** (Completed 234, Cancelled 8, In Progress 4) |
| ED visits | **76** (31% of encounters) |
| Average ED door-to-provider time | **48.3 min** (door-to-triage 10.4 + triage-to-provider 38.3) |
| ED patients waiting over 60 min | **17 of 71 seen** (23.9%), maximum **119 min** |
| ED Left Without Being Seen (LWBS) | **5** (6.6% of ED visits) |
| Gross billed charges | **$2,326,341.67** (242 encounters; 4 in-progress excluded) |
| Expected reimbursement | **$1,089,163.36** (46.8% of charges) |
| Active physicians | **9** of 10 on the roster |
| Average inpatient length of stay | **4.9 days** (54 completed stays) |
| High-utilizer patients (8+ encounters) | **10** patients, 39% of encounters |

---

## 🔍 Detailed Findings

### 1. Emergency Department Throughput & Acuity

**Peak demand is 17:00 to 18:59.** Those two hours account for 21 of 76 ED arrivals (28%). Among patients seen, the average door-to-provider time is **58.3 min** for arrivals between 16:00 and 20:59, compared with **41.3 min** at other times.

**The delay is after triage, not at triage.** About 79% of the average wait (38.3 of 48.3 minutes) happens between triage and provider start.

| Triage level | ED visits | Seen by provider | Avg door-to-provider (min) | Max (min) | Over 60 min |
|---|---|---|---|---|---|
| 1 (most urgent) | 7 | 7 | 14.3 | 18 | 0 |
| 2 | 19 | 19 | 27.3 | 45 | 0 |
| 3 | 22 | 21 | 52.2 | 85 | 3 |
| 4 | 20 | 17 | 65.9 | 119 | 8 |
| 5 (least urgent) | 8 | 7 | 84.1 | 113 | 6 |

**By arrival mode:**

| Arrival mode | ED visits | Avg door-to-triage (min) | Avg triage-to-provider (min) | Avg door-to-provider (min) | Over 60 min | LWBS |
|---|---|---|---|---|---|---|
| Walk-in | 52 | 12.0 | 44.5 | 56.0 | 15 | 5 |
| Ambulance | 21 | 6.8 | 23.1 | 30.0 | 1 | 0 |
| Referral | 3 | 8.3 | 46.0 | 54.3 | 1 | 0 |

**What this shows:**
- The system prioritizes correctly in direction: wait time rises as acuity falls, and no level 1 or 2 patient waited over an hour.
- Even so, level 2 patients average 27 minutes to a provider, which is well above the 10-minute standard commonly used for high-acuity cases. The right benchmark is for the hospital to confirm.
- Long waits are concentrated in levels 4 and 5 (14 of the 17 waits over 60 minutes), but 3 level 3 patients also waited over an hour, with a maximum of 85 minutes. Level 3 is where delay carries the most clinical risk.
- **LWBS:** all 5 patients who left were walk-ins (9.6% of walk-in visits), and 4 of the 5 were level 4 or 5. These encounters generated only **$750** in charges. The potential revenue forgone is not quantified here, and the larger concern is patient safety.

### 2. Financial Performance & Payer Distribution

| Department | Encounters | Gross charges | Expected reimbursement |
|---|---|---|---|
| Cardiology | 69 | $662,559 | $302,083 |
| Emergency | 76 | $582,599 | $242,251 |
| Orthopedics | 50 | $568,083 | $290,879 |
| General Medicine | 51 | $513,101 | $253,950 |

Cardiology produces the most billed revenue. Emergency has the most encounters but the lowest expected reimbursement. By encounter type, **inpatient stays generate 67% of all charges** ($1.56M), while outpatient visits generate 1.4%.

| Payer | Encounters | Gross charges | Expected reimbursement | Reimbursement rate |
|---|---|---|---|---|
| Commercial | 69 | $807,976 | $517,740 | 64.1% |
| Medicare | 88 | $741,481 | $334,222 | 45.1% |
| Medicaid | 59 | $537,122 | $188,688 | 35.1% |
| Self-Pay | 24 | $187,875 | $22,269 | 11.9% |
| Other | 6 | $51,888 | $26,245 | 50.6% |

- Commercial payers are 35% of charges but 48% of expected reimbursement.
- Medicare is the largest payer by volume (36% of encounters) and reimburses at under half of billed charges.
- Self-Pay patients are 8% of charges but only 2% of expected reimbursement.
- All 8 cancelled encounters carry $0 in charges, so cancellations caused no direct billing loss. Their cost is the unused clinic slot.

### 3. Physician Workload & Utilization

| Doctor | Specialty | Status | Encounters |
|---|---|---|---|
| Dr. Wilson | Orthopedic Surgery | Active | **50** |
| Dr. Shah | Cardiology | Active | 42 |
| Dr. Kim | Cardiology | Active | 27 |
| Dr. Carter | Emergency Medicine | Active | 26 |
| Dr. Mensah | Internal Medicine | Active | 26 |
| Dr. Thompson | Internal Medicine | Active | 25 |
| Dr. Adams | Emergency Medicine | Active | 22 |
| Dr. Nguyen | Emergency Medicine | Active (joined April) | 12 |
| Dr. Alvarez | Emergency Medicine | **Inactive** (left end of March) | 11 |
| Dr. Lee | Orthopedic Surgery | Active | **0** |

- The roster shows 9 active physicians, but the load is not shared. Orthopedics has two active surgeons on paper, yet one carries every encounter.
- Cardiology's two physicians handle 69 encounters between them, and Dr. Shah carries 61% of that.
- 5 ED encounters have no assigned doctor, and all 5 are the LWBS cases.

### 4. Inpatient Care, Returns & High Utilizers

**Length of stay** (admission to discharge, 54 completed inpatient stays) averages **4.9 days**. General Medicine runs longest at 6.0 days, versus 4.8 for Orthopedics and 4.4 for Cardiology. The longest single stay was 10.4 days. Stays ending in transfer average 5.1 days, not meaningfully different from home discharges (4.9 days).

**Repeat utilization:**

| Measure | Result |
|---|---|
| Patients with 3 or more encounters | 38 of 60 |
| Patients with 5 or more encounters | 19 of 60 |
| **High utilizers (8 or more encounters)** | **10 patients** (8 to 11 encounters each) |
| Share of all non-cancelled encounters from those 10 patients | **39%** (92 of 238) |
| ED visits within 30 days of a prior discharge | **33 of 76** (43%) |
| Patients with 3 or more ED visits | 10 |

---

## 🎯 Recommendations & Action Plan

| Priority | Action | Evidence | Suggested KPI |
|---|---|---|---|
| **1** | **Rebalance orthopedic scheduling.** Route new patients to Dr. Lee and review referral and booking rules that send everything to Dr. Wilson. | 50 vs 0 encounters between two active surgeons | Neither surgeon above 60% of department volume |
| **2** | **Shift ED staffing to cover the evening peak.** Move physician and nursing start times earlier (about 15:00 to 16:00) and add provider coverage through 21:00. | 17:00 to 18:59 is 28% of arrivals; peak-window wait is 58 vs 41 min | Peak-window door-to-provider under 45 min |
| **3** | **Start provider-in-triage and a fast-track lane for levels 4 and 5.** Treat low-acuity patients in parallel so they do not queue behind sicker patients. | 79% of wait is after triage; 14 of 17 long waits were levels 4 and 5 | Over-60-minute waits cut by half |
| **4** | **Treat LWBS as a tracked safety event.** Reassess anyone waiting over 60 minutes after triage, and review every LWBS case within 24 hours. | 5 LWBS, 4 of them level 4 or 5, all walk-ins | LWBS rate under 3% |
| **5** | **Set explicit acuity-based wait targets** for levels 2 and 3, and report them weekly. | Level 2 averages 27 min; level 3 reaches 85 min | Level 2 under 15 min; level 3 under 45 min |
| **6** | **Enroll high utilizers in proactive care management** (outpatient follow-up, care coordination, post-discharge calls). | 10 patients account for 39% of encounters; 43% of ED visits are 30-day returns | 30-day ED return rate reduced by 20% |
| **7** | **Strengthen front-end financial screening.** Offer coverage-enrollment and financial counseling at registration, particularly for Self-Pay and Medicaid-eligible patients. | Self-Pay: 8% of charges, 2% of expected reimbursement | Higher share of Self-Pay encounters with a screening on file |
| **8** | **Review inpatient discharge planning in General Medicine.** | Longest average stay at 6.0 days | Average stay in line with other departments |

---

## Database Architecture & Schema

Four normalized tables in the `hospital_analytics` database:

| Table | Purpose |
|---|---|
| `Patients` | Demographics, city, and date of birth |
| `Departments` | Service lines (Emergency, Cardiology, Orthopedics, General Medicine) |
| `Doctors` | Roster, specialty, department, and active status |
| `Encounters` | Visits with arrival, triage, provider-start, admission, and discharge timestamps; arrival mode; payer type; discharge disposition; ESI-style triage level (1 to 5); charges and expected reimbursement |

**Data-integrity features:** `ENUM` fields for controlled vocabularies, foreign keys with explicit `ON DELETE` rules, and `CHECK` constraints that reject impossible timelines (for example, triage before arrival, or discharge before admission).

### Dataset at a Glance (after running both setup scripts)

| Item | Count |
|---|---|
| Patients | 60 |
| Doctors | 10 (9 active, 1 inactive) |
| Encounters | 246 (Jan to Jun 2025) |
| Encounter types | Outpatient 82, Emergency 76, Inpatient 57, Observation 31 |
| Encounter status | Completed 234, Cancelled 8, In Progress 4 |

The data deliberately includes repeat and high-utilization patients, 30-day returns, patients who left without being seen, cancelled and in-progress encounters, an inactive doctor, and an active doctor with no encounters. These cases make the analytical queries meaningful.

---

## 📁 Repository Structure

```text
├── 01_hospital_setup.sql            # Database creation, schema DDL, and base seed data
├── 01b_hospital_seed_extended.sql   # Schema extensions (acuity, charges) and extended synthetic records
├── 02_hospital_analysis.sql         # Analytical queries, each with business context
├── LICENSE                          # MIT License
└── README.md                        # Project documentation and findings
```

---

## 🚀 Getting Started

**Requirements:** MySQL 8.0.16 or later (needed for enforced `CHECK` constraints) and MySQL Workbench or the `mysql` CLI.

Run the scripts in this order:

```sql
SOURCE 01_hospital_setup.sql;           -- creates the database and base data (drops and recreates the four tables)
SOURCE 01b_hospital_seed_extended.sql;  -- run ONCE after the base script
SOURCE 02_hospital_analysis.sql;        -- run queries top to bottom
```

In MySQL Workbench, open each file and execute it with the lightning-bolt button instead of using `SOURCE`.

> To reset everything, re-run `01_hospital_setup.sql` first, then `01b_hospital_seed_extended.sql`.

---

## 📊 Analyses

| # | Analysis | Business question |
|---|---|---|
| 1 | Department Encounter Volume & Operational Mix | Which departments carry the most volume, and in what encounter and arrival mix? |
| 2 | ED Wait Times & Triage Efficiency | Where do ED patients wait longest, and is the delay at triage or at provider start? |
| 3 | Physician Workload & Utilization | How evenly is patient volume spread across active doctors and specialties? |
| 4 | Patient Return / High-Utilization Analysis | Which patients return most often, and which returns happen within 30 days? |
| 5 | Payer Mix & Operational Risk | How do volume, charges, and expected reimbursement split by payer? |

### SQL Techniques Demonstrated
- Common Table Expressions (CTEs) for step-by-step logic
- Window functions (`ROW_NUMBER`, `LAG`, running totals)
- Date and time arithmetic with `TIMESTAMPDIFF`
- Conditional aggregation and `LEFT JOIN` logic for zero-volume cases
- Constraint-driven schema design (`ENUM`, `CHECK`, foreign keys)

---

## 🧪 Methodology & Definitions

- **Door-to-triage** is arrival to triage time. **Triage-to-provider** is triage to provider start. **Door-to-provider** is arrival to provider start. All are in minutes and calculated with `TIMESTAMPDIFF`.
- **Wait statistics** cover patients with a recorded provider start time (71 of 76 ED visits). LWBS patients are counted separately.
- **Peak window** is 16:00 to 20:59 arrival time. Peak hours are the arrival hours with the most ED visits.
- **Gross charges and expected reimbursement** are synthetic. Expected reimbursement applies a payer-based rate to each encounter's charges. In-progress encounters have no charges yet and are excluded.
- **Length of stay** is `admission_datetime` to `discharge_datetime` for completed inpatient encounters.
- **High utilizer** means a patient with 8 or more non-cancelled encounters in the six-month period.
- **30-day ED return** means an ED visit that occurs within 30 days after the discharge of any earlier completed encounter for the same patient.
- **Triage level** follows the ESI scale (1 most urgent, 5 least urgent). Wait targets quoted in the recommendations are illustrative and should be replaced with the hospital's own standards.

## Limitations

- The data is synthetic and small (246 encounters over six months), so percentages move noticeably with a few records.
- Four departments and one hospital site limit generalization.
- Charges are not tied to actual billing codes, and the reimbursement rates are assumptions.
- ED length-of-stay and boarding time are not analyzed here.
- There is no staffing-hours data, so workload is measured by encounter count and not by utilization of scheduled time.

---

## 👤 Author

Built by **Anicet Baraka Ciza** ([@iamanicet](https://github.com/iamanicet)) as part of a data analytics portfolio.
