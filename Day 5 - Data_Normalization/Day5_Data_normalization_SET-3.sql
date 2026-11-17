



--Set 3 – Hospital Patient Records and Clinical Notes

-----------------------------------------------------------creating tables-------------------------------------------------------------

CREATE DATABASE HospitalDB;
GO

USE HospitalDB;
GO

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(50) NOT NULL,
    department_id INT NOT NULL,

    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);

CREATE TABLE Visits (
    visit_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    visit_date DATE NOT NULL
        CHECK (visit_date <= CAST(GETDATE() AS DATE)),
    diagnosis VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Open',

    FOREIGN KEY (patient_id)
        REFERENCES Patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES Doctors(doctor_id)
);

CREATE TABLE Billing (
    bill_id INT PRIMARY KEY,
    visit_id INT NOT NULL UNIQUE,
    bill_amount DECIMAL(10,2) NOT NULL
        CHECK (bill_amount >= 0),

    FOREIGN KEY (visit_id)
        REFERENCES Visits(visit_id)
        ON DELETE CASCADE
);


------------------------------------------------------ insert data ------------------------------------------------------------------------

USE HospitalDB;
GO

-- Patients
INSERT INTO Patients VALUES
(1, 'Arun', 'Chennai'),
(2, 'Priya', 'Madurai'),
(3, 'Kumar', 'Salem'),
(4, 'Divya', 'Trichy'),
(5, 'Ravi', 'Erode');

-- Departments
INSERT INTO Departments VALUES
(1, 'Cardiology'),
(2, 'Neurology'),
(3, 'Orthopedics'),
(4, 'Dental'),
(5, 'General Medicine');

-- Doctors
INSERT INTO Doctors VALUES
(1, 'Dr. Meena', 1),
(2, 'Dr. Ravi', 2),
(3, 'Dr. Kumar', 3),
(4, 'Dr. Divya', 4),
(5, 'Dr. Anu', 5);

-- Visits
INSERT INTO Visits
(visit_id, patient_id, doctor_id, visit_date, diagnosis)
VALUES
(101, 1, 1, '2026-11-01', 'Heart pain'),
(102, 2, 2, '2026-11-05', 'Headache'),
(103, 3, 3, '2026-10-10', 'Knee pain'),
(104, 4, 4, '2026-11-12', 'Tooth pain'),
(105, 5, 5, '2026-09-15', 'Fever');

-- Billing
INSERT INTO Billing VALUES
(1, 101, 1500),
(2, 102, 1000),
(3, 103, 2000),
(4, 104, 800),
(5, 105, 500);



----------------------------------------------update and delete ----------------------------------------------------------------------------------

-- Update patient address
UPDATE Patients
SET address = 'Coimbatore'
WHERE patient_id = 1;

-- Delete one billing record
DELETE FROM Billing
WHERE bill_id = 5;

-- View updated data
SELECT * FROM Patients;
SELECT * FROM Billing;

--Retrieve patients visited in a given month

SELECT p.patient_name, v.visit_date, v.diagnosis
FROM Patients p
JOIN Visits v
ON p.patient_id = v.patient_id
WHERE v.visit_date >= '2026-11-01'
AND v.visit_date < '2026-12-01';

--Find doctors in a department using LIKE

SELECT d.doctor_name, dep.department_name
FROM Doctors d
JOIN Departments dep
ON d.department_id = dep.department_id
WHERE dep.department_name LIKE '%Cardio%';


---------------------------------------------------------- ALTER TABLE operations---------------------------------------------------------------

USE HospitalDB;
GO

-- 1. Add insurance_id column
ALTER TABLE Patients
ADD insurance_id VARCHAR(20) NULL;

-- 2. Rename Departments table
EXEC sp_rename
    'Departments',
    'HospitalDepartments';

-- 3. Drop the visit date constraint
ALTER TABLE Visits
DROP CONSTRAINT CK_Visits_VisitDate;
