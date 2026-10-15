-- =====================================================================
-- SCRIPT TITLE: Hospital Operations & Patient Flow Analytics (Extended Seed)
-- AUTHOR: Anicet Baraka Ciza | Senior Data Analyst Review
--
-- MANAGER REPORT & TECHNICAL COMMENTS:
-- This script extends the base dataset from 01_hospital_setup.sql by 
-- adding critical operational columns (triage level, departure times, 
-- financial charges, and expected reimbursements). It also seeds 
-- extended patient records and comprehensive encounter logs to support 
-- advanced analytics and throughput performance reporting.
-- =====================================================================

USE hospital_analytics;

-- ---------------------------------------------------------------------
-- SECTION 1: Schema extensions
-- ---------------------------------------------------------------------
ALTER TABLE Encounters
    ADD COLUMN triage_level             TINYINT UNSIGNED NULL AFTER discharge_disposition,
    ADD COLUMN ed_departure_datetime   DATETIME NULL AFTER triage_level,
    ADD COLUMN total_charges            DECIMAL(10,2) NULL AFTER ed_departure_datetime,
    ADD COLUMN expected_reimbursement   DECIMAL(10,2) NULL AFTER total_charges;

ALTER TABLE Encounters
    ADD CONSTRAINT chk_encounters_triage_level
        CHECK (triage_level IS NULL OR triage_level BETWEEN 1 AND 5),
    ADD CONSTRAINT chk_encounters_ed_departure_after_arrival
        CHECK (ed_departure_datetime IS NULL OR ed_departure_datetime >= arrival_datetime),
    ADD CONSTRAINT chk_encounters_charges_nonnegative
        CHECK (total_charges IS NULL OR total_charges >= 0),
    ADD CONSTRAINT chk_encounters_reimbursement_nonnegative
        CHECK (expected_reimbursement IS NULL OR expected_reimbursement >= 0);

-- ---------------------------------------------------------------------
-- SECTION 2: Backfill the 16 base encounters (1001-1016)
-- ED departure = admission time if admitted, otherwise discharge time.
-- Key-based WHERE clauses keep MySQL Workbench safe-update mode happy.
-- ---------------------------------------------------------------------
UPDATE Encounters
SET ed_departure_datetime = COALESCE(admission_datetime, discharge_datetime)
WHERE encounter_id BETWEEN 1001 AND 1016
  AND encounter_type = 'Emergency';

UPDATE Encounters SET triage_level = 3, total_charges = 3245.00, expected_reimbursement = 1993.21 WHERE encounter_id = 1001;
UPDATE Encounters SET triage_level = 4, total_charges = 150.00, expected_reimbursement = 56.48 WHERE encounter_id = 1002;
UPDATE Encounters SET total_charges = 16766.00, expected_reimbursement = 7021.86 WHERE encounter_id = 1003;
UPDATE Encounters SET total_charges = 734.00, expected_reimbursement = 436.81 WHERE encounter_id = 1004;
UPDATE Encounters SET triage_level = 2, total_charges = 20238.00, expected_reimbursement = 8941.75 WHERE encounter_id = 1005;
UPDATE Encounters SET total_charges = 498.00, expected_reimbursement = 332.75 WHERE encounter_id = 1006;
UPDATE Encounters SET total_charges = 22005.00, expected_reimbursement = 7052.07 WHERE encounter_id = 1007;
UPDATE Encounters SET triage_level = 2, total_charges = 9984.00, expected_reimbursement = 4115.82 WHERE encounter_id = 1008;
UPDATE Encounters SET triage_level = 4, total_charges = 2768.00, expected_reimbursement = 352.90 WHERE encounter_id = 1009;
UPDATE Encounters SET total_charges = 23643.00, expected_reimbursement = 11592.75 WHERE encounter_id = 1010;
UPDATE Encounters SET total_charges = 312.00, expected_reimbursement = 209.60 WHERE encounter_id = 1011;
UPDATE Encounters SET triage_level = 3, total_charges = 3427.00, expected_reimbursement = 2227.12 WHERE encounter_id = 1012;
UPDATE Encounters SET total_charges = 30503.00, expected_reimbursement = 14268.13 WHERE encounter_id = 1013;
UPDATE Encounters SET total_charges = 311.00, expected_reimbursement = 110.04 WHERE encounter_id = 1014;
UPDATE Encounters SET triage_level = 2, total_charges = 16480.00, expected_reimbursement = 6253.92 WHERE encounter_id = 1015;
UPDATE Encounters SET total_charges = 633.00, expected_reimbursement = 386.86 WHERE encounter_id = 1016;

