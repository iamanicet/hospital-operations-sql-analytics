-- =====================================================================
-- SCRIPT TITLE: Peak Arrival Hours and Facility Capacity Planning
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script analyzes patient arrival patterns across 24-hour time 
-- blocks to identify peak volume surges. By extracting arrival hours 
-- from encounters, clinical managers can align shift scheduling, triage 
-- staffing, and bed turnover protocols directly with patient influx peaks.
-- =====================================================================

USE hospital_analytics;

SELECT 
    HOUR(arrival_datetime) AS 'Arrival_Hour_24h',
    COUNT(encounter_id) AS 'Total_Arrivals',
    SUM(CASE WHEN encounter_type = 'Emergency' THEN 1 ELSE 0 END) AS 'Emergency_Arrivals',
    SUM(CASE WHEN encounter_type = 'Inpatient' THEN 1 ELSE 0 END) AS 'Inpatient_Arrivals',
    SUM(CASE WHEN encounter_type = 'Outpatient' THEN 1 ELSE 0 END) AS 'Outpatient_Arrivals'
FROM Encounters
WHERE arrival_datetime IS NOT NULL
GROUP BY HOUR(arrival_datetime)
ORDER BY Total_Arrivals DESC, Arrival_Hour_24h ASC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. Shift Optimization: Staffing schedules should be adjusted to match 
       identified surge hours, ensuring adequate nursing and physician coverage 
       during high-volume arrival periods.
    2. Capacity Management: High-density arrival windows for inpatient care 
       require streamlined registration and bed assignment workflows to prevent 
       admissions bottlenecks.
    =================================================================
*/