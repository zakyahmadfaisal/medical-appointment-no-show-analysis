# Data Dictionary

## Medical Appointment No-Show Analysis

This document describes the main fields used in the cleaned and Tableau-ready analytical dataset.

### Dataset grain

- **Grain:** 1 row = 1 appointment
- **Final validated rows:** 110,527
- **Attended:** 88,208
- **No-shows:** 22,319
- **Overall no-show rate:** 20.19%

The project uses a layered workflow: raw dataset → Python cleaning → MySQL transformation/validation → Tableau-ready analytical view/export.

## 1. Source / patient and appointment fields

| Field | Type | Description | Values / notes |
|---|---|---|---|
| `patient_id` | Integer | Patient identifier from the source dataset. | Identifier; not used as a prediction target. |
| `appointment_id` | Integer | Appointment identifier. | Appointment-level key used for reconciliation. |
| `gender` | Categorical | Original gender code. | `F`, `M`. |
| `scheduled_day` | Datetime | Date/time when the appointment was scheduled. | Used with `appointment_day` to derive waiting time. |
| `appointment_day` | Datetime | Appointment date. | Used for time-based analysis. |
| `age` | Integer | Patient age. | Invalid or unavailable values are handled during cleaning. |
| `neighbourhood` | Categorical | Patient neighbourhood. | Used for neighbourhood-level no-show analysis. |
| `scholarship` | Binary | Scholarship indicator from the source data. | `0` = No Scholarship; `1` = Scholarship. |
| `hypertension` | Binary | Hypertension indicator. | `0` = No Hypertension; `1` = Hypertension. |
| `diabetes` | Binary | Diabetes indicator. | `0` = No Diabetes; `1` = Diabetes. |
| `alcoholism` | Binary | Alcoholism indicator. | `0` = No Alcoholism; `1` = Alcoholism. |
| `handicap` | Integer / categorical | Handicap level indicator from the source data. | Preserved from source; dashboard uses a condition/status interpretation. |
| `sms_received` | Binary | Whether an SMS reminder was recorded as received. | `0` = No SMS; `1` = SMS Received. |
| `no_show` | Categorical | Original appointment outcome. | `No` = attended; `Yes` = no-show. |

## 2. Derived analytical fields

| Field | Type | Description | Derivation / values |
|---|---|---|---|
| `age_group` | Categorical | Age bucket used for comparison. | `0-12`, `13-18`, `19-35`, `36-50`, `51-65`, `66-75`, `76+`, `Unknown`. |
| `waiting_days` | Integer | Difference in days between appointment and scheduled dates. | `DATEDIFF(appointment_day, scheduled_day)`. |
| `waiting_group` | Categorical | Waiting-time bucket used in Tableau. | `Same Day`, `1-7 Days`, `8-14 Days`, `15-30 Days`, `31-60 Days`, `61+ Days`, `Unknown`. |
| `gender_status` | Categorical | Readable gender category. | `Female`, `Male`, `Unknown`. |
| `sms_status` | Categorical | Readable SMS category. | `No SMS`, `SMS Received`, `Unknown`. |
| `scholarship_status` | Categorical | Readable scholarship category. | `No Scholarship`, `Scholarship`, `Unknown`. |
| `no_show_binary` | Binary | Numeric appointment outcome for analysis. | `0` = Attended; `1` = No-Show. |
| `no_show_status` | Categorical | Readable appointment outcome. | `Attended`, `No-Show`, `Unknown`. |
| `appointment_year` | Integer | Year extracted from appointment date. | `YEAR(appointment_day)`. |
| `appointment_month` | Integer | Numeric month extracted from appointment date. | `MONTH(appointment_day)`. |
| `appointment_month_name` | Categorical | Month name used in Tableau trend analysis. | `MONTHNAME(appointment_day)`. |
| `appointment_day_number` | Integer | Day-of-week number. | `DAYOFWEEK(appointment_day)`. |
| `appointment_day_name` | Categorical | Day-of-week name. | `DAYNAME(appointment_day)`. |

## 3. Health-condition status fields

The final analytical workflow also uses readable status fields for health-condition comparisons:

| Field | Type | Description |
|---|---|---|
| `hypertension_status` | Categorical | `Hypertension` vs `No Hypertension`. |
| `diabetes_status` | Categorical | `Diabetes` vs `No Diabetes`. |
| `alcoholism_status` | Categorical | `Alcoholism` vs `No Alcoholism`. |
| `handicap_status` | Categorical | Readable handicap condition/status used in dashboard comparison. |

## 4. Waiting-time classification

The project uses the following chronological buckets:

| Waiting group | Rule |
|---|---|
| `Same Day` | `waiting_days = 0` |
| `1-7 Days` | `waiting_days` from 1 to 7 |
| `8-14 Days` | `waiting_days` from 8 to 14 |
| `15-30 Days` | `waiting_days` from 15 to 30 |
| `31-60 Days` | `waiting_days` from 31 to 60 |
| `61+ Days` | `waiting_days >= 61` |
| `Unknown` | Invalid, negative, or otherwise unclassified waiting-time values |

During notebook cleaning, invalid negative waiting values are explicitly flagged as a data-quality issue. In the final SQL/Tableau workflow, records are retained at appointment level and values outside the valid waiting-time ranges are represented by the `Unknown` category rather than silently being recoded to zero.

## 5. Outcome definitions

### Attended

An appointment with `no_show_binary = 0`.

### No-Show

An appointment with `no_show_binary = 1`.

### No-show rate

```text
No-show rate = No-show appointments / Total appointments × 100%
```

### No-show contribution

For waiting-time analysis, contribution represents the proportion of all no-show appointments contributed by a waiting-time group:

```text
No-show contribution = Group no-shows / Total no-shows × 100%
```

## 6. Data-quality notes

- The cleaning notebook checks column consistency, date parsing, missing values, duplicates, age validity, and waiting-time validity.
- Invalid negative waiting-time values are treated as a data-quality issue.
- The final analytical grain remains **1 row = 1 appointment**, allowing reconciliation of attended + no-show counts with total appointments.
- Neighbourhood analysis includes sample-size-aware SQL queries; one analysis explicitly applies a minimum of 500 appointments per neighbourhood.

## 7. Main analytical use

The fields above support three Tableau dashboards:

1. **Overview** — overall attendance, age, SMS, waiting time, and appointment-day patterns.
2. **Factor Analysis** — age, health conditions, waiting-time contribution, and segment analysis.
3. **Detailed Analysis** — monthly trend, weekday, gender, scholarship, SMS, age, neighbourhood, and waiting-time × SMS analysis.
