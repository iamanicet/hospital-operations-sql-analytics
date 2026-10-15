-- 01_hospital_setup.sql
-- Hospital Operations & Patient Flow Analytics
-- Target platform: MySQL 8.0.16+
--
-- All names and encounter records below are synthetic.
-- This script preserves the database but drops and recreates its four tables.
-- Re-running it will therefore reset those tables and their seed data.

CREATE DATABASE IF NOT EXISTS hospital_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE hospital_analytics;

-- Drop child tables before parent tables so foreign keys do not block the reset.
DROP TABLE IF EXISTS Encounters;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;
DROP TABLE IF EXISTS Departments;
CREATE TABLE Departments (
    department_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location        VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (department_id),
    UNIQUE KEY uq_departments_name (department_name)
) ENGINE = InnoDB;

CREATE TABLE Patients (
    patient_id    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name    VARCHAR(80) NOT NULL,
    last_name     VARCHAR(80) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex           ENUM('Female', 'Male', 'Other', 'Unknown')
                  NOT NULL DEFAULT 'Unknown',
    city          VARCHAR(100) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (patient_id),
    KEY idx_patients_date_of_birth (date_of_birth)
) ENGINE = InnoDB;

CREATE TABLE Doctors (
    doctor_id      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    department_id  INT UNSIGNED NOT NULL,
    first_name     VARCHAR(80) NOT NULL,
    last_name      VARCHAR(80) NOT NULL,
    specialty      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doctor_id),
    UNIQUE KEY uq_doctors_email (email),
    KEY idx_doctors_department (department_id),
    CONSTRAINT fk_doctors_department
        FOREIGN KEY (department_id)
        REFERENCES Departments (department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE Encounters (
    encounter_id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
    patient_id               INT UNSIGNED NOT NULL,
    department_id            INT UNSIGNED NOT NULL,
    doctor_id                INT UNSIGNED NULL,
    encounter_type           ENUM('Emergency', 'Inpatient', 'Outpatient', 'Observation')
                             NOT NULL,
    encounter_status         ENUM('Completed', 'In Progress', 'Cancelled')
                             NOT NULL DEFAULT 'Completed',
    arrival_mode             ENUM('Walk-in', 'Ambulance', 'Referral', 'Scheduled')
                             NOT NULL,
    payer_type               ENUM('Commercial', 'Medicare', 'Medicaid', 'Self-Pay', 'Other')
                             NOT NULL,
    chief_complaint          VARCHAR(255) NOT NULL,
    arrival_datetime         DATETIME NOT NULL,
    triage_datetime          DATETIME NULL,
    provider_start_datetime  DATETIME NULL,
    admission_datetime       DATETIME NULL,
    discharge_datetime      DATETIME NULL,
    discharge_disposition    ENUM(
                                 'Home',
                                 'Admitted',
                                 'Transferred',
                                 'Left Without Being Seen',
                                 'Deceased',
                                 'Other'
                             ) NULL,
    created_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (encounter_id),
    KEY idx_encounters_patient_arrival (patient_id, arrival_datetime),
    KEY idx_encounters_department_arrival (department_id, arrival_datetime),
    KEY idx_encounters_doctor_arrival (doctor_id, arrival_datetime),
    KEY idx_encounters_status_arrival (encounter_status, arrival_datetime),
    CONSTRAINT fk_encounters_patient
        FOREIGN KEY (patient_id)
        REFERENCES Patients (patient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_encounters_department
        FOREIGN KEY (department_id)
        REFERENCES Departments (department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_encounters_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES Doctors (doctor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    CONSTRAINT chk_encounters_triage_after_arrival
        CHECK (triage_datetime IS NULL OR triage_datetime >= arrival_datetime),
    CONSTRAINT chk_encounters_provider_after_arrival
        CHECK (provider_start_datetime IS NULL
               OR provider_start_datetime >= arrival_datetime),
    CONSTRAINT chk_encounters_admission_after_arrival
        CHECK (admission_datetime IS NULL
               OR admission_datetime >= arrival_datetime),
    CONSTRAINT chk_encounters_discharge_after_arrival
        CHECK (discharge_datetime IS NULL
               OR discharge_datetime >= arrival_datetime),
    CONSTRAINT chk_encounters_discharge_after_admission
        CHECK (discharge_datetime IS NULL
               OR admission_datetime IS NULL
               OR discharge_datetime >= admission_datetime)
) ENGINE = InnoDB;

-- Seed departments.
INSERT INTO Departments (department_id, department_name, location) VALUES
    (1, 'Emergency',        'Main Hospital - Ground Floor'),
    (2, 'Cardiology',       'Main Hospital - 3rd Floor'),
    (3, 'Orthopedics',      'Main Hospital - 2nd Floor'),
    (4, 'General Medicine', 'Main Hospital - 4th Floor');

-- Seed synthetic patients.
INSERT INTO Patients
    (patient_id, first_name, last_name, date_of_birth, sex, city)
VALUES
    (1,  'Ava',     'Morgan',   '1987-04-12', 'Female', 'Riverton'),
    (2,  'Liam',    'Chen',     '1972-11-03', 'Male',   'Riverton'),
    (3,  'Sofia',   'Patel',    '1958-06-21', 'Female', 'Lakeview'),
    (4,  'Noah',    'Brooks',   '1991-09-15', 'Male',   'Riverton'),
    (5,  'Mia',     'Reed',     '1949-02-08', 'Female', 'Hillcrest'),
    (6,  'Ethan',   'Rivera',   '2001-12-30', 'Male',   'Lakeview'),
    (7,  'Isabella','Foster',   '1965-07-17', 'Female', 'Hillcrest'),
    (8,  'James',   'Okafor',   '1980-01-25', 'Male',   'Riverton'),
    (9,  'Amara',   'Singh',    '1939-10-09', 'Female', 'Lakeview'),
    (10, 'Lucas',   'Bennett',  '1996-03-04', 'Male',   'Hillcrest');

-- Seed synthetic doctors. Each doctor is assigned to one department.
INSERT INTO Doctors
    (doctor_id, department_id, first_name, last_name, specialty, email, is_active)
VALUES
    (1, 1, 'Olivia', 'Carter',  'Emergency Medicine', 'olivia.carter@example.org', TRUE),
    (2, 1, 'Henry',  'Adams',   'Emergency Medicine', 'henry.adams@example.org',  TRUE),
    (3, 2, 'Priya',  'Shah',    'Cardiology',         'priya.shah@example.org',    TRUE),
    (4, 2, 'Daniel', 'Kim',     'Cardiology',         'daniel.kim@example.org',    TRUE),
    (5, 3, 'Grace',  'Wilson',  'Orthopedic Surgery', 'grace.wilson@example.org',  TRUE),
    (6, 4, 'Marcus', 'Thompson','Internal Medicine',  'marcus.thompson@example.org', TRUE);

-- Seed synthetic encounters across departments and encounter types.
-- Includes repeat visits, an encounter with no provider contact, and varied
-- arrival modes and payers for later operational analyses.
INSERT INTO Encounters (
    encounter_id,
    patient_id,
    department_id,
    doctor_id,
    encounter_type,
    encounter_status,
    arrival_mode,
    payer_type,
    chief_complaint,
    arrival_datetime,
    triage_datetime,
    provider_start_datetime,
    admission_datetime,
    discharge_datetime,
    discharge_disposition
) VALUES
    (1001, 1, 1, 1, 'Emergency', 'Completed', 'Walk-in',   'Commercial',
     'Abdominal pain', '2025-01-03 08:10:00', '2025-01-03 08:18:00',
     '2025-01-03 09:02:00', NULL, '2025-01-03 10:20:00', 'Home'),

    (1002, 2, 1, NULL, 'Emergency', 'Completed', 'Walk-in', 'Medicaid',
     'Fever and cough', '2025-01-03 09:45:00', '2025-01-03 10:11:00',
     NULL, NULL, '2025-01-03 12:00:00', 'Left Without Being Seen'),

    (1003, 3, 2, 3, 'Inpatient', 'Completed', 'Referral', 'Medicare',
     'Chest discomfort', '2025-01-04 14:00:00', NULL,
     '2025-01-04 14:30:00', '2025-01-04 16:00:00',
     '2025-01-07 11:00:00', 'Home'),

    (1004, 4, 2, 4, 'Outpatient', 'Completed', 'Scheduled', 'Commercial',
     'Follow-up for palpitations', '2025-01-06 09:00:00', NULL,
     '2025-01-06 09:18:00', NULL, '2025-01-06 10:00:00', 'Home'),

    (1005, 5, 1, 2, 'Emergency', 'Completed', 'Ambulance', 'Medicare',
     'Fall with hip pain', '2025-01-08 07:20:00', '2025-01-08 07:28:00',
     '2025-01-08 07:55:00', '2025-01-08 10:15:00',
     '2025-01-12 13:30:00', 'Admitted'),

    (1006, 6, 3, 5, 'Outpatient', 'Completed', 'Scheduled', 'Commercial',
     'Knee pain', '2025-01-09 13:00:00', NULL,
     '2025-01-09 13:22:00', NULL, '2025-01-09 14:10:00', 'Home'),

    (1007, 7, 4, 6, 'Inpatient', 'Completed', 'Referral', 'Medicaid',
     'Shortness of breath', '2025-01-10 10:00:00', NULL,
     '2025-01-10 10:35:00', '2025-01-10 12:00:00',
     '2025-01-14 09:15:00', 'Home'),

    (1008, 3, 1, 1, 'Emergency', 'Completed', 'Ambulance', 'Medicare',
     'Recurrent chest discomfort', '2025-01-20 16:10:00', '2025-01-20 16:18:00',
     '2025-01-20 16:42:00', '2025-01-20 18:30:00',
     '2025-01-22 12:00:00', 'Admitted'),

    (1009, 8, 1, 2, 'Emergency', 'Completed', 'Walk-in', 'Self-Pay',
     'Laceration to hand', '2025-02-02 18:25:00', '2025-02-02 18:33:00',
     '2025-02-02 19:05:00', NULL, '2025-02-02 20:10:00', 'Home'),

    (1010, 9, 4, 6, 'Inpatient', 'Completed', 'Ambulance', 'Medicare',
     'Dehydration', '2025-02-05 06:40:00', NULL,
     '2025-02-05 07:05:00', '2025-02-05 08:20:00',
     '2025-02-09 15:00:00', 'Home'),

    (1011, 10, 3, 5, 'Outpatient', 'Completed', 'Scheduled', 'Commercial',
     'Ankle injury follow-up', '2025-02-11 11:00:00', NULL,
     '2025-02-11 11:14:00', NULL, '2025-02-11 11:45:00', 'Home'),

    (1012, 1, 1, 2, 'Emergency', 'Completed', 'Walk-in', 'Commercial',
     'Migraine', '2025-02-18 20:05:00', '2025-02-18 20:13:00',
     '2025-02-18 20:49:00', NULL, '2025-02-18 22:05:00', 'Home'),

    (1013, 5, 3, 5, 'Inpatient', 'Completed', 'Referral', 'Medicare',
     'Hip fracture repair', '2025-03-01 08:00:00', NULL,
     '2025-03-01 08:25:00', '2025-03-01 09:10:00',
     '2025-03-05 16:20:00', 'Transferred'),

    (1014, 7, 4, 6, 'Outpatient', 'Completed', 'Scheduled', 'Medicaid',
     'Post-discharge review', '2025-03-04 14:00:00', NULL,
     '2025-03-04 14:12:00', NULL, '2025-03-04 14:40:00', 'Home'),

    (1015, 2, 1, 1, 'Emergency', 'Completed', 'Ambulance', 'Medicaid',
     'Worsening respiratory symptoms', '2025-03-10 05:50:00', '2025-03-10 05:58:00',
     '2025-03-10 06:24:00', '2025-03-10 08:05:00',
     '2025-03-13 10:30:00', 'Admitted'),

    (1016, 4, 2, 3, 'Outpatient', 'Completed', 'Scheduled', 'Commercial',
     'Cardiology consultation', '2025-03-12 10:30:00', NULL,
     '2025-03-12 10:52:00', NULL, '2025-03-12 11:35:00', 'Home');
     