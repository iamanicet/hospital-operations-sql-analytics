-- =====================================================================
-- SCRIPT TITLE: Inpatient Length of Stay and Discharge Disposition Analysis
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script evaluates inpatient operational efficiency by calculating 
-- the length of stay (in days) from admission to discharge, grouped by 
-- discharge disposition. It helps hospital leadership track bed turnover rates 
-- and discharge bottlenecks.
-- =====================================================================

USE hospital_analytics;

SELECT 
    discharge_disposition AS 'Discharge_Disposition',
    COUNT(encounter_id) AS 'Total_Inpatient_Encounters',
    -- Calculate average length of stay in days from admission to discharge
    ROUND(AVG(TIMESTAMPDIFF(HOUR, admission_datetime, discharge_datetime)) / 24, 1) AS 'Avg_Length_Of_Stay_Days',
    -- Calculate maximum length of stay to identify outlier cases
    ROUND(MAX(TIMESTAMPDIFF(HOUR, admission_datetime, discharge_datetime)) / 24, 1) AS 'Max_Length_Of_Stay_Days'
FROM Encounters
WHERE encounter_type = 'Inpatient'
  AND admission_datetime IS NOT NULL
  AND discharge_datetime IS NOT NULL
GROUP BY discharge_disposition
ORDER BY Total_Inpatient_Encounters DESC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. Bed Turnover Efficiency: Monitor average length of stay for routine 
       home discharges to ensure beds are cleared rapidly for incoming admissions.
    2. Outlier Management: Investigate cases with maximum length of stay outliers 
       to identify potential clinical complications or delayed discharge planning.
    =================================================================
*/