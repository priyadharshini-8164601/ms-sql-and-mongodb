CREATE DATABASE BankLoanDB;


GO
USE BankLoanDB;


GO
-- =========================================================
-- 1. CREATE TABLES
-- =========================================================
CREATE TABLE Branches (
    branch_id   INT           PRIMARY KEY,
    branch_name VARCHAR (100),
    city        VARCHAR (100)
);

CREATE TABLE Customers (
    customer_id   INT           PRIMARY KEY,
    customer_name VARCHAR (100),
    city          VARCHAR (100)
);

CREATE TABLE Loans (
    loan_id            INT             PRIMARY KEY,
    customer_id        INT            ,
    branch_id          INT            ,
    loan_amount        DECIMAL (12, 2),
    loan_date          DATE           ,
    total_installments INT            ,
    paid_installments  INT            ,
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
    FOREIGN KEY (branch_id) REFERENCES Branches (branch_id)
);

CREATE TABLE Repayments (
    repayment_id     INT             PRIMARY KEY,
    loan_id          INT            ,
    repayment_amount DECIMAL (12, 2),
    repayment_date   DATE           ,
    FOREIGN KEY (loan_id) REFERENCES Loans (loan_id)
);

CREATE TABLE Guarantors (
    guarantor_id INT PRIMARY KEY,
    loan_id      INT,
    customer_id  INT,
    FOREIGN KEY (loan_id) REFERENCES Loans (loan_id),
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
);

-- =========================================================
-- 2. INSERT SAMPLE DATA
-- =========================================================
INSERT  INTO Branches
VALUES (1, 'Chennai Main Branch', 'Chennai'),
       (2, 'Coimbatore Branch', 'Coimbatore'),
       (3, 'Bangalore Branch', 'Bangalore'),
       (4, 'Madurai Branch', 'Madurai'),
       (5, 'Salem Branch', 'Salem');

INSERT  INTO Customers
VALUES (101, 'Arun', 'Chennai'),
       (102, 'Priya', 'Coimbatore'),
       (103, 'Karthik', 'Bangalore'),
       (104, 'Divya', 'Madurai'),
       (105, 'Rahul', 'Chennai'),
       (106, 'Meena', 'Salem'),
       (107, 'Suresh', 'Coimbatore');

INSERT  INTO Loans
VALUES (1001, 101, 1, 500000, '2026-01-10', 24, 10),
       (1002, 102, 2, 300000, '2026-02-15', 36, 20),
       (1003, 101, 2, 700000, '2026-03-01', 48, 15),
       (1004, 103, 3, 900000, '2026-01-20', 36, 10),
       (1005, 104, 1, 400000, '2026-04-10', 24, 5),
       (1006, 105, 3, 600000, '2026-02-20', 48, 30),
       (1007, 106, 2, 250000, '2026-05-01', 24, 8),
       (1008, 107, 4, 800000, '2026-03-15', 36, 18),
       (1009, 103, 1, 350000, '2026-06-10', 24, 12);

INSERT  INTO Repayments
VALUES (1, 1001, 20000, '2026-09-10'),
       (2, 1001, 20000, '2026-10-10'),
       (3, 1002, 15000, '2026-11-01'),
       (4, 1003, 25000, '2026-08-01'),
       (5, 1004, 30000, '2026-10-20'),
       (6, 1005, 18000, '2026-07-10'),
       (7, 1006, 22000, '2026-11-05'),
       (8, 1007, 12000, '2026-09-15'),
       (9, 1008, 28000, '2026-10-25');

INSERT  INTO Guarantors
VALUES (1, 1001, 102),
       (2, 1002, 101),
       (3, 1003, 103),
       (4, 1004, 105),
       (5, 1005, 101),
       (6, 1006, 104),
       (7, 1007, 107);

-- =========================================================
-- 3. TEN BUSINESS QUESTIONS USING JOINS
-- =========================================================
-- Q1. Find loans overdue by more than three installments.
SELECT l.loan_id,
       c.customer_name,
       l.total_installments,
       l.paid_installments,
       (l.total_installments - l.paid_installments) AS remaining_installments
FROM   Loans AS l
       INNER JOIN
       Customers AS c
       ON l.customer_id = c.customer_id
WHERE  (l.total_installments - l.paid_installments) > 3;

-- Q2. Find customers having loans in more than one branch.
SELECT   c.customer_id,
         c.customer_name,
         COUNT(DISTINCT l.branch_id) AS branch_count
FROM     Customers AS c
         INNER JOIN
         Loans AS l
         ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING   COUNT(DISTINCT l.branch_id) > 1;

-- Q3. Find guarantors who are also borrowers.
-- SELF JOIN
SELECT DISTINCT g.customer_id AS guarantor_customer_id,
                c.customer_name AS guarantor_name,
                l.customer_id AS borrower_customer_id
FROM   Guarantors AS g
       INNER JOIN
       Loans AS l
       ON g.customer_id = l.customer_id
       INNER JOIN
       Customers AS c
       ON g.customer_id = c.customer_id;

-- Q4. Display all branches, including branches without loans.
SELECT   b.branch_id,
         b.branch_name,
         COUNT(l.loan_id) AS total_loans
FROM     Branches AS b
         LEFT OUTER JOIN
         Loans AS l
         ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name;

-- Q5. Display loans with customer and branch details.
SELECT l.loan_id,
       c.customer_name,
       b.branch_name,
       l.loan_amount
