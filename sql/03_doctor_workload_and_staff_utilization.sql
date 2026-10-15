-- =====================================================================
-- SCRIPT TITLE: Doctor Workload and Patient Volume Distribution
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script evaluates clinical staffing distribution and physician 
-- utilization by analyzing the total number of encounters handled per 
-- doctor, broken down by department and active status. It utilizes a 
-- LEFT JOIN to ensure all active and inactive physicians are accounted 
-- for, even those with zero assigned encounters.
-- =====================================================================

USE hospital_analytics;

SELECT 
    d.department_name AS 'Department',
    CONCAT(doc.first_name, ' ', doc.last_name) AS 'Physician_Name',
    doc.specialty AS 'Specialty',
    CASE WHEN doc.is_active = 1 THEN 'Active' ELSE 'Inactive' END AS 'Employment_Status',
    -- Count total encounters assigned to each physician
    COUNT(e.encounter_id) AS 'Total_Encounters_Handled',
    -- Count unique patients treated by the doctor to measure patient reach
    COUNT(DISTINCT e.patient_id) AS 'Unique_Patients_Seen'
FROM Doctors doc
INNER JOIN Departments d ON doc.department_id = d.department_id
LEFT JOIN Encounters e ON doc.doctor_id = e.doctor_id
GROUP BY doc.doctor_id, d.department_name, doc.first_name, doc.last_name, doc.specialty, doc.is_active
ORDER BY Total_Encounters_Handled DESC, d.department_name ASC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN :
    1. Workload Balancing: High encounter disparities exist among emergency 
       and cardiology physicians. Human resources should balance shift 
       allocations to prevent physician burnout.
    2. Inactive Staff Audit: Utilizing LEFT JOIN successfully flags physicians 
       who have left or have zero encounters. Ensure offboarding workflows 
       and license reassignments are systematically updated.
    =================================================================
*/