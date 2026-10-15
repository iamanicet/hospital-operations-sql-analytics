-- =====================================================================
-- SCRIPT TITLE: Emergency Department Wait Time Outlier Detection
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script identifies critical operational bottlenecks by filtering 
-- emergency encounters where the wait time from arrival to provider contact 
-- exceeds 60 minutes. It helps clinical leadership pinpoint staffing 
-- shortages and triage delays during peak volume hours.
-- =====================================================================

USE hospital_analytics;

SELECT 
    encounter_id AS 'Encounter_ID',
    patient_id AS 'Patient_ID',
    triage_level AS 'ESI_Acuity',
    arrival_datetime AS 'Arrival_Timestamp',
    provider_start_datetime AS 'Provider_Contact_Timestamp',
    -- Calculate exact wait time in minutes before provider evaluation
    TIMESTAMPDIFF(MINUTE, arrival_datetime, provider_start_datetime) AS 'Wait_Time_Mins',
    discharge_disposition AS 'Discharge_Disposition'
FROM Encounters
WHERE encounter_type = 'Emergency'
  AND provider_start_datetime IS NOT NULL
  AND TIMESTAMPDIFF(MINUTE, arrival_datetime, provider_start_datetime) > 60
ORDER BY Wait_Time_Mins DESC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. Critical Delay Investigation: Emergency cases experiencing over 60 minutes 
       of wait time represent severe clinical risk. Immediate root-cause 
       analysis is required for these specific encounters.
    2. Dynamic Staffing: Deploy float nursing and secondary provider coverage 
       during peak arrival windows to compress initial evaluation delays.
    =================================================================
*/