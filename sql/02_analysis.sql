/* ============================================================
   MEDICAL APPOINTMENT NO-SHOWS
   SQL ANALYSIS SCRIPT
   Purpose: Exploratory, comparative, and statistical analysis
   Source table: appointments
   Database: medical_appointment_db

   NOTE:
   This version is formatting-cleaned only. Query logic, analysis
   order, thresholds, filters, and calculations are preserved.
   ============================================================ */

USE medical_appointment_db;

SELECT
    COUNT(*) AS total_appointments,
    COUNT(DISTINCT patient_id) AS unique_patients,
    SUM(no_show_binary = 0) AS attended,
    SUM(no_show_binary = 1) AS no_show
FROM appointments;

/* ============================================================
   ANALYSIS 2 — NO-SHOW RATE
   ============================================================ */

SELECT
    no_show_binary,

    CASE
        WHEN no_show_binary = 0 THEN 'Attended'
        WHEN no_show_binary = 1 THEN 'No Show'
    END AS attendance_status,

    COUNT(*) AS total_appointments,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM appointments),
        2
    ) AS percentage

FROM appointments

GROUP BY no_show_binary

ORDER BY no_show_binary;

/* ============================================================
   ANALYSIS 3 — NO-SHOW BERDASARKAN GENDER
   ============================================================ */

SELECT
    gender,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY gender

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 4 — NO-SHOW BERDASARKAN AGE GROUP
   ============================================================ */

SELECT
    age_group,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY age_group

ORDER BY
    CASE age_group
        WHEN '0–12' THEN 1
        WHEN '13–18' THEN 2
        WHEN '19–35' THEN 3
        WHEN '36–50' THEN 4
        WHEN '51–65' THEN 5
        WHEN '66–75' THEN 6
        WHEN '76+' THEN 7
        WHEN 'Unknown' THEN 8
    END;

/* ============================================================
   ANALYSIS 5 — NO-SHOW BERDASARKAN WAITING DAYS
   ============================================================ */

SELECT
    CASE
        WHEN waiting_days = 0 THEN 'Same Day'
        WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
        WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
        WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
        WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN waiting_days > 60 THEN '61+ Days'
        ELSE 'Unknown'
    END AS waiting_group,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

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

SELECT
    waiting_group,
    total_appointments,
    attended,
    no_show,
    (attended + no_show) AS calculated_total,
    total_appointments - (attended + no_show) AS difference
FROM (
    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        COUNT(*) AS total_appointments,
        SUM(no_show_binary = 0) AS attended,
        SUM(no_show_binary = 1) AS no_show

    FROM appointments

    GROUP BY waiting_group
) AS validation
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

/* ============================================================
   ANALYSIS 6 - SMS REMINDER VS NO-SHOW
   ============================================================ */

SELECT
    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
    END AS sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY sms_received

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 7 - SMS REMINDER VS WAITING TIME
   ============================================================ */

SELECT
    waiting_group,
    sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM (
    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
        END AS sms_status,

        no_show_binary

    FROM appointments
) AS analysis_data

GROUP BY
    waiting_group,
    sms_status

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,
    sms_status;

/* ============================================================
   ANALYSIS 8 - NO-SHOW BERDASARKAN HARI APPOINTMENT
   ============================================================ */

SELECT
    DAYNAME(appointment_day) AS appointment_weekday,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY DAYOFWEEK(appointment_day), DAYNAME(appointment_day)

ORDER BY DAYOFWEEK(appointment_day);

/* ============================================================
   ANALYSIS 9 - HYPERTENSION VS NO-SHOW
   ============================================================ */

SELECT
    CASE
        WHEN hypertension = 0 THEN 'No Hypertension'
        WHEN hypertension = 1 THEN 'Hypertension'
    END AS hypertension_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY hypertension

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 10 - DIABETES VS NO-SHOW
   ============================================================ */

SELECT
    CASE
        WHEN diabetes = 0 THEN 'No Diabetes'
        WHEN diabetes = 1 THEN 'Diabetes'
    END AS diabetes_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY diabetes

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 11 - ALCOHOLISM VS NO-SHOW
   ============================================================ */

SELECT
    CASE
        WHEN alcoholism = 0 THEN 'No Alcoholism'
        WHEN alcoholism = 1 THEN 'Alcoholism'
    END AS alcoholism_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY alcoholism

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 12 - HANDICAP VS NO-SHOW
   ============================================================ */