-- ---------------------------------------------------------------------
-- SECTION 3: Additional patients (ids 11-60)
-- ---------------------------------------------------------------------
INSERT INTO Patients (patient_id, first_name, last_name, date_of_birth, sex, city) VALUES
    (11, 'Aria', 'Ellis', '1950-12-10', 'Male', 'Lakeview'),
    (12, 'Violet', 'Graham', '1962-06-24', 'Female', 'Lakeview'),
    (13, 'Michael', 'Bryant', '1966-09-15', 'Male', 'Lakeview'),
    (14, 'Zoe', 'Webb', '1996-11-22', 'Female', 'Hillcrest'),
    (15, 'Lily', 'Cruz', '2005-02-03', 'Female', 'Riverton'),
    (16, 'Hazel', 'Reynolds', '2006-03-23', 'Male', 'Riverton'),
    (17, 'Benjamin', 'Murphy', '1967-05-02', 'Female', 'Hillcrest'),
    (18, 'Ella', 'Fisher', '1941-05-02', 'Male', 'Riverton'),
    (19, 'David', 'Foster-Ray', '1942-01-13', 'Other', 'Riverton'),
    (20, 'Nathan', 'Sullivan', '1978-11-17', 'Female', 'Riverton'),
    (21, 'Daniel', 'Hughes', '2008-01-03', 'Male', 'Hillcrest'),
    (22, 'Amelia', 'Cole', '1953-04-22', 'Female', 'Hillcrest'),
    (23, 'Gabriel', 'Powell', '2005-02-09', 'Female', 'Hillcrest'),
    (24, 'Luke', 'Marshall', '2002-01-18', 'Female', 'Lakeview'),
    (25, 'Jacob', 'Myers', '1971-03-28', 'Female', 'Riverton'),
    (26, 'Scarlett', 'Harrison', '1996-06-14', 'Other', 'Hillcrest'),
    (27, 'William', 'Wells', '1970-07-24', 'Unknown', 'Riverton'),
    (28, 'Mason', 'Butler', '1965-05-26', 'Female', 'Lakeview'),
    (29, 'Carter', 'Owens', '1978-05-24', 'Female', 'Hillcrest'),
    (30, 'Anthony', 'Simpson', '1968-11-02', 'Male', 'Lakeview'),
    (31, 'Jack', 'Flores', '1957-11-27', 'Female', 'Riverton'),
    (32, 'Victoria', 'Hayes', '1996-12-08', 'Male', 'Hillcrest'),
    (33, 'Elijah', 'West', '1987-03-05', 'Male', 'Riverton'),
    (34, 'Grace', 'Coleman', '1977-04-07', 'Male', 'Hillcrest'),
    (35, 'Chloe', 'Jenkins', '1987-08-07', 'Female', 'Hillcrest'),
    (36, 'Stella', 'Murray', '2005-05-08', 'Male', 'Lakeview'),
    (37, 'Naomi', 'Perry', '1982-07-01', 'Male', 'Hillcrest'),
    (38, 'Samuel', 'Jordan', '1972-05-27', 'Female', 'Lakeview'),
    (39, 'Riley', 'McDonald', '1959-04-05', 'Female', 'Hillcrest'),
    (40, 'Layla', 'Ford', '1945-02-15', 'Male', 'Hillcrest'),
    (41, 'Abigail', 'Tucker', '1980-10-09', 'Female', 'Riverton'),
    (42, 'Caleb', 'Diaz', '1958-10-15', 'Female', 'Hillcrest'),
    (43, 'Isaac', 'Woods', '1970-05-14', 'Female', 'Hillcrest'),
    (44, 'Nora', 'Hamilton', '1938-04-13', 'Female', 'Hillcrest'),
    (45, 'Wyatt', 'Griffin', '1967-12-14', 'Male', 'Riverton'),
    (46, 'Oliver', 'Wallace', '1967-07-26', 'Male', 'Lakeview'),
    (47, 'Logan', 'Patterson', '1947-03-10', 'Male', 'Lakeview'),
    (48, 'Hannah', 'Porter', '1940-01-23', 'Male', 'Hillcrest'),
    (49, 'Charlotte', 'Simmons', '2000-04-26', 'Male', 'Riverton'),
    (50, 'Emily', 'Long', '1975-11-08', 'Male', 'Lakeview'),
    (51, 'Owen', 'Stevens', '1987-11-20', 'Female', 'Lakeview'),
    (52, 'Evelyn', 'Hughes-Lane', '1998-03-09', 'Male', 'Hillcrest'),
    (53, 'Emma', 'Freeman', '1985-12-09', 'Female', 'Hillcrest'),
    (54, 'Aurora', 'Gonzales', '1987-08-15', 'Female', 'Riverton'),
    (55, 'Leo', 'Russell', '2008-11-21', 'Male', 'Hillcrest'),
    (56, 'Harper', 'Ortiz', '1955-12-22', 'Male', 'Riverton'),
    (57, 'Joseph', 'Washington', '1938-01-06', 'Male', 'Riverton'),
    (58, 'Julian', 'Gomez', '1993-01-13', 'Male', 'Riverton'),
    (59, 'Dylan', 'Gibson', '1959-08-06', 'Female', 'Hillcrest'),
    (60, 'Penelope', 'Alexander', '1950-05-25', 'Male', 'Hillcrest');

