# Subqueries and CTEs

## Writing Cleaner, Smarter SQL


### 1. What is a subquery?

 - A subquery is a SQL query written inside another SQL query. The outer query — called the parent query — uses the result of the subquery as part of its logic. The database always runs the inner query first, then passes its result to the outer query to complete the work.

    - Think of it as a question inside a question. For example: "Which students scored above the class average?" — the inner question is "what is the average mark?" and the outer question is "which students beat that number?" Subqueries can appear in the WHERE clause, the FROM clause, or the SELECT clause.

### 2. Types of subqueries

 - Subqueries are grouped in two ways: by where they sit in the query, and by how they relate to the outer query.

#### Non-correlated subqueries

 - A non-correlated subquery is fully independent — it runs once and returns a fixed result that the outer query uses. The example below finds every exam result where the mark is higher than the overall class average. The inner query calculates that average once, and the outer query filters against it.

nairobi_academy — Q1: WHERE subquery (non-correlated)
SELECT
    student_id,
    marks
FROM exam_results
WHERE marks > (
    SELECT AVG(marks)
    FROM exam_results
);

#### Correlated subqueries

 - A correlated subquery references a column from the outer query, so it re-executes once for every row the outer query processes. The example below uses a correlated subquery inside the SELECT clause to show each student's name alongside the total number of exams they have individually sat.

nairobi_academy — Q3: SELECT subquery (correlated)
SELECT
    s.first_name,
    s.last_name,
    (
        SELECT COUNT(*)
        FROM exam_results er
        WHERE er.student_id = s.student_id  -- references outer query
    ) AS total_exams_sat
FROM students s;


 - Correlated subqueries re-run for every row in the outer query. On a small table like students (10 rows) this is fine. On a table with 100,000 rows it becomes very expensive — consider rewriting as a JOIN or CTE instead.

#### Scalar subquery

 - A scalar subquery returns exactly one value — one row, one column. It can sit in the WHERE clause as a comparison target. The example below finds the student who achieved the single highest mark in the entire exam_results table.

nairobi_academy — Q2: scalar subquery in WHERE
SELECT
    student_id,
    marks
FROM exam_results
WHERE marks = (
    SELECT MAX(marks)
    FROM exam_results
);

#### EXISTS subquery

 - EXISTS is a special form that does not return data — it checks whether at least one matching row exists. As soon as one match is found the database stops looking, making it very efficient for membership checks. The query below returns every subject that has at least one recorded exam result.

nairobi_academy — Q4: EXISTS subquery
SELECT
    subject_id,
    subject_name
FROM subjects s
WHERE EXISTS (
    SELECT 1
    FROM exam_results er
    WHERE er.subject_id = s.subject_id
);

### 3. When to use subqueries

 - Subqueries are a good fit when the logic is simple, the result is only needed once, or you need a quick inline calculation. The example below from city_hospital finds all patients who have attended more than one appointment — a clean use of a WHERE subquery with GROUP BY and HAVING.

city_hospital — Q5: WHERE subquery with GROUP BY / HAVING
SELECT
    patient_id,
    full_name,
    city
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM appointments
    GROUP BY patient_id
    HAVING COUNT(*) > 1
);

### 4. What is a CTE?

 - A Common Table Expression (CTE) is a named, temporary result set defined at the top of a query using the WITH keyword. Unlike a subquery buried inside a clause, a CTE sits clearly at the top, has a meaningful name, and can be referenced multiple times within the same query.

    - CTEs do not create permanent database objects — they exist only for the duration of the single query they are part of. Their main value is readability: breaking complex logic into clearly named steps that any developer can follow.


    - A CTE does not automatically make your query faster. What it does is make your query far easier to read, debug, and maintain — which matters enormously when working in a team or revisiting code months later.

### 5. Types and use cases of CTEs

  - Standard (non-recursive) CTE

- The most common form. One or more named result sets are defined at the top with WITH, then used in the final SELECT. The example below calculates each student's average mark, then filters to show only those averaging above 70.

nairobi_academy — Q7: single CTE — students averaging above 70
WITH student_averages AS (
    SELECT
        student_id,
        ROUND(AVG(marks), 2) AS avg_mark
    FROM exam_results
    GROUP BY student_id
)
SELECT
    s.first_name,
    s.last_name,
    sa.avg_mark
FROM student_averages sa
JOIN students s ON sa.student_id = s.student_id
WHERE sa.avg_mark > 70
ORDER BY sa.avg_mark DESC;

#### Chained CTEs

 - Multiple CTEs can be defined in sequence, separated by commas. Each CTE can reference the ones defined before it, building up the logic step by step like a pipeline. The example below first ranks all results by marks, then isolates only the top result, and finally joins back to get student and subject names.