SELECT
    handicap AS handicap_level,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY handicap

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 13 - NO-SHOW BERDASARKAN NEIGHBOURHOOD
   ============================================================ */

SELECT
    neighbourhood,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY neighbourhood

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 13B - NO-SHOW BERDASARKAN NEIGHBOURHOOD
   MINIMUM 500 APPOINTMENTS
   ============================================================ */

SELECT
    neighbourhood,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY neighbourhood

HAVING COUNT(*) >= 500

ORDER BY no_show_rate DESC;

/* ============================================================
   ANALYSIS 14 - NO-SHOW BERDASARKAN WAITING TIME & AGE GROUP
   ============================================================ */

WITH analysis_data AS (
    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        age_group,
        no_show_binary

    FROM appointments
)

SELECT
    waiting_group,
    age_group,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_data

GROUP BY
    waiting_group,
    age_group

HAVING COUNT(*) >= 100

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,
    no_show_rate DESC;

/* ============================================================
   ANALYSIS 15 - WAITING TIME × SMS REMINDER
   ============================================================ */

WITH analysis_data AS (
    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
            ELSE 'Unknown'
        END AS sms_status,

        no_show_binary

    FROM appointments
)

SELECT
    waiting_group,
    sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_data

GROUP BY
    waiting_group,
    sms_status

HAVING COUNT(*) >= 100

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,
    sms_status;

/* =========================================================
   ANALYSIS 16 - SMS REMINDER VS NO-SHOW BERDASARKAN AGE GROUP
   ========================================================= */

SELECT
    age_group,

    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
    END AS sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY
    age_group,
    sms_received

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
    END,
    sms_received;

/* =========================================================
   ANALYSIS 17 - SCHOLARSHIP VS NO-SHOW
   ========================================================= */

SELECT
    CASE
        WHEN scholarship = 0 THEN 'No Scholarship'
        WHEN scholarship = 1 THEN 'Scholarship'
    END AS scholarship_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY scholarship

ORDER BY no_show_rate DESC;

/* =========================================================
   ANALYSIS 18 - SCHOLARSHIP VS NO-SHOW
                BERDASARKAN WAITING TIME
   ========================================================= */

WITH analysis_data AS (

    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        scholarship,
        no_show_binary

    FROM appointments
)

SELECT
    waiting_group,

    CASE
        WHEN scholarship = 0 THEN 'No Scholarship'
        WHEN scholarship = 1 THEN 'Scholarship'
    END AS scholarship_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_data

GROUP BY
    waiting_group,
    scholarship

HAVING COUNT(*) >= 100

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,
    scholarship;

    /* =========================================================
   ANALYSIS 19 - NO-SHOW BERDASARKAN
                 WAITING TIME × APPOINTMENT DAY
   ========================================================= */

WITH analysis_data AS (

    SELECT
        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days > 60 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group,

        DAYNAME(appointment_day) AS appointment_weekday,

        no_show_binary

    FROM appointments
)

SELECT
    waiting_group,
    appointment_weekday,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_data

GROUP BY
    waiting_group,
    appointment_weekday

HAVING COUNT(*) >= 100

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE appointment_weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

/* =========================================================
   ANALYSIS 20 - SMS × APPOINTMENT WEEKDAY
   ========================================================= */

SELECT

    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
    END AS sms_status,

    DAYNAME(appointment_day) AS appointment_weekday,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY
    sms_received,
    appointment_weekday

HAVING COUNT(*) >= 100

ORDER BY
    CASE appointment_weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,

    sms_received;

/* =========================================================
   ANALYSIS 21
   WAITING TIME × SMS × APPOINTMENT WEEKDAY
   ========================================================= */

WITH analysis_data AS (

    SELECT
        *,
        CASE
            WHEN waiting_days = 0
                THEN 'Same Day'

            WHEN waiting_days BETWEEN 1 AND 7
                THEN '1-7 Days'

            WHEN waiting_days BETWEEN 8 AND 14
                THEN '8-14 Days'

            WHEN waiting_days BETWEEN 15 AND 30
                THEN '15-30 Days'

            WHEN waiting_days BETWEEN 31 AND 60
                THEN '31-60 Days'

            WHEN waiting_days > 60
                THEN '61+ Days'

            ELSE 'Unknown'
        END AS waiting_group

    FROM appointments

)

