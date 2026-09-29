/* ============================================================
   05 - STATISTICAL ANALYSIS
   Medical Appointment No-Show Analysis

   Purpose:
   Evaluate statistical association between selected factors
   and appointment no-show outcome.

   Statistical method:
   Chi-Square Test of Independence

   Effect size:
   Phi / Cramer's V equivalent for 2 x k tables

   Important:
   Statistical association does NOT imply causation.
   ============================================================ */


/* ============================================================
   ANALYSIS 34
   SMS STATUS VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (

    SELECT
        sms_status,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        COUNT(*) AS total_n

    FROM vw_tableau_no_show

    WHERE sms_status IN ('No SMS', 'SMS Received')

    GROUP BY sms_status

),

totals AS (

    SELECT
        SUM(attended) AS total_attended,
        SUM(no_show) AS total_no_show,
        SUM(total_n) AS total_n
    FROM observed

),

expected AS (

    SELECT
        o.sms_status,

        o.attended AS observed_attended,

        o.no_show AS observed_no_show,

        (o.total_n * 1.0 * t.total_attended / t.total_n)
            AS expected_attended,

        (o.total_n * 1.0 * t.total_no_show / t.total_n)
            AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        SUM(
            POWER(
                observed_attended - expected_attended,
                2
            ) / expected_attended

            +

            POWER(
                observed_no_show - expected_no_show,
                2
            ) / expected_no_show
        ) AS chi_square,

        (SELECT total_n FROM totals) AS total_n

    FROM expected

)

SELECT

    'SMS vs No-Show' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(chi_square / total_n),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 10.828
            THEN '< 0.001'

        WHEN chi_square >= 6.635
            THEN '< 0.01'

        WHEN chi_square >= 3.841
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM chi_calc;



/* ============================================================
   ANALYSIS 35
   WAITING TIME VS NO-SHOW CONTRIBUTION

   Descriptive analysis:
   - No-show rate
   - Contribution to total no-shows
   ============================================================ */

WITH grouped AS (

    SELECT

        waiting_group,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show

    FROM vw_tableau_no_show

    GROUP BY waiting_group

),

total AS (

    SELECT
        SUM(no_show) AS total_no_show
    FROM grouped

)

SELECT

    g.waiting_group,

    g.total_appointments,

    g.attended,

    g.no_show,

    ROUND(
        g.no_show * 100.0 / g.total_appointments,
        2
    ) AS no_show_rate,

    ROUND(
        g.no_show * 100.0 / t.total_no_show,
        2
    ) AS no_show_contribution_pct

FROM grouped g

CROSS JOIN total t

ORDER BY

    CASE g.waiting_group

        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7

    END;



