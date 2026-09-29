/* ============================================================
   06 - INSIGHT ANALYSIS
   Medical Appointment No-Show Analysis

   Purpose:
   - Identify key descriptive patterns
   - Compare no-show rates against overall baseline
   - Identify high-risk and high-volume segments
   - Prepare insights for Tableau Dashboard 2

   Source:
   vw_tableau_no_show

   Overall baseline:
   110,527 appointments
   22,319 no-shows
   20.19% overall no-show rate
   ============================================================ */

USE medical_appointment_db;


/* ============================================================
   RESULT 1 — OVERALL BASELINE
   ============================================================ */

SELECT
    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS overall_no_show_rate

FROM vw_tableau_no_show;


/* ============================================================
   RESULT 2 — KEY FACTOR COMPARISON
   Compare categories against the overall no-show baseline.

   rate_gap_vs_overall:
   category no-show rate - overall no-show rate

   rate_index:
   category no-show rate / overall no-show rate

   Interpretation:
   1.00 = same as overall baseline
   >1.00 = above overall baseline
   <1.00 = below overall baseline
   ============================================================ */

WITH overall AS (

    SELECT
        SUM(no_show_binary = 1) * 100.0 / COUNT(*) AS overall_rate
    FROM vw_tableau_no_show

),

factor_analysis AS (

    /* AGE GROUP */

    SELECT
        'Age Group' AS factor,
        age_group AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY age_group


    UNION ALL


    /* ALCOHOLISM */

    SELECT
        'Alcoholism' AS factor,
        alcoholism_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY alcoholism_status


    UNION ALL


    /* DIABETES */

    SELECT
        'Diabetes' AS factor,
        diabetes_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY diabetes_status


    UNION ALL


    /* GENDER */

    SELECT
        'Gender' AS factor,
        gender_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY gender_status


    UNION ALL


    /* HYPERTENSION */

    SELECT
        'Hypertension' AS factor,
        hypertension_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY hypertension_status


    UNION ALL


    /* SCHOLARSHIP */

    SELECT
        'Scholarship' AS factor,
        scholarship_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY scholarship_status


    UNION ALL


    /* SMS */

    SELECT
        'SMS' AS factor,
        sms_status AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY sms_status


    UNION ALL


    /* WAITING GROUP */

    SELECT
        'Waiting Time' AS factor,
        waiting_group AS category,
        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 1) AS no_show,
        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY waiting_group

)

SELECT
    f.factor,
    f.category,
    f.total_appointments,
    f.no_show,
    f.no_show_rate,

    ROUND(
        f.no_show_rate - o.overall_rate,
        2
    ) AS rate_gap_vs_overall,

    ROUND(
        f.no_show_rate / o.overall_rate,
        2
    ) AS rate_index

FROM factor_analysis f

CROSS JOIN overall o

ORDER BY
    f.factor,

    f.no_show_rate DESC;


/* ============================================================
   RESULT 3 — WAITING TIME CONTRIBUTION
   Shows both no-show rate and contribution to total no-shows.
   ============================================================ */

WITH waiting_summary AS (

    SELECT
        waiting_group,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY waiting_group

),

total AS (

    SELECT
        SUM(no_show_binary = 1) AS total_no_show

    FROM vw_tableau_no_show

)

SELECT
    w.waiting_group,
    w.total_appointments,
    w.no_show,
    w.no_show_rate,

    ROUND(
        w.no_show * 100.0 / t.total_no_show,
        2
    ) AS no_show_contribution_pct

FROM waiting_summary w

CROSS JOIN total t

ORDER BY
    CASE w.waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END;


/* ============================================================
   RESULT 4 — AGE GROUP INSIGHT
   Compare age groups against overall baseline.
   ============================================================ */

WITH overall AS (

    SELECT
        SUM(no_show_binary = 1) * 100.0 / COUNT(*) AS overall_rate

    FROM vw_tableau_no_show

),

age_summary AS (

    SELECT
        age_group,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY age_group

)