SELECT

    waiting_group,

    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
    END AS sms_status,

    DAYNAME(appointment_day) AS appointment_weekday,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_data

GROUP BY
    waiting_group,
    sms_received,
    DAYNAME(appointment_day)

HAVING COUNT(*) >= 100

ORDER BY

    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE appointment_weekday
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END,

    sms_status;

/* =========================================================
   ANALYSIS 22 - WAITING TIME VS NO-SHOW RATE
   ========================================================= */

WITH waiting_grouped AS (
    SELECT
        *,
        CASE
            WHEN waiting_days = 0
                THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7
                THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14
                THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30
                THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60
                THEN '31-60 Days'
            WHEN waiting_days >= 61
                THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group
    FROM appointments
)

SELECT
    waiting_group,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM waiting_grouped

GROUP BY waiting_group

HAVING COUNT(*) >= 100

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

/* =========================================================
   ANALYSIS 23 - WAITING TIME + SMS + SCHOLARSHIP VS NO-SHOW
   ========================================================= */

WITH waiting_data AS (
    SELECT
        sms_received,
        scholarship,
        no_show_binary,
        DATEDIFF(appointment_day, scheduled_day) AS waiting_days
    FROM appointments
),

waiting_grouped AS (
    SELECT
        sms_received,
        scholarship,
        no_show_binary,

        CASE
            WHEN waiting_days = 0 THEN 'Same Day'
            WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
            WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
            WHEN waiting_days BETWEEN 15 AND 30 THEN '15-30 Days'
            WHEN waiting_days BETWEEN 31 AND 60 THEN '31-60 Days'
            WHEN waiting_days >= 61 THEN '61+ Days'
            ELSE 'Unknown'
        END AS waiting_group

    FROM waiting_data
)

SELECT
    waiting_group,

    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
        ELSE 'Unknown'
    END AS sms_status,

    CASE
        WHEN scholarship = 0 THEN 'No Scholarship'
        WHEN scholarship = 1 THEN 'Scholarship'
        ELSE 'Unknown'
    END AS scholarship_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM waiting_grouped

GROUP BY
    waiting_group,
    sms_received,
    scholarship

HAVING COUNT(*) >= 100

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    sms_received,
    scholarship;

/* =========================================================
   ANALYSIS 24 - AGE + SMS + SCHOLARSHIP VS NO-SHOW
   ========================================================= */

WITH analysis_24 AS (

    SELECT

        CASE
            WHEN age BETWEEN 0 AND 12 THEN '0-12'
            WHEN age BETWEEN 13 AND 18 THEN '13-18'
            WHEN age BETWEEN 19 AND 35 THEN '19-35'
            WHEN age BETWEEN 36 AND 50 THEN '36-50'
            WHEN age BETWEEN 51 AND 65 THEN '51-65'
            WHEN age BETWEEN 66 AND 75 THEN '66-75'
            WHEN age >= 76 THEN '76+'
            ELSE 'Unknown'
        END AS age_group,

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
            ELSE 'Unknown'
        END AS sms_status,

        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        no_show_binary

    FROM appointments
)

SELECT

    age_group,
    sms_status,
    scholarship_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_24

GROUP BY
    age_group,
    sms_status,
    scholarship_status

HAVING COUNT(*) >= 100

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
    END,

    CASE sms_status
        WHEN 'No SMS' THEN 1
        WHEN 'SMS Received' THEN 2
        WHEN 'Unknown' THEN 3
    END,

    CASE scholarship_status
        WHEN 'No Scholarship' THEN 1
        WHEN 'Scholarship' THEN 2
        WHEN 'Unknown' THEN 3
    END;

/* =========================================================
   ANALYSIS 25 - WAITING TIME + AGE + SMS VS NO-SHOW
   ========================================================= */

WITH analysis_25 AS (

    SELECT

        CASE
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

        CASE
            WHEN age BETWEEN 0 AND 12 THEN '0-12'
            WHEN age BETWEEN 13 AND 18 THEN '13-18'
            WHEN age BETWEEN 19 AND 35 THEN '19-35'
            WHEN age BETWEEN 36 AND 50 THEN '36-50'
            WHEN age BETWEEN 51 AND 65 THEN '51-65'
            WHEN age BETWEEN 66 AND 75 THEN '66-75'
            WHEN age >= 76 THEN '76+'
            ELSE 'Unknown'
        END AS age_group,

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
            ELSE 'Unknown'
        END AS sms_status,

        no_show_binary

    FROM appointments
)

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

