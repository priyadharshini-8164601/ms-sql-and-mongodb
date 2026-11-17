-- Task 3: ALTER TABLE operations
-- A. Add insurance_id column

ALTER TABLE Patient
ADD insurance_id VARCHAR(30);

-- Verify
SELECT * FROM Patient;
 
-- B. Rename Billing table to VisitBilling

EXEC sp_rename 'Billing', 'VisitBilling';

-- Verify renamed table
SELECT * FROM VisitBilling;

-- C. Drop a constraint

ALTER TABLE Visit
DROP CONSTRAINT DF_Visit_Status;

-- Verify table structure
EXEC sp_help 'Visit';

-- Task 4: UPDATE and DELETE operations
-- A. Update patient address

-- Before update
SELECT * FROM Patient
WHERE PatientID = 1;

-- Update
UPDATE Patient
SET Address = 'Chennai'
WHERE PatientID = 1;

-- After update
SELECT * FROM Patient
WHERE PatientID = 1;

-- B. Update visit status

UPDATE Visit
SET Status = 'Completed'
WHERE VisitID = 1;

SELECT * FROM Visit
WHERE VisitID = 1;

-- C. Delete a patient without associated visits

-- Insert a separate patient
INSERT INTO Patient
(PatientID,PatientName,Address,Phone,insurance_id)
VALUES
(11,'Test Patient','Coimbatore','9000000011','INS011');

-- Before deletion
SELECT * FROM Patient
WHERE PatientID = 11;

-- Delete
DELETE FROM Patient
WHERE PatientID = 11;

-- After deletion
SELECT * FROM Patient
WHERE PatientID = 11;

-- Task 5: Retrieve patients visited in a given month
-- A. Patients visited in October 2026


SELECT
    P.PatientID,
    P.PatientName,
    V.VisitDate,
    V.Diagnosis,
    V.Status
FROM Patient P
JOIN Visit V
ON P.PatientID = V.PatientID
WHERE V.VisitDate >= '2026-10-01'
AND V.VisitDate < '2026-11-01';

-- B. Doctors belonging to a particular department using WHERE and LIKE

SELECT
    D.DoctorID,
    D.DoctorName,
    DP.DepartmentName
FROM Doctor D
JOIN Department DP
ON D.DepartmentID = DP.DepartmentID
WHERE DP.DepartmentName LIKE '%Cardio%';

-- C. Retrieve all patients with their doctors and departments

SELECT
    P.PatientName,
    D.DoctorName,
    DP.DepartmentName,
    V.VisitDate,
    V.Diagnosis,
    V.Status
FROM Visit V
JOIN Patient P
ON V.PatientID = P.PatientID
JOIN Doctor D
ON V.DoctorID = D.DoctorID
JOIN Department DP
ON D.DepartmentID = DP.DepartmentID;
GO
