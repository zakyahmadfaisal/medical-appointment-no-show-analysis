/* ============================================================
   04 - VALIDATION
   Medical Appointment No-Show Analysis

   Purpose:
   Validate vw_tableau_no_show before Tableau.

   Grain:
   1 row = 1 appointment
   ============================================================ */


/* ============================================================
   1. ROW-LEVEL INTEGRITY
   ============================================================ */

/* ------------------------------------------------------------
   1.1 Total Row Count
   Expected: 110,527
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS total_rows
FROM vw_tableau_no_show;


/* ------------------------------------------------------------
   1.2 Overall Dataset Reconciliation
   Expected:
   total_rows = 110,527
   attended   = 88,208
   no_show    = 22,319
   rate       = 20.19%
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS overall_no_show_rate

FROM vw_tableau_no_show;


/* ------------------------------------------------------------
   1.3 Distinct Appointment Dates
   Expected: 27
   ------------------------------------------------------------ */

SELECT
    COUNT(DISTINCT appointment_day) AS distinct_appointment_days
FROM vw_tableau_no_show;



/* ============================================================
   2. OUTCOME VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   2.1 No-Show Binary Values
   Expected: 0 and 1
   ------------------------------------------------------------ */

SELECT
    no_show_binary,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY no_show_binary
ORDER BY no_show_binary;


/* ------------------------------------------------------------
   2.2 No-Show Status
   Expected:
   Attended
   No-Show
   ------------------------------------------------------------ */

SELECT
    no_show_status,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY no_show_status
ORDER BY no_show_status;



/* ============================================================
   3. CORE CATEGORY VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   3.1 SMS
   Expected:
   sms_received = 0 and 1
   ------------------------------------------------------------ */

SELECT
    sms_received,
    sms_status,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY
    sms_received,
    sms_status
ORDER BY sms_received;


/* ------------------------------------------------------------
   3.2 Scholarship
   Expected:
   scholarship = 0 and 1
   ------------------------------------------------------------ */

SELECT
    scholarship,
    scholarship_status,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY
    scholarship,
    scholarship_status
ORDER BY scholarship;


/* ------------------------------------------------------------
   3.3 Gender
   Expected:
   Female
   Male
   ------------------------------------------------------------ */

SELECT
    gender_status,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY gender_status
ORDER BY gender_status;


/* ------------------------------------------------------------
   3.4 Age Group
   Expected: 8 categories
   ------------------------------------------------------------ */

SELECT
    age_group,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
GROUP BY age_group
ORDER BY
    CASE age_group
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
   4. WAITING TIME VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   4.1 Waiting Group Distribution
   ------------------------------------------------------------ */

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

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END;


/* ------------------------------------------------------------
   4.2 Waiting Days Data Quality
   Check:
   - negative waiting days
   - NULL waiting days
   - minimum
   - maximum
   ------------------------------------------------------------ */

SELECT
    SUM(waiting_days < 0) AS negative_waiting_days,

    SUM(waiting_days IS NULL) AS null_waiting_days,

    MIN(waiting_days) AS minimum_waiting_days,

    MAX(waiting_days) AS maximum_waiting_days

FROM vw_tableau_no_show;


/* ------------------------------------------------------------
   4.3 Unknown Waiting Group
   Expected: 1,082 rows
   ------------------------------------------------------------ */

SELECT
    waiting_group,
    COUNT(*) AS total_rows
FROM vw_tableau_no_show
WHERE waiting_group = 'Unknown'
GROUP BY waiting_group;



/* ============================================================
   5. HEALTH CONDITION VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   5.1 Health & Patient Factors
   ------------------------------------------------------------ */

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
    category;



/* ============================================================
   6. FACTOR DISTRIBUTION & NO-SHOW RATE
   ============================================================ */

/* ------------------------------------------------------------
   6.1 Demographic & Service Factors
   ------------------------------------------------------------ */

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

ORDER BY
    factor,
    category;



/* ============================================================
   7. AGE GROUP ANALYSIS VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   7.1 Age Group Distribution & No-Show Rate
   ------------------------------------------------------------ */

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

ORDER BY
    CASE age_group
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
   8. NEIGHBOURHOOD VALIDATION
   ============================================================ */

/* ------------------------------------------------------------
   8.1 Neighbourhood Distribution
   ------------------------------------------------------------ */

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

ORDER BY total_appointments DESC;



/* ------------------------------------------------------------
   8.2 Neighbourhoods with Minimum Sample Size
   Used in Analysis 13B
   Minimum: 500 appointments
   ------------------------------------------------------------ */

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

ORDER BY total_appointments DESC;



/* ============================================================
   9. FINAL RECONCILIATION
   ============================================================ */

/* ------------------------------------------------------------
   9.1 Waiting Groups Must Account for All Rows
   Expected:
   total_rows = total_waiting_group_rows = 110,527
   ------------------------------------------------------------ */

SELECT

    COUNT(*) AS total_rows,

    (
        SELECT
            SUM(total_appointments)

        FROM
        (
            SELECT
                waiting_group,
                COUNT(*) AS total_appointments

            FROM vw_tableau_no_show

            GROUP BY waiting_group

        ) AS waiting_summary

    ) AS total_waiting_group_rows

FROM vw_tableau_no_show;


/* ------------------------------------------------------------
   9.2 Final Outcome Reconciliation
   Expected:
   total = attended + no_show
   ------------------------------------------------------------ */

SELECT

    COUNT(*) AS total_rows,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    (
        SUM(no_show_binary = 0)
        +
        SUM(no_show_binary = 1)
    ) AS attended_plus_no_show

FROM vw_tableau_no_show;