FROM analysis_25

GROUP BY
    waiting_group,
    age_group,
    sms_status

HAVING COUNT(*) >= 100

ORDER BY

    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE age_group
        WHEN '0-12' THEN 1
        WHEN '13-18' THEN 2
        WHEN '19-35' THEN 3
        WHEN '36-50' THEN 4
        WHEN '51-65' THEN 5
        WHEN '66-75' THEN 6
        WHEN '76+' THEN 7
        WHEN 'Unknown' THEN 8
    END,

    CASE sms_status
        WHEN 'No SMS' THEN 1
        WHEN 'SMS Received' THEN 2
        WHEN 'Unknown' THEN 3
    END;

/* =========================================================
   ANALYSIS 26 - WAITING TIME + SCHOLARSHIP VS NO-SHOW
   ========================================================= */

WITH analysis_26 AS (

    SELECT

        CASE
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

        CASE
            WHEN scholarship = 0
                THEN 'No Scholarship'

            WHEN scholarship = 1
                THEN 'Scholarship'

            ELSE 'Unknown'
        END AS scholarship_status,

        no_show_binary

    FROM appointments
)

SELECT

    waiting_group,
    scholarship_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_26

GROUP BY
    waiting_group,
    scholarship_status

HAVING COUNT(*) >= 100

ORDER BY

    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE scholarship_status
        WHEN 'No Scholarship' THEN 1
        WHEN 'Scholarship' THEN 2
        WHEN 'Unknown' THEN 3
    END;

/* =========================================================
   ANALYSIS 27 - SCHOLARSHIP GAP BY WAITING TIME
   ========================================================= */

WITH analysis_27 AS (

    SELECT

        CASE
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

        scholarship,
        no_show_binary

    FROM appointments
)

