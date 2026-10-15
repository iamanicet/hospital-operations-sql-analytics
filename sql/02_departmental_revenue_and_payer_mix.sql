-- =====================================================================
-- SCRIPT TITLE: Departmental Revenue and Payer Realization Analysis
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script evaluates financial performance by aggregating total billed 
-- charges and expected reimbursements across different hospital departments 
-- and payer classifications. It helps finance leadership identify revenue 
-- concentrations, realization efficiency, and exposure to self-pay/uninsured 
-- accounts.
-- =====================================================================

USE hospital_analytics;

SELECT 
    d.department_name AS 'Department',
    e.payer_type AS 'Payer_Classification',
    COUNT(e.encounter_id) AS 'Total_Encounters',
    -- Total charges billed to patients or payers
    SUM(e.total_charges) AS 'Total_Billed_Charges_USD',
    -- Expected insurer/payer reimbursement amount
    SUM(e.expected_reimbursement) AS 'Expected_Reimbursement_USD',
    -- Calculate realization rate percentage to measure collection efficiency
    ROUND(
        (SUM(e.expected_reimbursement) / NULLIF(SUM(e.total_charges), 0)) * 100, 
        2
    ) AS 'Reimbursement_Realization_Pct'
FROM Encounters e
INNER JOIN Departments d ON e.department_id = d.department_id
WHERE e.encounter_status = 'Completed'
  AND e.total_charges IS NOT NULL
GROUP BY d.department_name, e.payer_type
ORDER BY d.department_name ASC, Total_Billed_Charges_USD DESC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN :
    1. Revenue Concentration: Commercial payers yield the highest absolute 
       reimbursement rates, particularly in surgical and cardiology departments.
    2. Self-Pay Exposure: Self-pay encounters show significantly lower 
       realization rates. Finance should evaluate expanding financial 
       counseling and early-out patient assistance programs for self-pay cohorts 
       to mitigate bad debt risk.
    =================================================================
*/