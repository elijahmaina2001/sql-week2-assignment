-- ============================================
-- Part 1: String Functions
-- Database: nairobi_academy
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

SET search_path TO nairobi_academy;

-- Q1. Full name in UPPERCASE and city in lowercase
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS upper_name,
    LOWER(city)                               AS lower_city
FROM students;

-- Q2. First name and its length, ordered longest to shortest
SELECT 
    first_name,
    LENGTH(first_name) AS name_length
FROM students
ORDER BY name_length DESC;

-- Q3. Subject name, first 4 characters as short_name, and full name length
SELECT 
    subject_name,
    LEFT(subject_name, 4)      AS short_name,
    LENGTH(subject_name)       AS name_length
FROM subjects;

-- Q4. CONCAT to produce a student summary sentence
SELECT 
    CONCAT(first_name, ' ', last_name, ' is in ', class, ' and comes from ', city) AS student_summary
FROM students;