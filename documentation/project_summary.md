# Project Summary

## Medical Appointment No-Show Analysis

### 1. Project overview

This project analyzes patterns of missed medical appointments using a complete analytics workflow from raw data preparation to interactive dashboard delivery.

The project focuses on understanding how appointment timing, patient demographics, SMS reminder status, scholarship status, health-condition indicators, weekdays, and neighbourhoods relate to appointment attendance.

### 2. Business problem

Missed appointments can reduce appointment availability and create operational inefficiencies. A descriptive analysis can help identify recurring patterns in appointment no-shows and highlight segments that deserve closer operational attention.

This project therefore asks:

- How large is the overall no-show problem?
- Which appointment and patient characteristics show different no-show rates?
- How does waiting time relate to missed appointments?
- How do SMS reminders behave across waiting-time segments?
- Are observed differences supported by statistical association tests?
- How can these results be communicated through an interactive dashboard?

### 3. Objectives

1. Measure overall attendance and no-show rates.
2. Analyze no-show patterns by waiting time, age, gender, SMS, scholarship, health conditions, weekday, and neighbourhood.
3. Compare segments against the overall 20.19% no-show baseline.
4. Explore multi-factor interactions such as waiting time × SMS and waiting time × age.
5. Validate row-level and aggregate results before visualization.
6. Apply chi-square tests of independence to selected categorical factors.
7. Build a portfolio-ready Tableau dashboard with interactive filters and drill-downs.

### 4. Dataset

The project uses the **Medical Appointment No Shows** dataset.

The validated analytical dataset contains:

- **110,527 appointments**
- **88,208 attended appointments**
- **22,319 no-shows**
- **20.19% overall no-show rate**

### 5. Data grain

The final analytical dataset preserves the appointment-level grain:

> **1 row = 1 appointment**

This allows the project to reconcile total appointments with attended and no-show outcomes throughout the SQL and Tableau workflow.

### 6. Technology stack

| Technology | Role |
|---|---|
| Python / Jupyter Notebook | Data cleaning and data-quality checks |
| MySQL | Transformation, aggregation, validation, and statistical analysis |
| Tableau Public | Interactive visualization and dashboard delivery |
| Git / GitHub | Version control and portfolio presentation |

### 7. Analytical workflow

```text
Raw dataset
    ↓
Python cleaning & quality checks
    ↓
Processed dataset
    ↓
MySQL setup & transformation
    ↓
Exploratory SQL analysis
    ↓
Final analytical view
    ↓
Validation & reconciliation
    ↓
Statistical analysis
    ↓
Insight analysis
    ↓
Tableau Public dashboards
    ↓
GitHub portfolio
```

### 8. Data preparation

The cleaning notebook covers:

- consistent column naming,
- date conversion,
- missing-value inspection,
- duplicate checking,
- age validation,
- calculation of `waiting_days`,
- creation of `age_group`,
- creation of `no_show_binary`,
- waiting-time validation,
- final dataset export.

Negative waiting-time values are explicitly flagged as a data-quality issue rather than being silently interpreted as zero.

### 9. SQL analysis

The SQL workflow is organized into six stages:

```text
01_setup.sql
02_analysis.sql
03_final_view.sql
04_validation.sql
05_statistical_analysis.sql
06_insight_analysis.sql
```

Coverage includes:

- overall outcome distribution,
- gender and age analysis,
- waiting-time segmentation,
- SMS analysis,
- scholarship analysis,
- health-condition analysis,
- neighbourhood analysis,
- interaction analysis,
- no-show contribution analysis,
- chi-square testing,
- effect-size calculations,
- Tableau-oriented insight queries.

### 10. Validation

The project performs reconciliation checks so that:

```text
Attended + No-show = Total appointments
```

The validated totals are:

```text
88,208 attended
+22,319 no-show
----------------
110,527 appointments
```

The resulting no-show rate is **20.19%**.

### 11. Tableau dashboards

#### Dashboard 1 — Overview

Provides the high-level picture:

- total appointments,
- attended appointments,
- no-show appointments,
- overall no-show rate,
- no-show rate by age group,
- SMS reminder distribution,
- no-show rate by waiting time,
- no-show rate by appointment day.

#### Dashboard 2 — Factor Analysis

Focuses on the main factors associated with different no-show patterns:

- overall no-show baseline,
- age-group comparison,
- health-condition comparison,
- no-show contribution by waiting time,
- appointment volume vs no-show rate by segment.

#### Dashboard 3 — Detailed Analysis

Provides detailed patterns and interactions:

- monthly no-show trend,
- appointment-day comparison,
- gender comparison,
- scholarship comparison,
- SMS comparison,
- age-group detail,
- neighbourhood comparison,
- waiting time × SMS heatmap.

### 12. Main findings

The project identifies several descriptive patterns:

- Overall no-show rate is **20.19%**.
- Same-day appointments have a much lower no-show rate (**4.77%**) than longer waiting-time groups.
- Waiting groups between 1 and 60 days contribute a substantial share of all no-shows.
- No-show rates vary across age groups, with the 13-18 and 19-35 groups above the overall baseline.
- SMS status differs meaningfully in the observed data, but this is an association rather than evidence of causation.
- Health-condition comparisons are relatively close to the overall baseline compared with waiting-time differences.
- The dashboard combines descriptive segmentation with statistical testing rather than relying on a single chart.

### 13. Limitations

- The analysis is observational and descriptive; it does not establish causality.
- SMS receipt may be related to other operational or patient-level factors.
- Neighbourhood comparisons can be sensitive to sample size and should not be interpreted as causal socioeconomic explanations.
- Invalid waiting-time records are retained as a data-quality category in the analytical workflow rather than being silently recoded.
- The dashboard is intended for exploratory analysis and portfolio demonstration, not direct clinical decision-making.

### 14. Reproducibility

A reviewer can follow the repository structure to reproduce the workflow:

```text
notebooks/
    01_Medical_Appointment_Data_Cleaning.ipynb

sql/
    01_setup.sql
    02_analysis.sql
    03_final_view.sql
    04_validation.sql
    05_statistical_analysis.sql
    06_insight_analysis.sql

data/
    Raw.csv
    Processed.csv
    Final.csv

dashboard/
    medical_appointment_no_show.twb
    tableau_public_link.txt

images/
    01_overview.png
    02_factor_analysis.png
    03_detailed_analysis.png
```

### 15. Portfolio positioning

This project demonstrates a practical end-to-end Data Analyst workflow:

**Data Cleaning → SQL Analytics → Validation → Statistical Testing → Insight Generation → Tableau Dashboard → GitHub Documentation**

The repository is structured so that the analytical reasoning, code, visual output, and documentation can be reviewed independently.

### 16. Documentation set

- [`data_dictionary.md`](data_dictionary.md) — analytical field definitions and transformation rules.
- [`key_insights.md`](key_insights.md) — validated findings and interpretation notes.
- [`project_summary.md`](project_summary.md) — end-to-end project overview and methodology.
