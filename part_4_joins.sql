-- ============================================
-- Part 4: SQL JOINS
-- Database: city_hospital
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

SET search_path TO city_hospital;

-- Q1. INNER JOIN - each appointment with patient name, doctor name, date and diagnosis
SELECT 
    p.full_name        AS patient_name,
    d.full_name        AS doctor_name,
    a.appt_date,
    a.diagnosis
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id
INNER JOIN doctors  d ON a.doctor_id  = d.doctor_id;

-- Q2. LEFT JOIN - ALL patients, show appointment date and diagnosis if they have one
SELECT 
    p.full_name        AS patient_name,
    a.appt_date,
    a.diagnosis
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id;

-- Q3. RIGHT JOIN - ALL doctors, show patient name if they have seen one
SELECT 
    d.full_name        AS doctor_name,
    p.full_name        AS patient_name
FROM appointments a
RIGHT JOIN doctors  d ON a.doctor_id  = d.doctor_id
LEFT JOIN  patients p ON a.patient_id = p.patient_id;

-- Q4. LEFT JOIN + WHERE IS NULL - patients who have NEVER had an appointment
SELECT 
    p.full_name,
    p.city
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;

-- Q5. Three-table INNER JOIN - appointment with patient, doctor and medicine
SELECT 
    a.appointment_id,
    p.full_name        AS patient_name,
    d.full_name        AS doctor_name,
    pr.medicine_name
FROM appointments a
INNER JOIN patients      p  ON a.patient_id     = p.patient_id
INNER JOIN doctors       d  ON a.doctor_id      = d.doctor_id
INNER JOIN prescriptions pr ON a.appointment_id = pr.appointment_id;