SELECT
    a.age_group,
    a.total_appointments,
    a.no_show,
    a.no_show_rate,

    ROUND(
        a.no_show_rate - o.overall_rate,
        2
    ) AS rate_gap_vs_overall,

    ROUND(
        a.no_show_rate / o.overall_rate,
        2
    ) AS rate_index

FROM age_summary a

CROSS JOIN overall o

ORDER BY
    CASE a.age_group
        WHEN '0-12' THEN 1
        WHEN '13-18' THEN 2
        WHEN '19-35' THEN 3
        WHEN '36-50' THEN 4
        WHEN '51-65' THEN 5
        WHEN '66-75' THEN 6
        WHEN '76+' THEN 7
        WHEN 'Unknown' THEN 8
    END;


/* ============================================================
   RESULT 5 — SMS INSIGHT
   REVISED:
   Compare SMS categories against the overall baseline.

   Important:
   This is descriptive association.
   It does NOT imply that SMS causes no-show.
   ============================================================ */

WITH overall AS (

    SELECT
        SUM(no_show_binary = 1) * 100.0 / COUNT(*) AS overall_rate

    FROM vw_tableau_no_show

),

sms_summary AS (

    SELECT
        sms_status,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY sms_status

)

SELECT
    s.sms_status,
    s.total_appointments,
    s.no_show,
    s.no_show_rate,

    ROUND(
        s.no_show_rate - o.overall_rate,
        2
    ) AS rate_gap_vs_overall,

    ROUND(
        s.no_show_rate / o.overall_rate,
        2
    ) AS rate_index

FROM sms_summary s

CROSS JOIN overall o

ORDER BY
    s.no_show_rate DESC;


/* ============================================================
   RESULT 6 — HEALTH & PATIENT CHARACTERISTICS
   Supporting analysis.

   NOTE:
   Very small categories should not be interpreted as major
   insights.
   ============================================================ */

SELECT
    'Alcoholism' AS factor,
    alcoholism_status AS category,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY alcoholism_status


UNION ALL


SELECT
    'Diabetes' AS factor,
    diabetes_status AS category,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY diabetes_status


UNION ALL


SELECT
    'Hypertension' AS factor,
    hypertension_status AS category,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY hypertension_status


UNION ALL


SELECT
    'Handicap' AS factor,
    handicap_status AS category,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY handicap_status

ORDER BY
    factor,
    total_appointments DESC;


/* ============================================================
   RESULT 7 — APPOINTMENT DAY
   REVISED:
   Only categories with at least 500 appointments are included.

   This prevents very small groups such as Saturday
   (39 appointments) from being over-interpreted.
   ============================================================ */

WITH weekday_summary AS (

    SELECT
        appointment_day_name,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY appointment_day_name

    HAVING COUNT(*) >= 500

)

SELECT
    appointment_day_name,
    total_appointments,
    no_show,
    no_show_rate,

    ROUND(
        no_show_rate -
        (
            SELECT
                SUM(no_show_binary = 1) * 100.0 /
                COUNT(*)
            FROM vw_tableau_no_show
        ),
        2
    ) AS rate_gap_vs_overall

FROM weekday_summary

ORDER BY
    CASE appointment_day_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;


/* ============================================================
   RESULT 8 — NEIGHBOURHOOD
   Minimum sample size: 500 appointments.

   Used as supporting geographic analysis.
   ============================================================ */

WITH neighbourhood_summary AS (

    SELECT
        neighbourhood,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY neighbourhood

    HAVING COUNT(*) >= 500

),

overall AS (

    SELECT
        SUM(no_show_binary = 1) * 100.0 / COUNT(*) AS overall_rate

    FROM vw_tableau_no_show

)

SELECT
    n.neighbourhood,
    n.total_appointments,
    n.no_show,
    n.no_show_rate,

    ROUND(
        n.no_show_rate - o.overall_rate,
        2
    ) AS rate_gap_vs_overall,

    ROUND(
        n.no_show_rate / o.overall_rate,
        2
    ) AS rate_index

FROM neighbourhood_summary n

CROSS JOIN overall o

ORDER BY
    n.no_show_rate DESC;


