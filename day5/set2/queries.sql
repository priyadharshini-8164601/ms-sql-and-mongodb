
-- Task 3: Differentiate DROP, TRUNCATE and DELETE
USE BankManagementDB;
GO

-- DELETE test table
CREATE TABLE DeleteTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO DeleteTest (Name)
VALUES ('Arun'),('Priya'),('Ravi');

SELECT * FROM DeleteTest;

-- Delete one record
DELETE FROM DeleteTest
WHERE ID = 2;

SELECT * FROM DeleteTest;

-- Insert another record to check identity
INSERT INTO DeleteTest (Name)
VALUES ('Karthik');

SELECT * FROM DeleteTest;
GO


-- TRUNCATE test table
CREATE TABLE TruncateTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO TruncateTest (Name)
VALUES ('Arun'),('Priya'),('Ravi');

SELECT * FROM TruncateTest;

-- Check rollback of TRUNCATE
BEGIN TRANSACTION;

TRUNCATE TABLE TruncateTest;

SELECT * FROM TruncateTest;

ROLLBACK TRANSACTION;

-- Verify records restored
SELECT * FROM TruncateTest;

-- Permanently truncate
TRUNCATE TABLE TruncateTest;

-- Insert again to check identity reset
INSERT INTO TruncateTest (Name)
VALUES ('Karthik');

SELECT * FROM TruncateTest;
GO


-- DROP test table
CREATE TABLE DropTest (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(50)
);

INSERT INTO DropTest (Name)
VALUES ('Arun'),('Priya'),('Ravi');

SELECT * FROM DropTest;

-- Check rollback of DROP
BEGIN TRANSACTION;

DROP TABLE DropTest;

ROLLBACK TRANSACTION;

-- Verify table restored
SELECT * FROM DropTest;

-- Permanently drop table
DROP TABLE DropTest;
GO

-- Task 4: Insert, UPDATE and DELETE sample records
-- Insert a new customer
INSERT INTO Customer (CustomerName,Address,Phone)
VALUES ('Kumar','Chennai','9000000011');

SELECT * FROM Customer
WHERE CustomerName = 'Kumar';

-- Update customer address
UPDATE Customer
SET Address = 'Coimbatore'
WHERE CustomerID = 11;

SELECT * FROM Customer
WHERE CustomerID = 11;

-- Delete customer
DELETE FROM Customer
WHERE CustomerID = 11;

SELECT * FROM Customer
WHERE CustomerID = 11;
GO


-- Task 5: Retrieve accounts using WHERE, AND, OR, IN and BETWEEN
-- A. AND operator
SELECT *
FROM Account
WHERE Balance > 50000
AND AccountType = 'Savings';

-- B. OR operator
SELECT *
FROM Account
WHERE AccountType = 'Savings'
OR AccountType = 'Current';

-- C. IN operator
SELECT *
FROM Account
WHERE BranchID IN (1,2,3,4,5);

-- D. BETWEEN operator
SELECT *
FROM Account
WHERE Balance BETWEEN 50000 AND 150000;


-- E. Accounts opened in the last quarter with balance above 50,000
SELECT
    A.AccountNumber,
    C.CustomerName,
    A.AccountType,
    B.BranchName,
    A.Balance,
    A.OpenedDate
FROM Account A
JOIN Customer C
ON A.CustomerID = C.CustomerID
JOIN Branch B
ON A.BranchID = B.BranchID
WHERE A.OpenedDate >= DATEADD(
    QUARTER,
    DATEDIFF(QUARTER, 0, GETDATE()) - 1,
    0
)
AND A.OpenedDate < DATEADD(
    QUARTER,
    DATEDIFF(QUARTER, 0, GETDATE()),
    0
)
AND A.Balance > 50000;
GO