nairobi_academy — Q8: chained CTEs — rank results, then isolate the top
WITH
ranked_results AS (
    SELECT
        student_id,
        subject_id,
        marks,
        RANK() OVER (ORDER BY marks DESC) AS rank
    FROM exam_results
),
top_result AS (
    SELECT *
    FROM ranked_results
    WHERE rank = 1
)
SELECT
    s.first_name,
    s.last_name,
    sub.subject_name,
    tr.marks
FROM top_result tr
JOIN students s   ON tr.student_id = s.student_id
JOIN subjects sub ON tr.subject_id  = sub.subject_id;

#### CTE for aggregation and filtering

 - CTEs are ideal when you need to aggregate data and then filter on that aggregation. The example from city_hospital counts each doctor's total appointments in the CTE, then the outer query filters to show only doctors who have seen more than one patient.

city_hospital — Q9: CTE — doctors with more than one appointment
WITH doctor_appointment_counts AS (
    SELECT
        doctor_id,
        COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY doctor_id
)
SELECT
    d.full_name       AS doctor_name,
    d.specialisation,
    dac.total_appointments
FROM doctor_appointment_counts dac
JOIN doctors d ON dac.doctor_id = d.doctor_id
WHERE dac.total_appointments > 1
ORDER BY dac.total_appointments DESC;

#### Recursive CTE

 - A recursive CTE is one of the most powerful features in SQL. It allows a query to refer to itself, enabling traversal of hierarchical data — org charts, folder trees, category structures, and any parent-child relationship stored in a self-referencing table.

    - A recursive CTE has two parts joined by UNION ALL: the anchor member (the starting point) and the recursive member (the step that builds on the previous result). The database keeps running the recursive step until no new rows are produced.

    - The doctors table in city_hospital has a supervisor_id column that points back to another doctor — a perfect hierarchy. The query below walks that structure from the top (doctors with no supervisor) all the way down, adding indentation to show depth.

city_hospital — Q10: recursive CTE — doctor supervision hierarchy
WITH RECURSIVE doctor_hierarchy AS (

    -- Anchor: doctors with no supervisor (top of the chain)
    SELECT
        doctor_id,
        full_name,
        supervisor_id,
        specialisation,
        0 AS level
    FROM doctors
    WHERE supervisor_id IS NULL

    UNION ALL

    -- Recursive: find each doctor supervised by someone already in the result
    SELECT
        d.doctor_id,
        d.full_name,
        d.supervisor_id,
        d.specialisation,
        dh.level + 1 AS level
    FROM doctors d
    JOIN doctor_hierarchy dh ON d.supervisor_id = dh.doctor_id
)
SELECT
    level,
    REPEAT('    ', level) || full_name AS doctor_name,
    specialisation
FROM doctor_hierarchy
ORDER BY level, doctor_id;

### WHAT THE RECURSIVE CTE PRODUCES

- Level 0 shows the two top-level doctors (no supervisor). Level 1 shows the doctors they supervise. Level 2 shows the doctors supervised by level 1 — and so on down the chain. The REPEAT function adds visual indentation to make the hierarchy easy to read.

### 6. Subqueries vs. CTEs: full comparison
 - Both tools achieve similar outcomes, but they differ in readability, reusability, and how well they suit complex logic. Here is a direct side-by-side comparison.

<img width="1063" height="950" alt="image" src="/snipping.JPG" />

The same logic — two ways
Both queries below answer the same question: show each appointment alongside the overall average fee. The subquery version embeds the calculation inline inside the SELECT. The CTE version names it clearly at the top. The result is identical — the difference is entirely in readability.

city_hospital — Q6: scalar subquery in SELECT
SELECT
    appointment_id,
    patient_id,
    fee,
    (
        SELECT ROUND(AVG(fee), 2)
        FROM appointments
    ) AS avg_fee_overall
FROM appointments;

city_hospital — same logic rewritten as a CTE
WITH overall_avg AS (
    SELECT ROUND(AVG(fee), 2) AS avg_fee
    FROM appointments
)
SELECT
    a.appointment_id,
    a.patient_id,
    a.fee,
    oa.avg_fee AS avg_fee_overall
FROM appointments a
CROSS JOIN overall_avg oa;

When to reach for each one

- Use CTE when	The logic has multiple steps, the result needs to be referenced more than once, you want the query to be readable by others, or you need recursion to traverse a hierarchy.

    - Use subquery when	The logic is simple and used only once — a quick scalar comparison, an IN filter, or an EXISTS check where a CTE would add unnecessary length.

    - Avoid deep nesting	More than two levels of nested subqueries is a red flag. At that point, a CTE will almost always produce cleaner, easier-to-debug code.

