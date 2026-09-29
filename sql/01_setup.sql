/* ============================================================
   MEDICAL APPOINTMENT NO-SHOWS
   Data Preparation & Validation
   Database : MySQL
   ============================================================ */


/* ============================================================
   1. CREATE DATABASE
   ============================================================ */

CREATE DATABASE IF NOT EXISTS medical_appointment_db;

USE medical_appointment_db;


/* ============================================================
   2. RESET TABLE
   ============================================================ */

DROP TABLE IF EXISTS appointments;


/* ============================================================
   3. CREATE TABLE
   ============================================================ */

CREATE TABLE appointments (
    patient_id BIGINT,
    appointment_id INT,
    gender VARCHAR(10),
    scheduled_day DATETIME,
    appointment_day DATETIME,
    age DECIMAL(5,2),
    age_group VARCHAR(20),
    neighbourhood VARCHAR(100),
    scholarship TINYINT,
    hypertension TINYINT,
    diabetes TINYINT,
    alcoholism TINYINT,
    handicap TINYINT,
    sms_received TINYINT,
    no_show VARCHAR(10),
    no_show_binary TINYINT,
    waiting_days DECIMAL(6,2)
);


/* ============================================================
   4. IMPORT CLEANED CSV
   ============================================================ */
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE
'D:/Project Portofolio/Medical Appointment No Shows/data/Processed.csv'

INTO TABLE appointments

CHARACTER SET utf8mb4

FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'

LINES TERMINATED BY '\n'

IGNORE 1 ROWS

(
    patient_id,
    appointment_id,
    gender,
    scheduled_day,
    appointment_day,
    @age,
    age_group,
    neighbourhood,
    scholarship,
    hypertension,
    diabetes,
    alcoholism,
    handicap,
    sms_received,
    no_show,
    no_show_binary,
    @waiting_days
)

SET
    age = NULLIF(TRIM(@age), ''),
    waiting_days = NULLIF(TRIM(@waiting_days), '');


/* ============================================================
   5. BASIC DATA VALIDATION
   ============================================================ */


/* 5.1 Total rows */

SELECT
    COUNT(*) AS total_rows
FROM appointments;


/* 5.2 Table structure */

DESCRIBE appointments;


/* 5.3 Duplicate appointment_id */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT appointment_id) AS unique_appointments,
    COUNT(*) - COUNT(DISTINCT appointment_id)
        AS duplicate_appointments
FROM appointments;


/* ============================================================
   6. MISSING VALUE VALIDATION
   ============================================================ */

SELECT
    COUNT(*) AS total_rows,

    SUM(age IS NULL)
        AS missing_age,

    SUM(waiting_days IS NULL)
        AS missing_waiting_days,

    SUM(scheduled_day IS NULL)
        AS missing_scheduled_day,

    SUM(appointment_day IS NULL)
        AS missing_appointment_day

FROM appointments;


/* ============================================================
   7. AGE VALIDATION
   ============================================================ */

SELECT
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(age), 2) AS avg_age,
    SUM(age IS NULL) AS missing_age
FROM appointments;


/* Check age outside valid range */

SELECT
    COUNT(*) AS invalid_age
FROM appointments
WHERE age < 0
   OR age > 100;


/* ============================================================
   8. WAITING DAYS VALIDATION
   ============================================================ */

SELECT
    MIN(waiting_days) AS min_waiting_days,
    MAX(waiting_days) AS max_waiting_days,
    ROUND(AVG(waiting_days), 2) AS avg_waiting_days,
    SUM(waiting_days IS NULL) AS missing_waiting_days
FROM appointments;


/* Check negative waiting days */

SELECT
    COUNT(*) AS negative_waiting_days
FROM appointments
WHERE waiting_days < 0;


/* ============================================================
   9. CATEGORICAL / BINARY VALIDATION
   ============================================================ */


/* Gender */

SELECT
    gender,
    COUNT(*) AS total
FROM appointments
GROUP BY gender
ORDER BY gender;


/* Scholarship */

SELECT
    scholarship,
    COUNT(*) AS total
FROM appointments
GROUP BY scholarship
ORDER BY scholarship;


/* Hypertension */

SELECT
    hypertension,
    COUNT(*) AS total
FROM appointments
GROUP BY hypertension
ORDER BY hypertension;


/* Diabetes */

SELECT
    diabetes,
    COUNT(*) AS total
FROM appointments
GROUP BY diabetes
ORDER BY diabetes;


/* Alcoholism */

SELECT
    alcoholism,
    COUNT(*) AS total
FROM appointments
GROUP BY alcoholism
ORDER BY alcoholism;


/* Handicap */

SELECT
    handicap,
    COUNT(*) AS total
FROM appointments
GROUP BY handicap
ORDER BY handicap;


/* SMS received */

SELECT
    sms_received,
    COUNT(*) AS total
FROM appointments
GROUP BY sms_received
ORDER BY sms_received;


/* ============================================================
   10. NO-SHOW VALIDATION
   ============================================================ */

SELECT
    no_show,
    no_show_binary,
    COUNT(*) AS total
FROM appointments
GROUP BY
    no_show,
    no_show_binary
ORDER BY no_show_binary;


/* No-show percentage */

SELECT
    no_show_binary,
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
   11. AGE GROUP VALIDATION
   ============================================================ */

SELECT
    age_group,
    COUNT(*) AS total
FROM appointments
GROUP BY age_group
ORDER BY total DESC;


/* ============================================================
   12. FINAL DATA QUALITY CHECK
   ============================================================ */

SELECT

    COUNT(*) AS total_rows,

    COUNT(DISTINCT appointment_id)
        AS unique_appointments,

    COUNT(*) - COUNT(DISTINCT appointment_id)
        AS duplicate_appointments,

    SUM(age IS NULL)
        AS missing_age,

    SUM(waiting_days IS NULL)
        AS missing_waiting_days,

    SUM(scheduled_day IS NULL)
        AS missing_scheduled_day,

    SUM(appointment_day IS NULL)
        AS missing_appointment_day,

    SUM(age < 0 OR age > 100)
        AS invalid_age,

    SUM(waiting_days < 0)
        AS negative_waiting_days,

    SUM(no_show_binary = 1)
        AS total_no_show,

    ROUND(
        SUM(no_show_binary = 1) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate

FROM appointments;