/* ============================================================
   RESULT 9 — WAITING TIME × AGE × SMS
   Exploratory segmentation.

   Minimum sample size: 100 appointments.
   ============================================================ */

SELECT
    waiting_group,
    age_group,
    sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY
    waiting_group,
    age_group,
    sms_status

HAVING COUNT(*) >= 100

ORDER BY
    no_show_rate DESC,

    total_appointments DESC;


/* ============================================================
   RESULT 10 — HIGH-VOLUME HIGH-RISK SEGMENTS
   Minimum sample size: 500 appointments.

   This result is intended to avoid over-interpreting
   small segments with extreme percentages.
   ============================================================ */

SELECT
    waiting_group,
    age_group,
    sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show

GROUP BY
    waiting_group,
    age_group,
    sms_status

HAVING COUNT(*) >= 500

ORDER BY
    no_show_rate DESC,

    total_appointments DESC;


/* ============================================================
   RESULT 11 — WAITING TIME CONTRIBUTION
   Sorted by contribution to total no-shows.

   This is different from Result 3:
   Result 3 follows waiting-time order.
   Result 11 prioritizes contribution volume.
   ============================================================ */

WITH waiting_summary AS (

    SELECT
        waiting_group,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY waiting_group

),

total AS (

    SELECT
        SUM(no_show_binary = 1) AS total_no_show

    FROM vw_tableau_no_show

)

SELECT
    w.waiting_group,
    w.total_appointments,
    w.no_show,

    ROUND(
        w.no_show * 100.0 / t.total_no_show,
        2
    ) AS no_show_contribution_pct,

    w.no_show_rate

FROM waiting_summary w

CROSS JOIN total t

ORDER BY
    no_show_contribution_pct DESC;


/* ============================================================
   RESULT 12 — EXECUTIVE INSIGHT SUMMARY
   REVISED:
   Return category + volume + no-show rate.

   Avoid using MAX(no_show_rate) without identifying
   the corresponding category.
   ============================================================ */

WITH overall AS (

    SELECT
        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS total_no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS overall_no_show_rate

    FROM vw_tableau_no_show

),

waiting AS (

    SELECT
        waiting_group AS category,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY waiting_group

),

age AS (

    SELECT
        age_group AS category,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY age_group

),

sms AS (

    SELECT
        sms_status AS category,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM vw_tableau_no_show

    GROUP BY sms_status

),

waiting_max AS (

    SELECT
        'Waiting Time' AS factor,
        category,
        total_appointments,
        no_show,
        no_show_rate

    FROM (

        SELECT
            category,
            total_appointments,
            no_show,
            no_show_rate,

            ROW_NUMBER() OVER (
                ORDER BY no_show_rate DESC
            ) AS rn

        FROM waiting

    ) x

    WHERE rn = 1

),

age_max AS (

    SELECT
        'Age Group' AS factor,
        category,
        total_appointments,
        no_show,
        no_show_rate

    FROM (

        SELECT
            category,
            total_appointments,
            no_show,
            no_show_rate,

            ROW_NUMBER() OVER (
                ORDER BY no_show_rate DESC
            ) AS rn

        FROM age

    ) x

    WHERE rn = 1

),

sms_max AS (

    SELECT
        'SMS' AS factor,
        category,
        total_appointments,
        no_show,
        no_show_rate

    FROM (

        SELECT
            category,
            total_appointments,
            no_show,
            no_show_rate,

            ROW_NUMBER() OVER (
                ORDER BY no_show_rate DESC
            ) AS rn

        FROM sms

    ) x

    WHERE rn = 1

)

SELECT
    'Overall' AS factor,
    'Overall Baseline' AS category,
    o.total_appointments,
    o.total_no_show AS no_show,
    o.overall_no_show_rate AS no_show_rate

FROM overall o


UNION ALL


SELECT
    factor,
    category,
    total_appointments,
    no_show,
    no_show_rate

FROM waiting_max


UNION ALL


SELECT
    factor,
    category,
    total_appointments,
    no_show,
    no_show_rate

FROM age_max


UNION ALL


SELECT
    factor,
    category,
    total_appointments,
    no_show,
    no_show_rate

FROM sms_max;