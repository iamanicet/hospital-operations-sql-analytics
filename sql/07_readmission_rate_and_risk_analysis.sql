-- =====================================================================
-- SCRIPT TITLE: Readmission Rate and Patient Risk Analysis
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script evaluates clinical quality and patient retention by identifying 
-- repeat hospital visits within the dataset. It calculates the total number 
-- of encounters per patient to highlight high-utilizer patient cohorts, 
-- supporting targeted care management and post-discharge outreach programs.
-- =====================================================================

USE hospital_analytics;

SELECT 
    p.patient_id AS 'Patient_ID',
    CONCAT(p.first_name, ' ', p.last_name) AS 'Patient_Name',
    p.city AS 'Patient_City',
    COUNT(e.encounter_id) AS 'Total_Visits',
    MAX(e.arrival_datetime) AS 'Most_Recent_Visit'
FROM Patients p
INNER JOIN Encounters e ON p.patient_id = e.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name, p.city
HAVING COUNT(e.encounter_id) > 1
ORDER BY Total_Visits DESC, Most_Recent_Visit DESC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. High-Utilizer Intervention: Patients with multiple visits should be 
       enrolled in proactive post-discharge follow-up programs to reduce 
       unplanned readmissions and lower overall cost of care.
    2. Primary Care Alignment: Coordinate with outpatient clinics in top 
       cities to strengthen chronic disease management and prevent acute ER visits.
    =================================================================
*/