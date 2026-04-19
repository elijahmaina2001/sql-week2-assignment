-- ============================================
-- Part 6: SET Operators
-- Databases: nairobi_academy AND city_hospital
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

-- Q1. UNION - unique cities from both students and patients, alphabetically
SELECT city FROM nairobi_academy.students
UNION
SELECT city FROM city_hospital.patients
ORDER BY city ASC;

-- Q2. UNION ALL - student first names and patient full names with source column
SELECT first_name         AS name, 'Student' AS source FROM nairobi_academy.students
UNION ALL
SELECT full_name          AS name, 'Patient' AS source FROM city_hospital.patients;

-- Q3. INTERSECT - cities that appear in BOTH students and patients tables
SELECT city FROM nairobi_academy.students
INTERSECT
SELECT city FROM city_hospital.patients;

-- Q4. UNION ALL - students, patients and doctors combined, ordered by source then name
SELECT CONCAT(first_name, ' ', last_name) AS name, 'Student' AS source 
FROM nairobi_academy.students
UNION ALL
SELECT full_name                          AS name, 'Patient' AS source 
FROM city_hospital.patients
UNION ALL
SELECT full_name                          AS name, 'Doctor'  AS source 
FROM city_hospital.doctors
ORDER BY source ASC, name ASC;