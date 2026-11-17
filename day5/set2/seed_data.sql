
USE BankManagementDB;
GO

-- Customer records
INSERT INTO Customer (CustomerName,Address,Phone)
VALUES
('Arun','Coimbatore','9000000001'),
('Priya','Chennai','9000000002'),
('Karthik','Madurai','9000000003'),
('Divya','Salem','9000000004'),
('Ravi','Erode','9000000005'),
('Meena','Trichy','9000000006'),
('Vijay','Tiruppur','9000000007'),
('Anu','Bangalore','9000000008'),
('Rahul','Mysore','9000000009'),
('Sneha','Pondicherry','9000000010');

-- Branch records
INSERT INTO Branch (BranchName,BranchLocation)
VALUES
('Main Branch','Coimbatore'),
('City Branch','Chennai'),
('Central Branch','Madurai'),
('North Branch','Salem'),
('South Branch','Erode'),
('East Branch','Trichy'),
('West Branch','Tiruppur'),
('Metro Branch','Bangalore'),
('Rural Branch','Mysore'),
('Regional Branch','Pondicherry');

-- Relationship Manager records
INSERT INTO RelationshipManager (ManagerName,BranchID)
VALUES
('Manager Arun',1),
('Manager Bala',2),
('Manager Charan',3),
('Manager Deepa',4),
('Manager Elango',5),
('Manager Farah',6),
('Manager Gokul',7),
('Manager Hari',8),
('Manager Indhu',9),
('Manager Jaya',10);

-- Account records
INSERT INTO Account
(CustomerID,AccountNumber,AccountType,BranchID,ManagerID,Balance,OpenedDate)
VALUES
(1,'ACC1001','Savings',1,1,75000,'2026-08-10'),
(2,'ACC1002','Current',2,2,120000,'2026-09-15'),
(3,'ACC1003','Savings',3,3,45000,'2026-10-05'),
(4,'ACC1004','Current',4,4,95000,'2026-10-20'),
(5,'ACC1005','Savings',5,5,80000,'2026-11-01'),
(6,'ACC1006','Savings',6,6,25000,'2026-07-15'),
(7,'ACC1007','Current',7,7,150000,'2026-08-25'),
(8,'ACC1008','Savings',8,8,65000,'2026-09-20'),
(9,'ACC1009','Current',9,9,200000,'2026-10-12'),
(10,'ACC1010','Savings',10,10,55000,'2026-11-05');
GO

-- Display all records
SELECT * FROM Customer;
SELECT * FROM Branch;
SELECT * FROM RelationshipManager;
SELECT * FROM Account;
GO
