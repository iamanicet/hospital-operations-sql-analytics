-- =====================================================================
-- SCRIPT TITLE: Emergency Department Volume, Wait Times, and Acuity Analysis
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script evaluates Emergency Department (ED) operational efficiency 
-- by analyzing patient volume, average provider wait times, total length 
-- of stay (LOS), and Left Without Being Seen (LWBS) rates across ESI acuity 
-- levels (1-5). Aggregate functions group data to help leadership 
-- identify clinical bottlenecks and resource misallocations.
-- =====================================================================

USE hospital_analytics;

SELECT 
    triage_level AS 'Acuity_Level_ESI',
    COUNT(encounter_id) AS 'Total_Encounters',
    -- Calculate average wait time from arrival to first provider contact (mins)
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, arrival_datetime, provider_start_datetime)), 1) AS 'Avg_Wait_To_Provider_Mins',
    -- Calculate average total ED length of stay from arrival to physical departure (mins)
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, arrival_datetime, ed_departure_datetime)), 1) AS 'Avg_Total_ED_Stay_Mins',
    -- Count patients who left the ED before receiving clinical evaluation
    SUM(CASE WHEN discharge_disposition = 'Left Without Being Seen' THEN 1 ELSE 0 END) AS 'LWBS_Count'
FROM Encounters
WHERE encounter_type = 'Emergency'
  AND triage_level IS NOT NULL
GROUP BY triage_level
ORDER BY triage_level ASC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN :
    1. Triage Optimization: ESI levels 3 through 5 show extended wait times 
       before provider contact. Establishing a dedicated "Fast Track" lane 
       for non-urgent cases will alleviate congestion in acute bays.
    2. Risk Mitigation: Monitor LWBS counts closely in semi-urgent cohorts. 
       Reducing wait times in these brackets directly improves patient safety 
       outcomes and clinical reputation.
    =================================================================
*/