-- ============================================
-- Part 3: Date & Time Functions
-- Database: nairobi_academy
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

SET search_path TO nairobi_academy;

-- Q1. Extract birth year, birth month, and birth day from date_of_birth
SELECT 
    first_name,
    EXTRACT(YEAR  FROM date_of_birth) AS birth_year,
    EXTRACT(MONTH FROM date_of_birth) AS birth_month,
    EXTRACT(DAY   FROM date_of_birth) AS birth_day
FROM students;

-- Q2. Full name, date_of_birth and age in complete years, oldest to youngest
SELECT 
    CONCAT(first_name, ' ', last_name)        AS full_name,
    date_of_birth,
    EXTRACT(YEAR FROM AGE(date_of_birth))      AS age
FROM students
ORDER BY date_of_birth ASC;

-- Q3. Format each exam date as 'Friday, 15th March 2024'
SELECT 
    TO_CHAR(exam_date, 'FMDay, DDth Month YYYY') AS formatted_date
FROM exam_results;