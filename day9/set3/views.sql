
CREATE DATABASE TelecomDB;
GO

USE TelecomDB;
GO

CREATE TABLE Plans (
    PlanID INT PRIMARY KEY IDENTITY(1,1),
    PlanName VARCHAR(100) NOT NULL,
    PlanType VARCHAR(20) NOT NULL,
    PlanAmount DECIMAL(10,2) NOT NULL,
    ValidityDays INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT CK_Plans_Type
    CHECK (PlanType IN ('Prepaid', 'Postpaid')),

    CONSTRAINT CK_Plans_Amount
    CHECK (PlanAmount > 0),

    CONSTRAINT CK_Plans_Validity
    CHECK (ValidityDays > 0)
);
GO

CREATE TABLE Subscribers (
    SubscriberID INT PRIMARY KEY IDENTITY(1001,1),
    SubscriberName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL UNIQUE,
    SubscriberType VARCHAR(20) NOT NULL,
    PlanID INT NOT NULL,
    Balance DECIMAL(10,2) NOT NULL DEFAULT 0,
    ActivationDate DATE NOT NULL DEFAULT GETDATE(),
    ValidityEndDate DATE NOT NULL,
    SubscriberStatus VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT FK_Subscribers_Plans
    FOREIGN KEY (PlanID) REFERENCES Plans(PlanID),

    CONSTRAINT CK_Subscribers_Type
    CHECK (SubscriberType IN ('Prepaid', 'Postpaid')),

    CONSTRAINT CK_Subscribers_Balance
    CHECK (Balance >= 0),

    CONSTRAINT CK_Subscribers_Status
    CHECK (SubscriberStatus IN ('Active', 'Inactive', 'Suspended'))
);
GO

CREATE TABLE RechargeHistory (
    RechargeID INT PRIMARY KEY IDENTITY(1,1),
    SubscriberID INT NOT NULL,
    PlanID INT NOT NULL,
    RechargeAmount DECIMAL(10,2) NOT NULL,
    RechargeDate DATETIME NOT NULL DEFAULT GETDATE(),
    ValidityEndDate DATE NOT NULL,
    RechargeStatus VARCHAR(20) NOT NULL DEFAULT 'Success',

    CONSTRAINT FK_Recharge_Subscribers
    FOREIGN KEY (SubscriberID) REFERENCES Subscribers(SubscriberID),

    CONSTRAINT FK_Recharge_Plans
    FOREIGN KEY (PlanID) REFERENCES Plans(PlanID),

    CONSTRAINT CK_Recharge_Amount
    CHECK (RechargeAmount > 0)
);
GO

CREATE TABLE NotificationLog (
    NotificationID INT PRIMARY KEY IDENTITY(1,1),
    SubscriberID INT NOT NULL,
    NotificationMessage VARCHAR(255) NOT NULL,
    NotificationDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsRead BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Notifications_Subscribers
    FOREIGN KEY (SubscriberID) REFERENCES Subscribers(SubscriberID)
);
GO

INSERT INTO Plans
(PlanName, PlanType, PlanAmount, ValidityDays)
VALUES
('Basic Prepaid', 'Prepaid', 199, 28),
('Smart Prepaid', 'Prepaid', 299, 56),
('Premium Prepaid', 'Prepaid', 499, 84),
('Monthly Postpaid', 'Postpaid', 599, 30),
('Family Postpaid', 'Postpaid', 999, 30);
GO

INSERT INTO Subscribers
(SubscriberName, PhoneNumber, SubscriberType,
 PlanID, Balance, ActivationDate, ValidityEndDate)
VALUES
('Arun Kumar', '9876543210', 'Prepaid', 1, 25,
 DATEADD(DAY,-60,GETDATE()), DATEADD(DAY,20,GETDATE())),

('Priya Sharma', '9876543211', 'Prepaid', 2, 150,
 DATEADD(DAY,-50,GETDATE()), DATEADD(DAY,30,GETDATE())),

('Rahul Raj', '9876543212', 'Prepaid', 1, 40,
 DATEADD(DAY,-40,GETDATE()), DATEADD(DAY,15,GETDATE())),

('Divya Kumar', '9876543213', 'Postpaid', 4, 0,
 DATEADD(DAY,-90,GETDATE()), DATEADD(DAY,20,GETDATE())),

('Karthik S', '9876543214', 'Prepaid', 3, 10,
 DATEADD(DAY,-70,GETDATE()), DATEADD(DAY,10,GETDATE())),

('Meena Raj', '9876543215', 'Postpaid', 5, 0,
 DATEADD(DAY,-80,GETDATE()), DATEADD(DAY,25,GETDATE()));
GO

INSERT INTO RechargeHistory
(SubscriberID, PlanID, RechargeAmount, RechargeDate,
 ValidityEndDate, RechargeStatus)
VALUES
(1001, 1, 199, DATEADD(DAY,-50,GETDATE()), DATEADD(DAY,-22,GETDATE()), 'Success'),
(1001, 2, 299, DATEADD(DAY,-25,GETDATE()), DATEADD(DAY,31,GETDATE()), 'Success'),
(1002, 2, 299, DATEADD(DAY,-20,GETDATE()), DATEADD(DAY,36,GETDATE()), 'Success'),
(1003, 1, 199, DATEADD(DAY,-30,GETDATE()), DATEADD(DAY,-2,GETDATE()), 'Success'),
(1003, 1, 199, DATEADD(DAY,-5,GETDATE()), DATEADD(DAY,23,GETDATE()), 'Success'),
(1005, 3, 499, DATEADD(DAY,-15,GETDATE()), DATEADD(DAY,69,GETDATE()), 'Success');
GO

CREATE VIEW vw_prepaid_subscribers
AS
SELECT
    s.SubscriberID,
    s.SubscriberName,
    s.PhoneNumber,
    s.PlanID,
    p.PlanName,
    s.Balance,
    s.ActivationDate,
    s.ValidityEndDate,
    s.SubscriberStatus
FROM Subscribers s
INNER JOIN Plans p
    ON s.PlanID = p.PlanID
WHERE s.SubscriberType = 'Prepaid';
GO

SELECT * FROM vw_prepaid_subscribers;
GO

CREATE VIEW vw_recharge_summary
AS
SELECT
    s.SubscriberID,
    s.SubscriberName,
    s.PhoneNumber,
    COUNT(r.RechargeID) AS TotalRecharges,
    ISNULL(SUM(r.RechargeAmount), 0) AS TotalRechargeAmount,
    MAX(r.RechargeDate) AS LastRechargeDate
FROM Subscribers s
LEFT JOIN RechargeHistory r
    ON s.SubscriberID = r.SubscriberID
    AND r.RechargeStatus = 'Success'
GROUP BY
    s.SubscriberID,
    s.SubscriberName,
    s.PhoneNumber;
GO

SELECT * FROM vw_recharge_summary;
GO

CREATE VIEW vw_prepaid_only
AS
SELECT
    SubscriberID,
    SubscriberName,
    PhoneNumber,
    PlanID,
    Balance,
    ValidityEndDate,
    SubscriberStatus
FROM Subscribers
WHERE SubscriberType = 'Prepaid'
WITH CHECK OPTION;
GO

SELECT * FROM vw_prepaid_only;
GO

UPDATE vw_prepaid_only
SET Balance = 30
WHERE SubscriberID = 1001;
GO

SELECT * FROM vw_prepaid_only;
GO
