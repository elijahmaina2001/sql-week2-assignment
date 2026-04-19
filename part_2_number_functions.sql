-- ============================================
-- Part 2: Number Functions
-- Database: nairobi_academy
-- Name: Elijah Maina
-- Date: 19/4/2026
-- ============================================

SET search_path TO nairobi_academy;

-- Q1. Each exam result with mark rounded, rounded UP and rounded DOWN
SELECT 
    result_id,
    marks,
    ROUND(marks, 1)          AS rounded_mark,
    CEIL(marks / 10.0) * 10  AS rounded_up,
    FLOOR(marks / 10.0) * 10 AS rounded_down
FROM exam_results;

-- Q2. Summary statistics for exam_results in one query
SELECT 
    COUNT(*)                    AS total_results,
    ROUND(AVG(marks), 2)        AS average_mark,
    MAX(marks)                  AS highest_mark,
    MIN(marks)                  AS lowest_mark,
    SUM(marks)                  AS total_marks
FROM exam_results;

-- Q3. Each result with original marks and 10% boosted mark
SELECT 
    result_id,
    marks                            AS original_marks,
    ROUND(marks * 1.10)              AS boosted_mark
FROM exam_results;