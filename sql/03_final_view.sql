/* ============================================================
   FINAL VIEW FOR TABLEAU
   Medical Appointment No-Show Analysis
   1 row = 1 appointment

   Existing columns are preserved.
   Additional raw/detail columns:
   - age
   - gender
   - neighbourhood
   ============================================================ */

CREATE OR REPLACE VIEW vw_tableau_no_show AS

SELECT
    /* --------------------------------------------------------
       IDENTIFIER / DATE
       -------------------------------------------------------- */

    appointment_day,
    scheduled_day,

    /* --------------------------------------------------------
       WAITING TIME
       -------------------------------------------------------- */

    DATEDIFF(
        appointment_day,
        scheduled_day
    ) AS waiting_days,

    CASE
        WHEN appointment_day IS NULL
          OR scheduled_day IS NULL
            THEN 'Unknown'

        WHEN DATEDIFF(appointment_day, scheduled_day) = 0
            THEN 'Same Day'

        WHEN DATEDIFF(appointment_day, scheduled_day) BETWEEN 1 AND 7
            THEN '1-7 Days'

        WHEN DATEDIFF(appointment_day, scheduled_day) BETWEEN 8 AND 14
            THEN '8-14 Days'

        WHEN DATEDIFF(appointment_day, scheduled_day) BETWEEN 15 AND 30
            THEN '15-30 Days'

        WHEN DATEDIFF(appointment_day, scheduled_day) BETWEEN 31 AND 60
            THEN '31-60 Days'

        WHEN DATEDIFF(appointment_day, scheduled_day) >= 61
            THEN '61+ Days'

        ELSE 'Unknown'
    END AS waiting_group,

    /* --------------------------------------------------------
       AGE
       -------------------------------------------------------- */

    age,

    age_group,

    /* --------------------------------------------------------
       GENDER
       -------------------------------------------------------- */

    gender,

    CASE
        WHEN gender = 'F'
            THEN 'Female'

        WHEN gender = 'M'
            THEN 'Male'

        ELSE 'Unknown'
    END AS gender_status,

    /* --------------------------------------------------------
       LOCATION
       -------------------------------------------------------- */

    neighbourhood,

    /* --------------------------------------------------------
       SMS
       -------------------------------------------------------- */

    CASE
        WHEN sms_received = 0
            THEN 'No SMS'

        WHEN sms_received = 1
            THEN 'SMS Received'

        ELSE 'Unknown'
    END AS sms_status,

    sms_received,

    /* --------------------------------------------------------
       SCHOLARSHIP
       -------------------------------------------------------- */

    CASE
        WHEN scholarship = 0
            THEN 'No Scholarship'

        WHEN scholarship = 1
            THEN 'Scholarship'

        ELSE 'Unknown'
    END AS scholarship_status,

    scholarship,

    /* --------------------------------------------------------
       HEALTH
       -------------------------------------------------------- */

    hypertension,

    CASE
        WHEN hypertension = 0
            THEN 'No Hypertension'

        WHEN hypertension = 1
            THEN 'Hypertension'

        ELSE 'Unknown'
    END AS hypertension_status,

    diabetes,

    CASE
        WHEN diabetes = 0
            THEN 'No Diabetes'

        WHEN diabetes = 1
            THEN 'Diabetes'

        ELSE 'Unknown'
    END AS diabetes_status,

    alcoholism,

    CASE
        WHEN alcoholism = 0
            THEN 'No Alcoholism'

        WHEN alcoholism = 1
            THEN 'Alcoholism'

        ELSE 'Unknown'
    END AS alcoholism_status,

    handicap,

    CASE
        WHEN handicap = 0
            THEN 'No Handicap'

        WHEN handicap > 0
            THEN 'Handicap'

        ELSE 'Unknown'
    END AS handicap_status,

    /* --------------------------------------------------------
       NO-SHOW
       -------------------------------------------------------- */

    no_show_binary,

    CASE
        WHEN no_show_binary = 0
            THEN 'Attended'

        WHEN no_show_binary = 1
            THEN 'No-Show'

        ELSE 'Unknown'
    END AS no_show_status,

    /* --------------------------------------------------------
       TIME DIMENSIONS FOR TABLEAU
       -------------------------------------------------------- */

    YEAR(appointment_day) AS appointment_year,

    MONTH(appointment_day) AS appointment_month,

    MONTHNAME(appointment_day) AS appointment_month_name,

    DAYOFWEEK(appointment_day) AS appointment_day_number,

    DAYNAME(appointment_day) AS appointment_day_name

FROM appointments;


/* ============================================================
   VALIDATION 1 — OVERALL
   ============================================================ */

SELECT
    COUNT(*) AS total_rows,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM vw_tableau_no_show;


/* ============================================================
   VALIDATION 2 — HEALTH
   ============================================================ */

SELECT
    hypertension_status,
    COUNT(*) AS appointments,
    SUM(no_show_binary = 1) AS no_show,
    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate
FROM vw_tableau_no_show
GROUP BY hypertension_status;


/* ============================================================
   VALIDATION 3 — HEALTH COMBINATION
   ============================================================ */

SELECT
    hypertension_status,
    diabetes_status,
    alcoholism_status,
    handicap_status,
    COUNT(*) AS appointments
FROM vw_tableau_no_show
GROUP BY
    hypertension_status,
    diabetes_status,
    alcoholism_status,
    handicap_status
LIMIT 20;

SELECT
    COUNT(*) AS total_rows,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    COUNT(neighbourhood) AS neighbourhood_count,
    COUNT(DISTINCT neighbourhood) AS unique_neighbourhood
FROM vw_tableau_no_show;

SELECT *
FROM vw_tableau_no_show;