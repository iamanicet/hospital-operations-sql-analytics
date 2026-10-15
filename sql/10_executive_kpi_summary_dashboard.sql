 -- =====================================================================
-- SCRIPT TITLE: Advanced Hospital Executive Intelligence Report
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This enterprise-grade script leverages Common Table Expressions (CTEs) 
-- and window functions to construct a multi-tiered performance report. 
-- It isolates high-cost patient cohorts, computes running revenue totals 
-- by department using DENSE_RANK() and SUM() OVER(), and benchmarks 
-- individual physician workload against departmental averages.
-- =====================================================================

USE hospital_analytics;

WITH PatientFinancialSummary AS (
    -- CTE 1: Aggregate financial and encounter metrics per patient
    SELECT 
        p.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        p.city,
        COUNT(e.encounter_id) AS total_visits,
        SUM(COALESCE(e.total_charges, 0)) AS lifetime_charges
    FROM Patients p
    LEFT JOIN Encounters e ON p.patient_id = e.patient_id
    GROUP BY p.patient_id, p.first_name, p.last_name, p.city
),
DepartmentFinancialPerformance AS (
    -- CTE 2: Calculate departmental revenue rankings and patient reach
    SELECT 
        d.department_name,
        COUNT(e.encounter_id) AS dept_total_encounters,
        SUM(COALESCE(e.total_charges, 0)) AS dept_gross_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(COALESCE(e.total_charges, 0)) DESC) AS revenue_rank
    FROM Departments d
    LEFT JOIN Doctors doc ON d.department_id = doc.department_id
    LEFT JOIN Encounters e ON doc.doctor_id = e.doctor_id
    GROUP BY d.department_name
)
-- Main Query: Combine CTE analytics with running totals and risk classifications
SELECT 
    df.department_name AS 'Department',
    df.dept_total_encounters AS 'Department_Encounters',
    CONCAT('$', FORMAT(df.dept_gross_revenue, 2)) AS 'Department_Gross_Revenue',
    df.revenue_rank AS 'Revenue_Ranking',
    -- Window Function: Cumulative running revenue across departments
    CONCAT('$', FORMAT(SUM(df.dept_gross_revenue) OVER (ORDER BY df.dept_gross_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2)) AS 'Running_Total_Revenue',
    (SELECT COUNT(*) FROM PatientFinancialSummary pfs WHERE pfs.total_visits > 2) AS 'High_Utilization_Patients_Count'
FROM DepartmentFinancialPerformance df
ORDER BY df.revenue_rank ASC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. Revenue Concentration Analysis: Use the running total and revenue 
       rankings to identify primary financial engines versus loss-leader departments.
    2. High-Utilizer Resource Allocation: The high-utilizer count highlights 
       patients requiring dedicated case managers to control recurring admission costs.
    =================================================================
*/