SELECT

    waiting_group,

    /* =========================
       NO SCHOLARSHIP
       ========================= */

    SUM(
        CASE
            WHEN scholarship = 0 THEN 1
            ELSE 0
        END
    ) AS no_scholarship_appointments,

    ROUND(
        SUM(
            CASE
                WHEN scholarship = 0
                     AND no_show_binary = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(
            SUM(
                CASE
                    WHEN scholarship = 0 THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS no_scholarship_no_show_rate,

    /* =========================
       SCHOLARSHIP
       ========================= */

    SUM(
        CASE
            WHEN scholarship = 1 THEN 1
            ELSE 0
        END
    ) AS scholarship_appointments,

    ROUND(
        SUM(
            CASE
                WHEN scholarship = 1
                     AND no_show_binary = 1
                THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(
            SUM(
                CASE
                    WHEN scholarship = 1 THEN 1
                    ELSE 0
                END
            ),
            0
        ),
        2
    ) AS scholarship_no_show_rate,

    /* =========================
       GAP
       ========================= */

    ROUND(

        (
            SUM(
                CASE
                    WHEN scholarship = 1
                         AND no_show_binary = 1
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
            /
            NULLIF(
                SUM(
                    CASE
                        WHEN scholarship = 1 THEN 1
                        ELSE 0
                    END
                ),
                0
            )
        )

        -

        (
            SUM(
                CASE
                    WHEN scholarship = 0
                         AND no_show_binary = 1
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
            /
            NULLIF(
                SUM(
                    CASE
                        WHEN scholarship = 0 THEN 1
                        ELSE 0
                    END
                ),
                0
            )
        ),

        2

    ) AS scholarship_gap_pp

FROM analysis_27

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

/* =========================================================
   ANALYSIS 28 - WAITING TIME × SCHOLARSHIP × GENDER
   ========================================================= */

WITH analysis_28 AS (

    SELECT

        CASE
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

        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        CASE
            WHEN gender = 'F' THEN 'Female'
            WHEN gender = 'M' THEN 'Male'
            ELSE 'Unknown'
        END AS gender_status,

        no_show_binary

    FROM appointments
)

SELECT

    waiting_group,
    scholarship_status,
    gender_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_28

GROUP BY
    waiting_group,
    scholarship_status,
    gender_status

HAVING COUNT(*) >= 100

ORDER BY

    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE scholarship_status
        WHEN 'No Scholarship' THEN 1
        WHEN 'Scholarship' THEN 2
        WHEN 'Unknown' THEN 3
    END,

    CASE gender_status
        WHEN 'Female' THEN 1
        WHEN 'Male' THEN 2
        WHEN 'Unknown' THEN 3
    END;

/* =========================================================
   ANALYSIS 29 - GENDER VS NO-SHOW BY WAITING TIME
   ========================================================= */

WITH analysis_29 AS (

    SELECT

        CASE
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

        CASE
            WHEN gender = 'F' THEN 'Female'
            WHEN gender = 'M' THEN 'Male'
            ELSE 'Unknown'
        END AS gender_status,

        no_show_binary

    FROM appointments
)

SELECT

    waiting_group,
    gender_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM analysis_29

GROUP BY
    waiting_group,
    gender_status

HAVING COUNT(*) >= 100

ORDER BY

    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE gender_status
        WHEN 'Female' THEN 1
        WHEN 'Male' THEN 2
        WHEN 'Unknown' THEN 3
    END;

/* =========================================================
   ANALYSIS 30 - NO-SHOW CONTRIBUTION BY WAITING TIME
   ========================================================= */

WITH analysis_30 AS (

    SELECT

        CASE
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

        no_show_binary

    FROM appointments
),

grouped AS (

    SELECT

        waiting_group,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM analysis_30

    GROUP BY waiting_group

),

total AS (

    SELECT
        SUM(no_show_binary = 1) AS total_no_show
    FROM analysis_30

)

SELECT

    g.waiting_group,

    g.total_appointments,

    g.attended,

    g.no_show,

    g.no_show_rate,

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

/* =========================================================
   ANALYSIS 31 - NO-SHOW CONTRIBUTION BY WAITING TIME,
   SMS & SCHOLARSHIP
   ========================================================= */

WITH analysis_31 AS (

    SELECT
        CASE
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

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
            ELSE 'Unknown'
        END AS sms_status,

        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        no_show_binary

    FROM appointments
),

grouped AS (

    SELECT

        waiting_group,
        sms_status,
        scholarship_status,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM analysis_31

    GROUP BY
        waiting_group,
        sms_status,
        scholarship_status

    HAVING COUNT(*) >= 100

),

total AS (

    SELECT
        SUM(no_show_binary = 1) AS total_no_show
    FROM analysis_31

)

SELECT

    g.waiting_group,
    g.sms_status,
    g.scholarship_status,

    g.total_appointments,
    g.attended,
    g.no_show,
    g.no_show_rate,

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
    END,

    CASE g.sms_status
        WHEN 'No SMS' THEN 1
        WHEN 'SMS Received' THEN 2
        ELSE 3
    END,

    CASE g.scholarship_status
        WHEN 'No Scholarship' THEN 1
        WHEN 'Scholarship' THEN 2
        ELSE 3
    END;

/* =========================================================
   ANALYSIS 32 - SMS RATE DIFFERENCE BY WAITING & SCHOLARSHIP
   ========================================================= */

WITH analysis_32 AS (

    SELECT
        CASE
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

        CASE
            WHEN sms_received = 0 THEN 'No SMS'
            WHEN sms_received = 1 THEN 'SMS Received'
            ELSE 'Unknown'
        END AS sms_status,

        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        no_show_binary

    FROM appointments
),

grouped AS (

    SELECT
        waiting_group,
        sms_status,
        scholarship_status,

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 1) AS no_show,

        ROUND(
            SUM(no_show_binary = 1) * 100.0 / COUNT(*),
            2
        ) AS no_show_rate

    FROM analysis_32

    GROUP BY
        waiting_group,
        sms_status,
        scholarship_status

    HAVING COUNT(*) >= 100

)

SELECT
    waiting_group,
    scholarship_status,

    MAX(
        CASE
            WHEN sms_status = 'No SMS'
            THEN total_appointments
        END
    ) AS no_sms_appointments,

    MAX(
        CASE
            WHEN sms_status = 'No SMS'
            THEN no_show
        END
    ) AS no_sms_no_show,

    MAX(
        CASE
            WHEN sms_status = 'No SMS'
            THEN no_show_rate
        END
    ) AS no_sms_rate,

    MAX(
        CASE
            WHEN sms_status = 'SMS Received'
            THEN total_appointments
        END
    ) AS sms_appointments,

    MAX(
        CASE
            WHEN sms_status = 'SMS Received'
            THEN no_show
        END
    ) AS sms_no_show,

    MAX(
        CASE
            WHEN sms_status = 'SMS Received'
            THEN no_show_rate
        END
    ) AS sms_rate,

    ROUND(
        MAX(
            CASE
                WHEN sms_status = 'No SMS'
                THEN no_show_rate
            END
        )
        -
        MAX(
            CASE
                WHEN sms_status = 'SMS Received'
                THEN no_show_rate
            END
        ),
        2
    ) AS sms_rate_difference_pp

FROM grouped

GROUP BY
    waiting_group,
    scholarship_status

HAVING
    COUNT(DISTINCT sms_status) = 2

ORDER BY
    CASE waiting_group
        WHEN 'Same Day' THEN 1
        WHEN '1-7 Days' THEN 2
        WHEN '8-14 Days' THEN 3
        WHEN '15-30 Days' THEN 4
        WHEN '31-60 Days' THEN 5
        WHEN '61+ Days' THEN 6
        WHEN 'Unknown' THEN 7
    END,

    CASE scholarship_status
        WHEN 'No Scholarship' THEN 1
        WHEN 'Scholarship' THEN 2
        ELSE 3
    END;

/* =========================================================
   ANALYSIS 33 - OVERALL SMS VS NO-SHOW
   ========================================================= */

SELECT
    CASE
        WHEN sms_received = 0 THEN 'No SMS'
        WHEN sms_received = 1 THEN 'SMS Received'
        ELSE 'Unknown'
    END AS sms_status,

    COUNT(*) AS total_appointments,

    SUM(no_show_binary = 0) AS attended,

    SUM(no_show_binary = 1) AS no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments

GROUP BY
    sms_received

ORDER BY
    sms_received;

/* =========================================================
   ANALYSIS 34 - CHI-SQUARE TEST
   SMS STATUS VS NO-SHOW
   ========================================================= */

WITH observed AS (

    SELECT
        SUM(sms_received = 0 AND no_show_binary = 0) AS a,
        SUM(sms_received = 0 AND no_show_binary = 1) AS b,
        SUM(sms_received = 1 AND no_show_binary = 0) AS c,
        SUM(sms_received = 1 AND no_show_binary = 1) AS d

    FROM appointments

),

calc AS (

    SELECT
        a,
        b,
        c,
        d,

        (a + b + c + d) AS total_n,

        ((a + b) * (a + c) * 1.0)
            / (a + b + c + d) AS expected_a,

        ((a + b) * (b + d) * 1.0)
            / (a + b + c + d) AS expected_b,

        ((c + d) * (a + c) * 1.0)
            / (a + b + c + d) AS expected_c,

        ((c + d) * (b + d) * 1.0)
            / (a + b + c + d) AS expected_d

    FROM observed

),

chi_calc AS (

    SELECT
        *,

        (
            POWER(a - expected_a, 2) / expected_a
            +
            POWER(b - expected_b, 2) / expected_b
            +
            POWER(c - expected_c, 2) / expected_c
            +
            POWER(d - expected_d, 2) / expected_d
        ) AS chi_square

    FROM calc

)

SELECT

    a AS no_sms_attended,
    b AS no_sms_no_show,

    c AS sms_attended,
    d AS sms_no_show,

    total_n,

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

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

/* =========================================================
   ANALYSIS 35 - WAITING TIME VS NO-SHOW
   ========================================================= */

WITH grouped AS (

    SELECT
        CASE
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

        COUNT(*) AS total_appointments,

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show

    FROM appointments

    GROUP BY
        CASE
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
        END

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

/* =========================================================
   ANALYSIS 36 - CHI-SQUARE
   WAITING TIME VS NO-SHOW
   ========================================================= */

WITH observed AS (

    SELECT
        CASE
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

        SUM(no_show_binary = 0) AS attended,

        SUM(no_show_binary = 1) AS no_show,

        COUNT(*) AS total_n

    FROM appointments

    GROUP BY
        CASE
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
        END
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

        (o.total_n * t.total_attended / t.total_n)
            AS expected_attended,

        (o.total_n * t.total_no_show / t.total_n)
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

    ROUND(chi_square, 4) AS chi_square,

    6 AS degrees_of_freedom,

    ROUND(
        SQRT(
            chi_square / total_n / 1
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

/* =========================================================
   ANALYSIS 37 - CHI-SQUARE
   SCHOLARSHIP VS NO-SHOW
   ========================================================= */

WITH observed AS (

    SELECT
        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        SUM(no_show_binary = 0) AS attended,
        SUM(no_show_binary = 1) AS no_show,
        COUNT(*) AS total_n

    FROM appointments

    GROUP BY
        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END
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

        (o.total_n * t.total_attended / t.total_n)
            AS expected_attended,

        (o.total_n * t.total_no_show / t.total_n)
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

        MAX(
            expected_attended + expected_no_show
        ) AS total_n

    FROM expected
)

SELECT

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

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

/* =========================================================
   ANALYSIS 38 - CHI-SQUARE
   GENDER VS NO-SHOW
   ========================================================= */

WITH observed AS (

    SELECT
        CASE
            WHEN gender = 0 THEN 'Female'
            WHEN gender = 1 THEN 'Male'
        END AS gender_status,

        SUM(CASE
            WHEN no_show_binary = 0 THEN 1
            ELSE 0
        END) AS attended,

        SUM(CASE
            WHEN no_show_binary = 1 THEN 1
            ELSE 0
        END) AS no_show,

        COUNT(*) AS total_n

    FROM appointments

    WHERE gender IN (0, 1)

    GROUP BY gender

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

    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

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
   ANALYSIS 39 — AGE GROUP VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (
    SELECT
        CASE
            WHEN age_group = '0-12' THEN '0-12'
            WHEN age_group = '13-18' THEN '13-18'
            WHEN age_group = '19-35' THEN '19-35'
            WHEN age_group = '36-50' THEN '36-50'
            WHEN age_group = '51-65' THEN '51-65'
            WHEN age_group = '66-75' THEN '66-75'
            WHEN age_group = '76+' THEN '76+'
            ELSE 'Unknown'
        END AS age_group,

        SUM(no_show_binary = 0) AS attended,
        SUM(no_show_binary = 1) AS no_show
    FROM appointments
    GROUP BY
        CASE
            WHEN age_group = '0-12' THEN '0-12'
            WHEN age_group = '13-18' THEN '13-18'
            WHEN age_group = '19-35' THEN '19-35'
            WHEN age_group = '36-50' THEN '36-50'
            WHEN age_group = '51-65' THEN '51-65'
            WHEN age_group = '66-75' THEN '66-75'
            WHEN age_group = '76+' THEN '76+'
            ELSE 'Unknown'
        END
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
            (o.attended + o.no_show)
            * t.total_attended / t.total_n,
            6
        ) AS expected_attended,

        ROUND(
            (o.attended + o.no_show)
            * t.total_no_show / t.total_n,
            6
        ) AS expected_no_show

    FROM observed o
    CROSS JOIN totals t
),

chi_calc AS (
    SELECT
        *,
        POWER(attended - expected_attended, 2)
            / expected_attended

        +

        POWER(no_show - expected_no_show, 2)
            / expected_no_show

        AS chi_component

    FROM expected
),

final_calc AS (
    SELECT
        SUM(chi_component) AS chi_square,
        SUM(attended + no_show) AS total_n
    FROM chi_calc
)

SELECT
    ROUND(chi_square, 4) AS chi_square,

    7 AS degrees_of_freedom,

    ROUND(
        SQRT(chi_square / total_n),
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
   ANALYSIS 40 — SCHOLARSHIP VS NO-SHOW
   Chi-Square Test of Independence
   ============================================================ */

WITH observed AS (
    SELECT
        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END AS scholarship_status,

        SUM(no_show_binary = 0) AS attended,
        SUM(no_show_binary = 1) AS no_show

    FROM appointments

    GROUP BY
        CASE
            WHEN scholarship = 0 THEN 'No Scholarship'
            WHEN scholarship = 1 THEN 'Scholarship'
            ELSE 'Unknown'
        END
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
            (o.attended + o.no_show)
            * t.total_attended / t.total_n,
            6
        ) AS expected_attended,

        ROUND(
            (o.attended + o.no_show)
            * t.total_no_show / t.total_n,
            6
        ) AS expected_no_show

    FROM observed o
    CROSS JOIN totals t
),

chi_calc AS (
    SELECT
        *,

        POWER(attended - expected_attended, 2)
            / expected_attended

        +

        POWER(no_show - expected_no_show, 2)
            / expected_no_show

        AS chi_component

    FROM expected
),

final_calc AS (
    SELECT
        SUM(chi_component) AS chi_square,
        SUM(attended + no_show) AS total_n

    FROM chi_calc
)

SELECT
    ROUND(chi_square, 4) AS chi_square,

    1 AS degrees_of_freedom,

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

FROM final_calc;