FROM   Loans AS l
       INNER JOIN
       Customers AS c
       ON l.customer_id = c.customer_id
       INNER JOIN
       Branches AS b
       ON l.branch_id = b.branch_id;

-- Q6. Display all customers, including customers without loans.
SELECT c.customer_id,
       c.customer_name,
       l.loan_id,
       l.loan_amount
FROM   Customers AS c
       LEFT OUTER JOIN
       Loans AS l
       ON c.customer_id = l.customer_id;

-- Q7. Display all branches and loan records,
-- including unmatched records from either side.
SELECT b.branch_name,
       l.loan_id,
       l.loan_amount
FROM   Branches AS b
       FULL OUTER JOIN
       Loans AS l
       ON b.branch_id = l.branch_id;

-- Q8. Display loans and their repayment details.
SELECT l.loan_id,
       l.loan_amount,
       r.repayment_id,
       r.repayment_amount,
       r.repayment_date
FROM   Loans AS l
       LEFT OUTER JOIN
       Repayments AS r
       ON l.loan_id = r.loan_id;

-- Q9. Find total repayment amount for each loan.
SELECT   l.loan_id,
         c.customer_name,
         l.loan_amount,
         COALESCE (SUM(r.repayment_amount), 0) AS total_repaid
FROM     Loans AS l
         INNER JOIN
         Customers AS c
         ON l.customer_id = c.customer_id
         LEFT OUTER JOIN
         Repayments AS r
         ON l.loan_id = r.loan_id
GROUP BY l.loan_id, c.customer_name, l.loan_amount;

-- Q10. Display guarantor names and their borrowers.
SELECT g.loan_id,
       gc.customer_name AS guarantor_name,
       bc.customer_name AS borrower_name
FROM   Guarantors AS g
       INNER JOIN
       Customers AS gc
       ON g.customer_id = gc.customer_id
       INNER JOIN
       Loans AS l
       ON g.loan_id = l.loan_id
       INNER JOIN
       Customers AS bc
       ON l.customer_id = bc.customer_id;

-- =========================================================
-- 4. CORRELATED AND UNCORRELATED SUBQUERIES
-- =========================================================
-- Q11. CORRELATED SUBQUERY:
-- Customers whose total loan exposure exceeds
-- their branch's average customer loan exposure.
SELECT   c.customer_id,
         c.customer_name,
         SUM(l.loan_amount) AS total_exposure
FROM     Customers AS c
         INNER JOIN
         Loans AS l
         ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING   SUM(l.loan_amount) > (SELECT AVG(customer_exposure)
                               FROM   (SELECT   l2.customer_id,
                                                SUM(l2.loan_amount) AS customer_exposure
                                       FROM     Loans AS l2
                                       WHERE    l2.branch_id = l.branch_id
                                       GROUP BY l2.customer_id) AS BranchExposure);

-- Q12. UNCORRELATED SUBQUERY:
-- Customers whose total loan exposure exceeds
-- the overall average loan amount.
SELECT   c.customer_id,
         c.customer_name,
         SUM(l.loan_amount) AS total_exposure
FROM     Customers AS c
         INNER JOIN
         Loans AS l
         ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING   SUM(l.loan_amount) > (SELECT AVG(loan_amount)
                               FROM   Loans);

-- =========================================================
-- 5. EXISTS AND NOT EXISTS
-- =========================================================
-- Q13. Customers who have loans but no repayment
-- in the last 60 days.
-- Uses EXISTS and NOT EXISTS.
SELECT c.customer_id,
       c.customer_name
FROM   Customers AS c
WHERE  EXISTS (SELECT 1
               FROM   Loans AS l
               WHERE  l.customer_id = c.customer_id)
       AND NOT EXISTS (SELECT 1
                       FROM   Loans AS l
                              INNER JOIN
                              Repayments AS r
                              ON l.loan_id = r.loan_id
                       WHERE  l.customer_id = c.customer_id
                              AND r.repayment_date >= DATEADD(DAY, -60, CAST (GETDATE() AS DATE)));

-- =========================================================
-- 6. NESTED SUBQUERY
-- Branches whose highest loan is greater than
-- the bank-wide average of branch maximum loans.
-- =========================================================
SELECT   b.branch_id,
         b.branch_name,
         MAX(l.loan_amount) AS highest_loan
FROM     Branches AS b
         INNER JOIN
         Loans AS l
         ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name
HAVING   MAX(l.loan_amount) > (SELECT AVG(branch_maximum)
                               FROM   (SELECT   branch_id,
                                                MAX(loan_amount) AS branch_maximum
                                       FROM     Loans
                                       GROUP BY branch_id) AS BranchMaximums);

-- =========================================================
-- 7. ADDITIONAL USEFUL REPORTS
-- =========================================================
-- Q15. Total loan amount for every branch.
SELECT   b.branch_name,
         COALESCE (SUM(l.loan_amount), 0) AS total_loan_amount
FROM     Branches AS b
         LEFT OUTER JOIN
         Loans AS l
         ON b.branch_id = l.branch_id
GROUP BY b.branch_name;

-- Q16. Customers with their total repayment amount.
SELECT   c.customer_name,
         COALESCE (SUM(r.repayment_amount), 0) AS total_repayment
FROM     Customers AS c
         LEFT OUTER JOIN
         Loans AS l
         ON c.customer_id = l.customer_id
         LEFT OUTER JOIN
         Repayments AS r
         ON l.loan_id = r.loan_id
GROUP BY c.customer_id, c.customer_name;


-- =========================================================
-- END OF BANK LOAN PORTFOLIO
-- =========================================================