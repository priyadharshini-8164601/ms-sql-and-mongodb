
CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Address VARCHAR(200),
    NationalID VARCHAR(30),
    BankAccountNumber VARCHAR(30)
);
GO

CREATE TABLE Agents (
    AgentID INT PRIMARY KEY IDENTITY(1,1),
    AgentName VARCHAR(100) NOT NULL,
    Email VARCHAR(100)
);
GO

CREATE TABLE Policies (
    PolicyID INT PRIMARY KEY IDENTITY(1001,1),
    CustomerID INT NOT NULL,
    AgentID INT NOT NULL,
    PolicyType VARCHAR(50) NOT NULL,
    PolicyStartDate DATE NOT NULL,
    PolicyExpiryDate DATE NOT NULL,
    PremiumAmount DECIMAL(12,2) NOT NULL,
    PremiumDueDate DATE NOT NULL,
    PolicyStatus VARCHAR(20) NOT NULL DEFAULT 'Active',
    NoClaimYears INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Policies_Customers
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Policies_Agents
    FOREIGN KEY (AgentID) REFERENCES Agents(AgentID),

    CONSTRAINT CK_Policies_Premium
    CHECK (PremiumAmount >= 0),

    CONSTRAINT CK_Policies_Status
    CHECK (PolicyStatus IN
    ('Active', 'Lapsed', 'Expired', 'Cancelled')),

    CONSTRAINT CK_Policies_NoClaimYears
    CHECK (NoClaimYears >= 0)
);
GO

CREATE TABLE Claims (
    ClaimID INT PRIMARY KEY IDENTITY(1,1),
    PolicyID INT NOT NULL,
    ClaimDate DATE NOT NULL,
    ClaimAmount DECIMAL(12,2) NOT NULL,
    ClaimStatus VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Claims_Policies
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID)
);
GO

CREATE TABLE RenewalAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    PolicyID INT NOT NULL,
    RenewalDate DATETIME NOT NULL DEFAULT GETDATE(),
    OldPremium DECIMAL(12,2),
    NewPremium DECIMAL(12,2),
    AuditMessage VARCHAR(255),

    CONSTRAINT FK_RenewalAudit_Policies
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID)
);
GO

CREATE TABLE PolicyStatusLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    PolicyID INT NOT NULL,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20),
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE(),
    ChangeReason VARCHAR(255),

    CONSTRAINT FK_PolicyStatusLog_Policies
    FOREIGN KEY (PolicyID) REFERENCES Policies(PolicyID)
);
GO

INSERT INTO Customers
(CustomerName, Email, Phone, Address, NationalID, BankAccountNumber)
VALUES
('Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai', 'ID1001', 'BANK1001'),
('Priya Sharma', 'priya@gmail.com', '9876543211', 'Coimbatore', 'ID1002', 'BANK1002'),
('Rahul Raj', 'rahul@gmail.com', '9876543212', 'Madurai', 'ID1003', 'BANK1003'),
('Divya Kumar', 'divya@gmail.com', '9876543213', 'Salem', 'ID1004', 'BANK1004'),
('Karthik S', 'karthik@gmail.com', '9876543214', 'Erode', 'ID1005', 'BANK1005');
GO

INSERT INTO Agents
(AgentName, Email)
VALUES
('Anand Kumar', 'anand@insurance.com'),
('Meena Raj', 'meena@insurance.com'),
('Suresh Babu', 'suresh@insurance.com');
GO

INSERT INTO Policies
(CustomerID, AgentID, PolicyType, PolicyStartDate,
 PolicyExpiryDate, PremiumAmount, PremiumDueDate,
 PolicyStatus, NoClaimYears)
VALUES
(1, 1, 'Health', DATEADD(YEAR,-1,GETDATE()),
 DATEADD(DAY,10,GETDATE()), 12000,
 DATEADD(DAY,10,GETDATE()), 'Active', 2),

(2, 2, 'Life', DATEADD(YEAR,-1,GETDATE()),
 DATEADD(DAY,20,GETDATE()), 15000,
 DATEADD(DAY,20,GETDATE()), 'Active', 3),

(3, 1, 'Vehicle', DATEADD(YEAR,-1,GETDATE()),
 DATEADD(DAY,40,GETDATE()), 8000,
 DATEADD(DAY,40,GETDATE()), 'Active', 1),

(4, 3, 'Health', DATEADD(YEAR,-1,GETDATE()),
 DATEADD(DAY,-5,GETDATE()), 10000,
 DATEADD(DAY,-5,GETDATE()), 'Active', 0),

(5, 2, 'Vehicle', DATEADD(YEAR,-1,GETDATE()),
 DATEADD(DAY,15,GETDATE()), 9000,
 DATEADD(DAY,15,GETDATE()), 'Active', 2);
GO

INSERT INTO Claims
(PolicyID, ClaimDate, ClaimAmount, ClaimStatus)
VALUES
(1001, DATEADD(DAY,-100,GETDATE()), 5000, 'Approved'),
(1002, DATEADD(DAY,-30,GETDATE()), 3000, 'Pending'),
(1003, DATEADD(DAY,-60,GETDATE()), 2000, 'Rejected'),
(1004, DATEADD(DAY,-10,GETDATE()), 4000, 'Pending');
GO

CREATE VIEW vw_policy_due
AS
SELECT
    p.PolicyID,
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Phone,
    c.Address,
    a.AgentName,
    p.PolicyType,
    p.PolicyExpiryDate,
    p.PremiumDueDate,
    p.PremiumAmount,
    p.PolicyStatus
FROM Policies p
INNER JOIN Customers c
    ON p.CustomerID = c.CustomerID
INNER JOIN Agents a
    ON p.AgentID = a.AgentID
WHERE p.PolicyExpiryDate >= CAST(GETDATE() AS DATE)
  AND p.PolicyExpiryDate <= DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
  AND p.PolicyStatus = 'Active';
GO

SELECT * FROM vw_policy_due;
GO

SELECT
    PolicyID,
    CustomerName,
    PolicyType,
    PolicyExpiryDate,
    PremiumAmount
FROM vw_policy_due
ORDER BY PolicyExpiryDate;
GO
