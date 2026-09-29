# Key Insights

## Medical Appointment No-Show Analysis

This document summarizes the main findings from the validated SQL analysis and Tableau dashboards. The findings are **descriptive**: observed differences and statistical associations should not be interpreted as proof of causation.

## 1. Overall outcome

The final validated analytical dataset contains **110,527 appointments**:

| Metric | Value |
|---|---:|
| Total appointments | 110,527 |
| Attended | 88,208 |
| No-show | 22,319 |
| Overall no-show rate | **20.19%** |

The 20.19% rate is used as the baseline/reference line across the dashboards.

## 2. Waiting time is one of the clearest segmentation dimensions

| Waiting Group | Appointments | No-Shows | No-Show Rate | No-Show Contribution |
|---|---:|---:|---:|---:|
| Same Day | 37,794 | 1,803 | 4.77% | 8.08% |
| 1-7 Days | 32,007 | 7,731 | 24.15% | 34.64% |
| 8-14 Days | 11,957 | 3,665 | 30.65% | 16.42% |
| 15-30 Days | 17,331 | 5,639 | 32.54% | 25.27% |
| 31-60 Days | 8,268 | 2,825 | 34.17% | 12.66% |
| 61+ Days | 2,088 | 595 | 28.50% | 2.67% |
| Unknown | 1,082 | 61 | 5.64% | 0.27% |

The descriptive pattern shows a substantially lower no-show rate for same-day appointments and higher rates across several longer waiting-time groups. Waiting groups also account for different shares of the total no-show volume, which is why the project uses both **no-show rate** and **no-show contribution**.

The `Unknown` waiting category is treated as a data-quality category. The project does not silently recode negative waiting values to zero.

## 3. SMS reminder status shows a measurable difference in the observed data

| SMS Status | Appointments | No-Shows | No-Show Rate |
|---|---:|---:|---:|
| No SMS | 75,045 | 12,535 | 16.70% |
| SMS Received | 35,482 | 9,784 | 27.57% |

The observed no-show rate is higher among appointments with recorded SMS receipt. This should **not** be interpreted as evidence that receiving an SMS causes no-shows to increase. SMS assignment may reflect other operational or patient-level conditions. The SQL workflow therefore includes both descriptive interaction analysis and a chi-square test of independence.

## 4. Age-group differences are visible

| Age Group | Appointments | No-Show Rate |
|---|---:|---:|
| 0-12 | 17,497 | 20.96% |
| 13-18 | 7,830 | 26.05% |
| 19-35 | 24,137 | 23.83% |
| 36-50 | 22,100 | 20.33% |
| 51-65 | 22,122 | 16.55% |
| 66-75 | 7,909 | 15.12% |
| 76+ | 5,385 | 16.10% |
| Unknown | 3,547 | 18.10% |

The largest observed rates are concentrated in the younger adult/teen groups, while several older groups are below the overall 20.19% baseline.

## 5. Health-condition comparisons are comparatively close to the overall baseline

| Health Condition | Condition | No Condition |
|---|---:|---:|
| Hypertension | 17.30% | 20.90% |
| Diabetes | 18.00% | 20.36% |
| Alcoholism | 20.15% | 20.19% |
| Handicap | 18.16% | 20.24% |

These comparisons are useful for segmentation but should not be interpreted as causal effects of the health conditions themselves.

## 6. Scholarship and gender differences are smaller

### Scholarship

- No Scholarship: **19.81%** no-show rate
- Scholarship: **23.74%** no-show rate

### Gender

- Female: **20.31%**
- Male: **19.97%**

The gender gap is small relative to the broader differences observed across waiting-time and age segments.

## 7. Appointment-day patterns

The validated detailed analysis reports these no-show rates:

| Appointment Day | No-Show Rate |
|---|---:|
| Monday | 20.65% |
| Tuesday | 20.09% |
| Wednesday | 19.69% |
| Thursday | 19.35% |
| Friday | 21.23% |
| Saturday | 23.08% |

Sunday is not present in the observed appointment data used in the dashboard.

## 8. Monthly pattern

The detailed dashboard covers three observed appointment months:

| Month | No-Show Rate |
|---|---:|
| April | 19.57% |
| May | 20.79% |
| June | 18.46% |

The monthly trend is relatively close to the overall baseline, but May is above and June is below the 20.19% reference.

## 9. Neighbourhood analysis

Neighbourhood-level no-show rates vary across locations. The SQL workflow includes a separate analysis with a **minimum of 500 appointments per neighbourhood** to reduce the influence of very small groups. The Detailed Analysis dashboard presents the top 10 neighbourhoods by no-show rate using the project’s validated Tableau dataset.

This is intentionally presented as a descriptive neighbourhood comparison rather than a causal or socioeconomic conclusion.

## 10. Waiting time × SMS interaction

The waiting-time × SMS heatmap shows that the observed no-show pattern changes across waiting-time groups and SMS status. This interaction view is more informative than reading SMS status alone because it places reminder status in the context of appointment lead time.

## 11. Statistical analysis

The project includes chi-square tests of independence for selected categorical factors and the no-show outcome, including:

- SMS status vs no-show
- Waiting time group vs no-show
- Scholarship vs no-show
- Gender vs no-show
- Age group vs no-show

Effect size is also considered where appropriate. The statistical workflow is implemented in `05_statistical_analysis.sql`.

The correct interpretation is **association**, not causation.

## 12. Portfolio-level takeaway

The strongest analytical story is the combination of:

1. a clear overall baseline (**20.19%**),
2. strong segmentation by waiting time,
3. meaningful age-group variation,
4. interaction analysis using waiting time × SMS,
5. statistical testing to complement descriptive charts,
6. and a reproducible SQL → Tableau workflow.

These elements demonstrate not only dashboard design, but also data preparation, validation, analytical reasoning, and communication of findings.
