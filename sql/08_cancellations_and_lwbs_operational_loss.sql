-- =====================================================================
-- SCRIPT TITLE: Scheduled Cancellations and LWBS Operational Loss Analysis
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script quantifies non-completed patient encounters, specifically 
-- focusing on cancelled scheduled appointments and Left Without Being Seen (LWBS) 
-- events in the Emergency Department. Identifying these non-realized encounters 
-- helps operational leaders minimize capacity waste and address patient satisfaction 
-- bottlenecks.
-- =====================================================================

USE hospital_analytics;

SELECT 
    e.encounter_type AS 'Encounter_Type',
    e.encounter_status AS 'Encounter_Status',
    e.discharge_disposition AS 'Discharge_Disposition',
    COUNT(e.encounter_id) AS 'Total_Encounters',
    -- Total unrealized billed charges associated with non-completed encounters
    SUM(COALESCE(e.total_charges, 0)) AS 'Unrealized_Charges_USD'
FROM Encounters e
WHERE e.encounter_status = 'Cancelled'
   OR e.discharge_disposition = 'Left Without Being Seen'
GROUP BY e.encounter_type, e.encounter_status, e.discharge_disposition
ORDER BY Total_Encounters DESC;

/*
    =================================================================
    MANAGEMENT RECOMMENDATION & ACTION PLAN:
    1. LWBS Mitigation: Patients leaving the Emergency Department without being 
       seen indicate severe triage or waiting area bottlenecks. Implementing a 
       rapid triage system can help retain vulnerable patients.
    2. Cancellation Management: High outpatient cancellation rates lead to idle 
       provider hours. Automated SMS appointment reminders and flexible rescheduling 
       protocols should be instituted to improve completed visit ratios.
    =================================================================
*/