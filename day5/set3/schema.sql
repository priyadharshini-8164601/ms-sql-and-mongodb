
-- Create database
CREATE DATABASE HospitalManagementDB;
GO

USE HospitalManagementDB;
GO

-- 1. Department Table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Doctor Table
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,

    CONSTRAINT FK_Doctor_Department
    FOREIGN KEY (DepartmentID)
    REFERENCES Department(DepartmentID)
);

-- 3. Patient Table
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    PatientName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(15) NOT NULL UNIQUE
);

-- 4. Visit Table
CREATE TABLE Visit (
    VisitID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    Diagnosis VARCHAR(200) NOT NULL,

    Status VARCHAR(20) NOT NULL
    CONSTRAINT DF_Visit_Status DEFAULT 'Open',

    CONSTRAINT FK_Visit_Patient
    FOREIGN KEY (PatientID)
    REFERENCES Patient(PatientID),

    CONSTRAINT FK_Visit_Doctor
    FOREIGN KEY (DoctorID)
    REFERENCES Doctor(DoctorID),

    CONSTRAINT CK_Visit_Date
    CHECK (
        VisitDate >= '2000-01-01'
        AND VisitDate <= CAST(GETDATE() AS DATE)
    )
);

-- 5. Billing Table
CREATE TABLE Billing (
    BillingID INT PRIMARY KEY,
    VisitID INT NOT NULL UNIQUE,
    BillAmount DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Billing_Visit
    FOREIGN KEY (VisitID)
    REFERENCES Visit(VisitID),

    CONSTRAINT CK_Billing_Amount
    CHECK (BillAmount >= 0)
);
GO