-- ---------------------------------------------------------------------
-- SECTION 4: Additional doctors
-- ---------------------------------------------------------------------
INSERT INTO Doctors (doctor_id, department_id, first_name, last_name, specialty, email, is_active) VALUES
    (7, 1, 'Rachel', 'Nguyen', 'Emergency Medicine', 'rachel.nguyen@example.org', TRUE),
    (8, 1, 'Victor', 'Alvarez', 'Emergency Medicine', 'victor.alvarez@example.org', FALSE),
    (9, 3, 'Hannah', 'Lee', 'Orthopedic Surgery', 'hannah.lee@example.org', TRUE),
    (10, 4, 'Samuel', 'Mensah', 'Internal Medicine', 'samuel.mensah@example.org', TRUE);

-- ---------------------------------------------------------------------
-- SECTION 5: Extended encounters (ids 2001+)
-- ---------------------------------------------------------------------
INSERT INTO Encounters (
    encounter_id, patient_id, department_id, doctor_id, encounter_type, encounter_status,
    arrival_mode, payer_type, chief_complaint, arrival_datetime, triage_datetime,
    provider_start_datetime, admission_datetime, discharge_datetime, discharge_disposition,
    triage_level, ed_departure_datetime, total_charges, expected_reimbursement
) VALUES
    (2001, 40, 2, 3, 'Inpatient', 'Completed', 'Referral', 'Medicare', 'Arrhythmia', '2025-01-01 10:51:00', NULL, '2025-01-01 11:27:00', '2025-01-01 12:16:00', '2025-01-04 15:16:00', 'Home', NULL, NULL, 21534.00, 9685.84),
    (2002, 13, 1, 8, 'Emergency', 'Completed', 'Ambulance', 'Medicaid', 'Shortness of breath', '2025-01-01 18:52:00', '2025-01-01 18:58:00', '2025-01-01 19:05:00', '2025-01-01 22:02:00', '2025-01-06 04:02:00', 'Admitted', 1, '2025-01-01 22:02:00', 20725.00, 6852.13),
    (2003, 9, 3, 5, 'Inpatient', 'Completed', 'Referral', 'Medicare', 'Spinal fusion', '2025-01-02 11:49:00', NULL, '2025-01-02 12:11:00', '2025-01-02 13:15:00', '2025-01-07 22:15:00', 'Home', NULL, NULL, 35192.00, 16855.83),
    (2004, 36, 1, 2, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Sepsis concern', '2025-01-03 01:06:00', '2025-01-03 01:14:00', '2025-01-03 01:29:00', NULL, '2025-01-03 02:20:00', 'Home', 2, '2025-01-03 02:20:00', 3674.00, 2253.01),
    (2005, 27, 1, 2, 'Emergency', 'Completed', 'Ambulance', 'Other', 'Severe trauma', '2025-01-03 07:43:00', '2025-01-03 07:51:00', '2025-01-03 08:03:00', '2025-01-03 11:39:00', '2025-01-08 23:39:00', 'Admitted', 2, '2025-01-03 11:39:00', 23060.00, 11514.66),
    (2006, 14, 2, 4, 'Observation', 'Completed', 'Scheduled', 'Medicaid', 'Syncope observation', '2025-01-03 16:23:00', NULL, '2025-01-03 16:57:00', '2025-01-03 17:45:00', '2025-01-04 08:17:00', 'Home', NULL, NULL, 4284.67, 1459.23),
    (2007, 32, 1, 1, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Vomiting and diarrhea', '2025-01-04 17:47:00', '2025-01-04 18:02:00', '2025-01-04 19:04:00', NULL, '2025-01-04 22:11:00', 'Home', 3, '2025-01-04 22:11:00', 3442.00, 2425.98),
    (2008, 39, 1, 2, 'Emergency', 'Completed', 'Walk-in', 'Medicare', 'Vomiting and diarrhea', '2025-01-05 18:07:00', '2025-01-05 18:19:00', '2025-01-05 19:32:00', NULL, '2025-01-05 20:42:00', 'Home', 3, '2025-01-05 20:42:00', 3087.00, 1276.42),
    (2009, 18, 4, 6, 'Inpatient', 'Completed', 'Scheduled', 'Medicare', 'Sepsis', '2025-01-06 08:16:00', NULL, '2025-01-06 09:04:00', '2025-01-06 09:42:00', '2025-01-14 15:42:00', 'Home', NULL, NULL, 40078.00, 16683.89),
    (2010, 21, 2, 4, 'Outpatient', 'Completed', 'Scheduled', 'Self-Pay', 'Follow-up for palpitations', '2025-01-06 09:30:00', NULL, '2025-01-06 09:48:00', NULL, '2025-01-06 10:42:00', 'Home', NULL, NULL, 614.00, 79.91),
    (2011, 26, 1, 2, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Shortness of breath', '2025-01-06 11:29:00', '2025-01-06 11:42:00', '2025-01-06 11:46:00', '2025-01-06 14:25:00', '2025-01-15 01:25:00', 'Admitted', 1, '2025-01-06 14:25:00', 32972.00, 21636.92),
    (2012, 35, 4, 10, 'Observation', 'Completed', 'Referral', 'Commercial', 'Dehydration', '2025-01-06 12:43:00', NULL, '2025-01-06 13:16:00', '2025-01-06 13:15:00', '2025-01-07 15:28:00', 'Home', NULL, NULL, 6380.33, 3737.30),
    (2013, 7, 2, 4, 'Observation', 'Completed', 'Scheduled', 'Medicaid', 'Chest pain observation', '2025-01-06 13:57:00', NULL, '2025-01-06 14:15:00', '2025-01-06 14:28:00', '2025-01-07 04:44:00', 'Home', NULL, NULL, 4438.33, 1708.71),
    (2014, 39, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Medication review', '2025-01-06 15:30:00', NULL, '2025-01-06 16:03:00', NULL, '2025-01-06 16:23:00', 'Home', NULL, NULL, 240.00, 98.85),
    (2015, 10, 2, 4, 'Outpatient', 'Cancelled', 'Scheduled', 'Commercial', 'Hypertension review', '2025-01-07 15:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
    (2016, 49, 4, 10, 'Outpatient', 'Cancelled', 'Scheduled', 'Commercial', 'Medication review', '2025-01-07 16:15:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
    (2017, 22, 3, 5, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Back pain assessment', '2025-01-08 15:15:00', NULL, '2025-01-08 15:43:00', NULL, '2025-01-08 16:15:00', 'Home', NULL, NULL, 596.00, 292.62),
    (2018, 8, 2, 3, 'Inpatient', 'Completed', 'Scheduled', 'Self-Pay', 'Acute coronary syndrome', '2025-01-09 15:14:00', NULL, '2025-01-09 16:01:00', '2025-01-09 17:46:00', '2025-01-14 01:46:00', 'Other', NULL, NULL, 25461.00, 3024.82),
    (2019, 55, 2, 4, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid', 'Cardiology consultation', '2025-01-10 14:00:00', NULL, '2025-01-10 14:27:00', NULL, '2025-01-10 15:24:00', 'Home', NULL, NULL, 517.00, 193.50),
    (2020, 20, 1, 8, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Palpitations', '2025-01-11 07:32:00', '2025-01-11 07:40:00', '2025-01-11 08:07:00', NULL, '2025-01-11 10:41:00', 'Home', 3, '2025-01-11 10:41:00', 3068.00, 1920.99),
    (2021, 9, 3, 5, 'Observation', 'Completed', 'Scheduled', 'Medicare', 'Post-op pain control', '2025-01-11 10:57:00', NULL, '2025-01-11 11:08:00', '2025-01-11 11:51:00', '2025-01-12 10:33:00', 'Home', NULL, NULL, 5722.00, 2401.87),
    (2022, 47, 1, 8, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Migraine', '2025-01-12 01:52:00', '2025-01-12 02:05:00', '2025-01-12 02:53:00', NULL, '2025-01-12 03:40:00', 'Home', 4, '2025-01-12 03:40:00', 2284.00, 1617.89),
    (2023, 47, 2, 4, 'Outpatient', 'Completed', 'Scheduled', 'Commercial', 'Cardiology consultation', '2025-01-13 14:30:00', NULL, '2025-01-13 15:02:00', NULL, '2025-01-13 15:51:00', 'Home', NULL, NULL, 496.00, 330.70),
    (2024, 40, 1, 1, 'Emergency', 'Completed', 'Walk-in', 'Medicare', 'Allergic reaction', '2025-01-14 17:05:00', '2025-01-14 17:30:00', '2025-01-14 18:23:00', NULL, '2025-01-14 20:23:00', 'Home', 4, '2025-01-14 20:23:00', 2355.00, 1138.11),
    (2025, 55, 1, NULL, 'Emergency', 'Completed', 'Walk-in', 'Medicaid', 'Dizziness', '2025-01-18 01:46:00', '2025-01-18 01:51:00', NULL, NULL, '2025-01-18 03:43:00', 'Left Without Being Seen', 3, '2025-01-18 03:43:00', 150.00, 49.68),
    (2026, 25, 2, 3, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid', 'Hypertension review', '2025-01-20 08:45:00', NULL, '2025-01-20 09:02:00', NULL, '2025-01-20 09:24:00', 'Home', NULL, NULL, 580.00, 193.37),
    (2027, 22, 3, 5, 'Inpatient', 'Completed', 'Referral', 'Medicare', 'Hip fracture repair', '2025-01-20 09:22:00', NULL, '2025-01-20 10:14:00', '2025-01-20 11:16:00', '2025-01-27 20:16:00', 'Home', NULL, NULL, 42685.00, 18757.21),
    (2028, 9, 3, 5, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Knee pain', '2025-01-20 11:15:00', NULL, '2025-01-20 11:26:00', NULL, '2025-01-20 12:08:00', 'Home', NULL, NULL, 214.00, 93.63),
    (2029, 31, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Medication review', '2025-01-20 11:30:00', NULL, '2025-01-20 11:52:00', NULL, '2025-01-20 12:28:00', 'Home', NULL, NULL, 222.00, 101.94),
    (2030, 30, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Other', 'Post-discharge review', '2025-01-20 15:00:00', NULL, '2025-01-20 15:09:00', NULL, '2025-01-20 15:51:00', 'Home', NULL, NULL, 565.00, 284.86),
    (2031, 20, 4, 10, 'Outpatient', 'Completed', 'Scheduled', 'Commercial', 'Chronic cough', '2025-01-22 09:15:00', NULL, '2025-01-22 09:53:00', NULL, '2025-01-22 10:36:00', 'Home', NULL, NULL, 235.00, 164.58),
    (2032, 55, 4, 10, 'Inpatient', 'Completed', 'Scheduled', 'Medicaid', 'COPD exacerbation', '2025-01-24 11:40:00', NULL, '2025-01-24 12:04:00', '2025-01-24 13:01:00', '2025-01-27 14:01:00', 'Home', NULL, NULL, 20425.00, 7112.10),
    (2033, 35, 3, 5, 'Inpatient', 'Completed', 'Referral', 'Commercial', 'Fracture fixation', '2025-01-25 13:10:00', NULL, '2025-01-25 13:53:00', '2025-01-25 14:22:00', '2025-01-29 22:22:00', 'Home', NULL, NULL, 31042.00, 22131.32),
    (2034, 11, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Post-discharge review', '2025-01-27 09:15:00', NULL, '2025-01-27 09:33:00', NULL, '2025-01-27 10:09:00', 'Home', NULL, NULL, 290.00, 135.26),
    (2035, 53, 2, 4, 'Outpatient', 'Completed', 'Scheduled', 'Self-Pay', 'Echocardiogram follow-up', '2025-01-27 12:30:00', NULL, '2025-01-27 12:52:00', NULL, '2025-01-27 13:31:00', 'Home', NULL, NULL, 510.00, 66.12),
    (2036, 39, 2, 4, 'Outpatient', 'Completed', 'Referral', 'Medicare', 'Post-procedure review', '2025-01-27 12:45:00', NULL, '2025-01-27 13:03:00', NULL, '2025-01-27 13:43:00', 'Home', NULL, NULL, 584.00, 247.87),
    (2037, 32, 1, 8, 'Emergency', 'Completed', 'Ambulance', 'Commercial', 'Stroke symptoms', '2025-01-27 17:03:00', '2025-01-27 17:11:00', '2025-01-27 17:15:00', '2025-01-27 21:42:00', '2025-02-01 22:42:00', 'Admitted', 1, '2025-01-27 21:42:00', 23350.00, 14507.41),
    (2038, 30, 3, 5, 'Outpatient', 'Completed', 'Referral', 'Other', 'Knee pain', '2025-01-28 08:00:00', NULL, '2025-01-28 08:19:00', NULL, '2025-01-28 09:19:00', 'Home', NULL, NULL, 417.00, 209.12),
    (2039, 22, 3, 5, 'Observation', 'Completed', 'Scheduled', 'Medicare', 'Fall observation', '2025-01-29 10:15:00', NULL, '2025-01-29 10:42:00', '2025-01-29 11:00:00', '2025-01-30 09:04:00', 'Home', NULL, NULL, 5790.33, 2790.39),
    (2040, 58, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Commercial', 'Medication review', '2025-01-30 13:00:00', NULL, '2025-01-30 13:15:00', NULL, '2025-01-30 13:57:00', 'Home', NULL, NULL, 529.00, 354.23),
    (2041, 17, 4, 10, 'Inpatient', 'Completed', 'Referral', 'Medicaid', 'Dehydration', '2025-02-01 13:41:00', NULL, '2025-02-01 14:17:00', '2025-02-01 15:42:00', '2025-02-09 00:42:00', 'Transferred', NULL, NULL, 35598.00, 11664.58),
    (2042, 37, 2, 3, 'Inpatient', 'Completed', 'Referral', 'Commercial', 'Chest discomfort', '2025-02-03 07:01:00', NULL, '2025-02-03 07:28:00', '2025-02-03 08:44:00', '2025-02-09 17:44:00', 'Home', NULL, NULL, 33562.00, 22452.43),
    (2043, 9, 4, 10, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Diabetes review', '2025-02-03 15:15:00', NULL, '2025-02-03 15:21:00', NULL, '2025-02-03 15:41:00', 'Home', NULL, NULL, 357.00, 155.36),
    (2044, 56, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Annual health review', '2025-02-03 16:00:00', NULL, '2025-02-03 16:06:00', NULL, '2025-02-03 16:35:00', 'Home', NULL, NULL, 242.00, 115.75),
    (2045, 52, 3, 5, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid', 'Ankle injury follow-up', '2025-02-04 12:30:00', NULL, '2025-02-04 13:10:00', NULL, '2025-02-04 13:35:00', 'Home', NULL, NULL, 310.00, 105.31),
    (2046, 19, 1, 8, 'Emergency', 'Completed', 'Walk-in', 'Medicare', 'Allergic reaction', '2025-02-05 08:56:00', '2025-02-05 09:08:00', '2025-02-05 09:47:00', NULL, '2025-02-05 11:36:00', 'Home', 4, '2025-02-05 11:36:00', 2943.00, 1308.56),
    (2047, 24, 4, 6, 'Inpatient', 'Completed', 'Referral', 'Commercial', 'Pneumonia', '2025-02-05 11:50:00', NULL, '2025-02-05 12:16:00', '2025-02-05 13:38:00', '2025-02-09 19:38:00', 'Home', NULL, NULL, 25123.00, 17900.24),
    (2048, 57, 4, 10, 'Outpatient', 'Completed', 'Scheduled', 'Medicare', 'Post-discharge review', '2025-02-05 12:15:00', NULL, '2025-02-05 12:47:00', NULL, '2025-02-05 13:31:00', 'Home', NULL, NULL, 226.00, 105.39),
    (2049, 12, 2, 4, 'Outpatient', 'Cancelled', 'Scheduled', 'Commercial', 'Echocardiogram follow-up', '2025-02-05 14:15:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
    (2050, 18, 2, 4, 'Observation', 'Completed', 'Scheduled', 'Medicare', 'Palpitations monitoring', '2025-02-06 11:02:00', NULL, '2025-02-06 11:15:00', '2025-02-06 12:27:00', '2025-02-06 22:49:00', 'Home', NULL, NULL, 3907.33, 1860.83),
    (2051, 3, 1, 1, 'Emergency', 'Completed', 'Ambulance', 'Medicare', 'Severe trauma', '2025-02-06 11:44:00', '2025-02-06 11:52:00', '2025-02-06 12:07:00', NULL, '2025-02-06 16:06:00', 'Transferred', 2, '2025-02-06 16:06:00', 4005.00, 1689.23),
    (2052, 32, 1, NULL, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Urinary symptoms', '2025-02-06 19:42:00', NULL, NULL, NULL, '2025-02-06 20:58:00', 'Left Without Being Seen', 4, '2025-02-06 20:58:00', 150.00, 92.91),
    (2053, 13, 2, 3, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid', 'Post-procedure review', '2025-02-07 10:15:00', NULL, '2025-02-07 10:32:00', NULL, '2025-02-07 11:22:00', 'Home', NULL, NULL, 474.00, 174.54),
    (2054, 2, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid', 'Diabetes review', '2025-02-07 14:15:00', NULL, '2025-02-07 14:22:00', NULL, '2025-02-07 15:16:00', 'Home', NULL, NULL, 397.00, 127.00),
    (2055, 15, 4, 6, 'Inpatient', 'Completed', 'Referral', 'Commercial', 'COPD exacerbation', '2025-02-08 09:29:00', NULL, '2025-02-08 10:27:00', '2025-02-08 11:42:00', '2025-02-12 15:42:00', 'Home', NULL, NULL, 23997.00, 14080.77),
    (2056, 21, 4, 10, 'Observation', 'Completed', 'Referral', 'Self-Pay', 'Dehydration', '2025-02-08 11:26:00', NULL, '2025-02-08 11:38:00', '2025-02-08 12:31:00', '2025-02-09 16:09:00', 'Home', NULL, NULL, 6376.67, 744.40),
    (2057, 57, 2, 3, 'Inpatient', 'Completed', 'Scheduled', 'Medicare', 'Acute coronary syndrome', '2025-02-08 12:32:00', NULL, '2025-02-08 13:09:00', '2025-02-08 14:36:00', '2025-02-10 20:36:00', 'Home', NULL, NULL, 18006.00, 8003.97),
    (2058, 20, 1, 1, 'Emergency', 'Completed', 'Walk-in', 'Commercial', 'Urinary symptoms', '2025-02-09 08:43:00', '2025-02-09 08:57:00', '2025-02-09 10:02:00', NULL, '2025-02-09 11:26:00', 'Home', 4, '2025-02-09 11:26:00', 2548.00, 1505.01),
    (2059, 7, 1, 1, 'Emergency', 'Completed', 'Ambulance', 'Medicaid', 'Altered mental status', '2025-02-09 15:53:00', '2025-02-09 15:56:00', '2025-02-09 16:10:00', '2025-02-09 19:15:00', '2025-02-17 07:15:00', 'Admitted', 2, '2025-02-09 19:15:00', 29504.00, 10372.61),
    (2060, 5, 1, 1, 'Emergency', 'Completed', 'Ambulance', 'Medicare', 'Stroke symptoms', '2025-02-10 19:55:00', '2025-02-10 20:03:00', '2025-02-10 20:28:00', '2025-02-10 21:52:00', '2025-02-13 04:52:00', 'Admitted', 2, '2025-02-10 21:52:00', 13829.00, 5763.81);