/* ============================================================
   ANALYSIS 36
   WAITING TIME VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (

    SELECT

        waiting_group,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        COUNT(*) AS total_n

    FROM vw_tableau_no_show

    GROUP BY waiting_group

),

totals AS (

    SELECT

        SUM(attended) AS total_attended,

        SUM(no_show) AS total_no_show,

        SUM(total_n) AS total_n

    FROM observed

),

expected AS (

    SELECT

        o.waiting_group,

        o.attended AS observed_attended,

        o.no_show AS observed_no_show,

        (
            o.total_n
            * t.total_attended
            / t.total_n
        ) AS expected_attended,

        (
            o.total_n
            * t.total_no_show
            / t.total_n
        ) AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        SUM(

            POWER(
                observed_attended - expected_attended,
                2
            ) / expected_attended

            +

            POWER(
                observed_no_show - expected_no_show,
                2
            ) / expected_no_show

        ) AS chi_square,

        MAX(total_n) AS total_n

    FROM (

        SELECT
            e.*,
            t.total_n

        FROM expected e

        CROSS JOIN totals t

    ) x

)

SELECT

    'Waiting Time vs No-Show' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    6 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(
            chi_square / total_n
        ),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 22.458
            THEN '< 0.001'

        WHEN chi_square >= 16.812
            THEN '< 0.01'

        WHEN chi_square >= 12.592
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM chi_calc;



/* ============================================================
   ANALYSIS 37
   SCHOLARSHIP VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (

    SELECT

        scholarship_status,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        COUNT(*) AS total_n

    FROM vw_tableau_no_show

    GROUP BY scholarship_status

),

totals AS (

    SELECT

        SUM(attended) AS total_attended,

        SUM(no_show) AS total_no_show,

        SUM(total_n) AS total_n

    FROM observed

),

expected AS (

    SELECT

        o.scholarship_status,

        o.attended AS observed_attended,

        o.no_show AS observed_no_show,

        (
            o.total_n
            * t.total_attended
            / t.total_n
        ) AS expected_attended,

        (
            o.total_n
            * t.total_no_show
            / t.total_n
        ) AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        SUM(

            POWER(
                observed_attended - expected_attended,
                2
            ) / expected_attended

            +

            POWER(
                observed_no_show - expected_no_show,
                2
            ) / expected_no_show

        ) AS chi_square,

        (
            SELECT total_n
            FROM totals
        ) AS total_n

    FROM expected

)

SELECT

    'Scholarship vs No-Show' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(
            chi_square / total_n
        ),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 10.828
            THEN '< 0.001'

        WHEN chi_square >= 6.635
            THEN '< 0.01'

        WHEN chi_square >= 3.841
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM chi_calc;



/* ============================================================
   ANALYSIS 38
   GENDER VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (

    SELECT

        gender_status,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        COUNT(*) AS total_n

    FROM vw_tableau_no_show

    WHERE gender_status IN ('Female', 'Male')

    GROUP BY gender_status

),

totals AS (

    SELECT

        SUM(attended) AS total_attended,

        SUM(no_show) AS total_no_show,

        SUM(total_n) AS total_n

    FROM observed

),

expected AS (

    SELECT

        o.gender_status,

        o.attended AS observed_attended,

        o.no_show AS observed_no_show,

        (
            o.total_n
            * 1.0
            * t.total_attended
            / t.total_n
        ) AS expected_attended,

        (
            o.total_n
            * 1.0
            * t.total_no_show
            / t.total_n
        ) AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        SUM(

            POWER(
                observed_attended - expected_attended,
                2
            ) / expected_attended

            +

            POWER(
                observed_no_show - expected_no_show,
                2
            ) / expected_no_show

        ) AS chi_square,

        (SELECT total_n FROM totals) AS total_n

    FROM expected

)

SELECT

    'Gender vs No-Show' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(
            chi_square / total_n
        ),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 10.828
            THEN '< 0.001'

        WHEN chi_square >= 6.635
            THEN '< 0.01'

        WHEN chi_square >= 3.841
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM chi_calc;



/* ============================================================
   ANALYSIS 39
   AGE GROUP VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (

    SELECT

        age_group,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show

    FROM vw_tableau_no_show

    GROUP BY age_group

),

totals AS (

    SELECT

        SUM(attended) AS total_attended,

        SUM(no_show) AS total_no_show,

        SUM(attended + no_show) AS total_n

    FROM observed

),

expected AS (

    SELECT

        o.age_group,

        o.attended,

        o.no_show,

        ROUND(
            (
                o.attended + o.no_show
            )
            * t.total_attended
            / t.total_n,
            6
        ) AS expected_attended,

        ROUND(
            (
                o.attended + o.no_show
            )
            * t.total_no_show
            / t.total_n,
            6
        ) AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        POWER(
            attended - expected_attended,
            2
        )
        / expected_attended

        +

        POWER(
            no_show - expected_no_show,
            2
        )
        / expected_no_show

        AS chi_component

    FROM expected

),

final_calc AS (

    SELECT

        SUM(chi_component) AS chi_square,

        (
            SELECT total_n
            FROM totals
        ) AS total_n

    FROM chi_calc

)

SELECT

    'Age Group vs No-Show' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    7 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(
            chi_square / total_n
        ),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 24.322
            THEN '< 0.001'

        WHEN chi_square >= 18.475
            THEN '< 0.01'

        WHEN chi_square >= 14.067
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM final_calc;



/* ============================================================
   ANALYSIS 40
   SCHOLARSHIP VS NO-SHOW
   Chi-Square Test of Independence

   This repeats the scholarship statistical test from
   Analysis 37 as defined in the original analysis sequence.
   ============================================================ */

WITH observed AS (

    SELECT

        scholarship_status,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show

    FROM vw_tableau_no_show

    GROUP BY scholarship_status

),

totals AS (

    SELECT

        SUM(attended) AS total_attended,

        SUM(no_show) AS total_no_show,

        SUM(attended + no_show) AS total_n

    FROM observed

),

expected AS (

    SELECT

        o.scholarship_status,

        o.attended,

        o.no_show,

        ROUND(
            (
                o.attended + o.no_show
            )
            * t.total_attended
            / t.total_n,
            6
        ) AS expected_attended,

        ROUND(
            (
                o.attended + o.no_show
            )
            * t.total_no_show
            / t.total_n,
            6
        ) AS expected_no_show

    FROM observed o

    CROSS JOIN totals t

),

chi_calc AS (

    SELECT

        POWER(
            attended - expected_attended,
            2
        )
        / expected_attended

        +

        POWER(
            no_show - expected_no_show,
            2
        )
        / expected_no_show

        AS chi_component

    FROM expected

),

final_calc AS (

    SELECT

        SUM(chi_component) AS chi_square,

        (
            SELECT total_n
            FROM totals
        ) AS total_n

    FROM chi_calc

)

SELECT

    'Scholarship vs No-Show (Analysis 40)' AS analysis,

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

    total_n,

    ROUND(
        SQRT(
            chi_square / total_n
        ),
        4
    ) AS phi_effect_size,

    CASE

        WHEN chi_square >= 10.828
            THEN '< 0.001'

        WHEN chi_square >= 6.635
            THEN '< 0.01'

        WHEN chi_square >= 3.841
            THEN '< 0.05'

        ELSE '>= 0.05'

    END AS p_value_interpretation

FROM final_calc;