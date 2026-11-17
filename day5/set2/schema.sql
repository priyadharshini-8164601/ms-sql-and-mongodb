
CREATE DATABASE BankManagementDB;
GO

USE BankManagementDB;
GO

-- 1. Customer Table
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    Phone VARCHAR(15) NOT NULL UNIQUE
);

-- 2. Branch Table
CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    BranchLocation VARCHAR(100) NOT NULL
);

-- 3. Relationship Manager Table
CREATE TABLE RelationshipManager (
    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
    ManagerName VARCHAR(100) NOT NULL,
    BranchID INT NOT NULL,

    FOREIGN KEY (BranchID)
    REFERENCES Branch(BranchID)
    ON DELETE NO ACTION
);

-- 4. Account Table
CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
    AccountType VARCHAR(30) NOT NULL,
    BranchID INT NOT NULL,
    ManagerID INT NOT NULL,
    Balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    OpenedDate DATE NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Account_Customer
    FOREIGN KEY (CustomerID)
    REFERENCES Customer(CustomerID)
    ON DELETE NO ACTION,

    CONSTRAINT FK_Account_Branch
    FOREIGN KEY (BranchID)
    REFERENCES Branch(BranchID)
    ON DELETE NO ACTION,

    CONSTRAINT FK_Account_Manager
    FOREIGN KEY (ManagerID)
    REFERENCES RelationshipManager(ManagerID)
    ON DELETE NO ACTION,

    CONSTRAINT CK_Account_Balance
    CHECK (AccountType <> 'Savings' OR Balance >= 0),

    CONSTRAINT UQ_Customer_Account_Branch
    UNIQUE (CustomerID, AccountType, BranchID)
);
GO
