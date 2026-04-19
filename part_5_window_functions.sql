-- ============================================
-- Part 5: Window Functions
-- Database: nairobi_academy
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

SET search_path TO nairobi_academy;

-- Q1. ROW_NUMBER() - unique rank for each exam result, highest mark to lowest
SELECT 
    result_id,
    student_id,
    marks,
    ROW_NUMBER() OVER (ORDER BY marks DESC) AS row_num
FROM exam_results;

-- Q2. RANK() and DENSE_RANK() side by side, marks descending
SELECT 
    result_id,
    marks,
    RANK()       OVER (ORDER BY marks DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY marks DESC) AS dense_rank
FROM exam_results;

-- Q3. NTILE(3) - divide results into 3 performance bands
SELECT 
    result_id,
    marks,
    NTILE(3) OVER (ORDER BY marks DESC) AS band
FROM exam_results;

-- Q4. AVG() OVER PARTITION BY student_id - each result with student's personal average
SELECT 
    student_id,
    marks,
    ROUND(AVG(marks) OVER (PARTITION BY student_id), 2) AS student_avg
FROM exam_results;

-- Q5. LAG() - each result alongside previous result's marks and improvement
SELECT 
    student_id,
    result_id,
    marks,
    LAG(marks) OVER (PARTITION BY student_id ORDER BY result_id) AS previous_marks,
    marks - LAG(marks) OVER (PARTITION BY student_id ORDER BY result_id) AS improvement
FROM exam_results;