
USE HospitalManagementDB;
GO

-- 1. Department records
INSERT INTO Department VALUES
(1,'Cardiology'),
(2,'Neurology'),
(3,'Orthopedics'),
(4,'Dermatology'),
(5,'Pediatrics'),
(6,'ENT'),
(7,'Ophthalmology'),
(8,'General Medicine'),
(9,'Oncology'),
(10,'Gynecology');

-- 2. Doctor records
INSERT INTO Doctor VALUES
(1,'Dr. Arun',1),
(2,'Dr. Priya',2),
(3,'Dr. Karthik',3),
(4,'Dr. Divya',4),
(5,'Dr. Ravi',5),
(6,'Dr. Meena',6),
(7,'Dr. Vijay',7),
(8,'Dr. Anu',8),
(9,'Dr. Rahul',9),
(10,'Dr. Sneha',10);

-- 3. Patient records
INSERT INTO Patient
(PatientID,PatientName,Address,Phone,insurance_id)
VALUES
(1,'Raj','Coimbatore','9000000001','INS001'),
(2,'Priya','Chennai','9000000002','INS002'),
(3,'Kumar','Madurai','9000000003','INS003'),
(4,'Divya','Salem','9000000004','INS004'),
(5,'Arun','Erode','9000000005','INS005'),
(6,'Meena','Trichy','9000000006','INS006'),
(7,'Vijay','Tiruppur','9000000007','INS007'),
(8,'Anu','Bangalore','9000000008','INS008'),
(9,'Rahul','Mysore','9000000009','INS009'),
(10,'Sneha','Pondicherry','9000000010','INS010');

-- 4. Visit records
-- Status must be provided because its default was dropped
INSERT INTO Visit
(VisitID,PatientID,DoctorID,VisitDate,Diagnosis,Status)
VALUES
(1,1,1,'2026-10-01','Heart Pain','Open'),
(2,2,2,'2026-10-05','Headache','Open'),
(3,3,3,'2026-10-10','Bone Pain','Completed'),
(4,4,4,'2026-10-15','Skin Allergy','Open'),
(5,5,5,'2026-11-01','Fever','Completed'),
(6,6,6,'2026-11-05','Ear Infection','Open'),
(7,7,7,'2026-09-10','Eye Infection','Completed'),
(8,8,8,'2026-09-15','Cold','Open'),
(9,9,9,'2026-08-20','Tumor Checkup','Completed'),
(10,10,10,'2026-08-25','Pregnancy Checkup','Open');

-- 5. Billing records
INSERT INTO VisitBilling
(BillingID,VisitID,BillAmount)
VALUES
(1,1,2500),
(2,2,1500),
(3,3,3000),
(4,4,1200),
(5,5,800),
(6,6,1000),
(7,7,1800),
(8,8,700),
(9,9,5000),
(10,10,3500);
GO

-- Display all records
SELECT * FROM Department;
SELECT * FROM Doctor;
SELECT * FROM Patient;
SELECT * FROM Visit;
SELECT * FROM VisitBilling;
GO
