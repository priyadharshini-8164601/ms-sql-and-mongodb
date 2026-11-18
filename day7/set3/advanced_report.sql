CREATE DATABASE RetailReturnsDB;

GO
USE RetailReturnsDB;


GO
-- =========================================================
-- 1. CREATE TABLES
-- =========================================================
CREATE TABLE Stores (
    store_id   INT           PRIMARY KEY,
    store_name VARCHAR (100),
    city       VARCHAR (100),
    region     VARCHAR (100)
);

CREATE TABLE Customers (
    customer_id   INT           PRIMARY KEY,
    customer_name VARCHAR (100),
    city          VARCHAR (100)
);

CREATE TABLE Employees (
    employee_id   INT           PRIMARY KEY,
    employee_name VARCHAR (100),
    manager_id    INT           NULL,
    store_id      INT          ,
    FOREIGN KEY (manager_id) REFERENCES Employees (employee_id),
    FOREIGN KEY (store_id) REFERENCES Stores (store_id)
);

CREATE TABLE Products (
    product_id   INT             PRIMARY KEY,
    product_name VARCHAR (100)  ,
    category     VARCHAR (100)  ,
    price        DECIMAL (10, 2)
);

CREATE TABLE Sales (
    sale_id     INT  PRIMARY KEY,
    customer_id INT ,
    product_id  INT ,
    store_id    INT ,
    quantity    INT ,
    sale_date   DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
    FOREIGN KEY (product_id) REFERENCES Products (product_id),
    FOREIGN KEY (store_id) REFERENCES Stores (store_id)
);

CREATE TABLE Returns (
    return_id     INT           PRIMARY KEY,
    sale_id       INT          ,
    customer_id   INT          ,
    product_id    INT          ,
    store_id      INT          ,
    return_date   DATE         ,
    return_reason VARCHAR (200),
    FOREIGN KEY (sale_id) REFERENCES Sales (sale_id),
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
    FOREIGN KEY (product_id) REFERENCES Products (product_id),
    FOREIGN KEY (store_id) REFERENCES Stores (store_id)
);

CREATE TABLE Refunds (
    refund_id     INT             PRIMARY KEY,
    return_id     INT            ,
    refund_amount DECIMAL (10, 2),
    refund_date   DATE           ,
    FOREIGN KEY (return_id) REFERENCES Returns (return_id)
);

CREATE TABLE ReturnFeedback (
    feedback_id   INT           PRIMARY KEY,
    return_id     INT          ,
    feedback_text VARCHAR (300),
    rating        INT          ,
    FOREIGN KEY (return_id) REFERENCES Returns (return_id)
);

-- =========================================================
-- 2. INSERT SAMPLE DATA
-- =========================================================
INSERT  INTO Stores
VALUES (1, 'Chennai Central Store', 'Chennai', 'South'),
       (2, 'Coimbatore Store', 'Coimbatore', 'South'),
       (3, 'Bangalore Store', 'Bangalore', 'South'),
       (4, 'Mumbai Store', 'Mumbai', 'West'),
       (5, 'Delhi Store', 'Delhi', 'North');

INSERT  INTO Customers
VALUES (101, 'Arun', 'Chennai'),
       (102, 'Priya', 'Coimbatore'),
       (103, 'Karthik', 'Bangalore'),
       (104, 'Divya', 'Mumbai'),
       (105, 'Rahul', 'Delhi'),
       (106, 'Meena', 'Chennai');

INSERT  INTO Employees
VALUES (201, 'Ramesh', NULL, 1),
       (202, 'Suresh', 201, 1),
       (203, 'Anitha', 201, 2),
       (204, 'Kumar', 202, 3),
       (205, 'Meena', 203, 4);

INSERT  INTO Products
VALUES (1, 'Laptop', 'Electronics', 50000),
       (2, 'Mobile', 'Electronics', 20000),
       (3, 'Headphones', 'Accessories', 3000),
       (4, 'Keyboard', 'Accessories', 1500),
       (5, 'Monitor', 'Electronics', 12000),
       (6, 'Mouse', 'Accessories', 800),
       (7, 'Printer', 'Electronics', 15000);

INSERT  INTO Sales
VALUES (1001, 101, 1, 1, 2, '2026-10-01'),
       (1002, 102, 2, 2, 3, '2026-10-02'),
       (1003, 103, 3, 3, 5, '2026-10-03'),
       (1004, 104, 1, 4, 1, '2026-10-04'),
       (1005, 105, 4, 5, 4, '2026-10-05'),
       (1006, 101, 2, 1, 2, '2026-10-06'),
       (1007, 102, 5, 2, 2, '2026-10-07'),
       (1008, 103, 6, 3, 5, '2026-10-08'),
       (1009, 104, 3, 4, 2, '2026-10-09'),
       (1010, 106, 4, 1, 3, '2026-10-10'),
       (1011, 105, 7, 5, 1, '2026-10-11'),
       (1012, 106, 5, 1, 1, '2026-10-12');

INSERT  INTO Returns
VALUES (501, 1001, 101, 1, 1, '2026-10-10', 'Damaged product'),
       (502, 1002, 102, 2, 2, '2026-10-11', 'Wrong item'),
       (503, 1003, 103, 3, 3, '2026-10-12', 'Not satisfied'),
       (504, 1004, 104, 1, 4, '2026-10-13', 'Defective product'),
       (505, 1005, 105, 4, 5, '2026-10-14', 'Wrong size'),
       (506, 1006, 101, 2, 1, '2026-10-15', 'Damaged product'),
       (507, 1008, 103, 6, 3, '2026-10-16', 'Poor quality'),
       (508, 1010, 106, 4, 1, '2026-10-17', 'Wrong item');

INSERT  INTO Refunds
VALUES (701, 501, 100000, '2026-10-11'),
       (702, 502, 60000, '2026-10-12'),
       (703, 503, 15000, '2026-10-13'),
       (704, 504, 50000, '2026-10-14'),
       (705, 505, 6000, '2026-10-15'),
       (706, 507, 4000, '2026-10-17');

INSERT  INTO ReturnFeedback
VALUES (801, 501, 'Product arrived damaged', 2),
       (802, 502, 'Received incorrect product', 3),
       (803, 503, 'Product quality was poor', 2),
       (804, 504, 'Refund processed successfully', 4),
       (805, 505, 'Return process was easy', 5),
       (806, 506, 'Waiting for refund', 2),
       (807, 507, 'Good customer support', 4);

-- =========================================================
-- 3. TEN BUSINESS QUESTIONS USING JOINS
-- =========================================================
-- Q1. Find products having a return rate above 10%.
-- Return rate = Returned quantity / Sold quantity * 100.
-- This dataset uses one unit per sale record for this
-- return-rate calculation.
SELECT   p.product_id,
         p.product_name,
         COUNT(DISTINCT s.sale_id) AS total_sales,
         COUNT(DISTINCT r.return_id) AS total_returns,
         CAST (COUNT(DISTINCT r.return_id) * 100.0 / NULLIF (COUNT(DISTINCT s.sale_id), 0) AS DECIMAL (10, 2)) AS return_rate
FROM     Products AS p
         INNER JOIN
         Sales AS s
         ON p.product_id = s.product_id
         LEFT OUTER JOIN
         Returns AS r
         ON s.sale_id = r.sale_id
GROUP BY p.product_id, p.product_name
HAVING   COUNT(DISTINCT r.return_id) * 100.0 / NULLIF (COUNT(DISTINCT s.sale_id), 0) > 10;

-- Q2. Find customers who have returns but no refunds.
SELECT DISTINCT c.customer_id,
                c.customer_name,
                r.return_id
FROM   Customers AS c
       INNER JOIN
       Returns AS r
       ON c.customer_id = r.customer_id
       LEFT OUTER JOIN
       Refunds AS f
       ON r.return_id = f.return_id
WHERE  f.refund_id IS NULL;

-- Q3. Find stores with the highest refund value.
SELECT   s.store_id,
         s.store_name,
         COALESCE (SUM(f.refund_amount), 0) AS total_refund
FROM     Stores AS s
         LEFT OUTER JOIN
         Returns AS r
         ON s.store_id = r.store_id
         LEFT OUTER JOIN
         Refunds AS f
         ON r.return_id = f.return_id
GROUP BY s.store_id, s.store_name
ORDER BY total_refund DESC;

-- Q4. Display employees and their managers.
-- SELF JOIN.
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM   Employees AS e
       LEFT OUTER JOIN
       Employees AS m
       ON e.manager_id = m.employee_id;

-- Q5. Display all products and their return details,
-- including products without returns.
SELECT p.product_name,
       r.return_id,
       r.return_reason
FROM   Products AS p
       LEFT OUTER JOIN
       Returns AS r
       ON p.product_id = r.product_id;

-- Q6. Display all stores and their sales,
-- including stores without sales.
SELECT st.store_name,
       s.sale_id,
       s.sale_date
FROM   Stores AS st
       LEFT OUTER JOIN
       Sales AS s
       ON st.store_id = s.store_id;

-- Q7. Display return details with customer and product names.
SELECT r.return_id,
       c.customer_name,
       p.product_name,
       r.return_reason
FROM   Returns AS r
       INNER JOIN
       Customers AS c
       ON r.customer_id = c.customer_id
       INNER JOIN
       Products AS p
       ON r.product_id = p.product_id;

-- Q8. Display all stores and returns using FULL OUTER JOIN.
SELECT st.store_name,
       r.return_id,
       r.return_reason
FROM   Stores AS st
       FULL OUTER JOIN
       Returns AS r
       ON st.store_id = r.store_id;

-- Q9. Display return details with their refund information.
SELECT r.return_id,
       r.return_reason,
       f.refund_amount,
       f.refund_date
FROM   Returns AS r
       LEFT OUTER JOIN
       Refunds AS f
       ON r.return_id = f.return_id;

-- Q10. Display customer purchase and return details.
SELECT c.customer_name,
       p.product_name,
       s.sale_id,
       r.return_id,
       r.return_reason
FROM   Customers AS c
       INNER JOIN
       Sales AS s
       ON c.customer_id = s.customer_id
       INNER JOIN
       Products AS p
       ON s.product_id = p.product_id
       LEFT OUTER JOIN
       Returns AS r
       ON s.sale_id = r.sale_id;

-- =========================================================
-- 4. IN AND NOT IN SUBQUERIES
-- =========================================================
-- Q11. Find customers who have returned products.
SELECT customer_id,
       customer_name
FROM   Customers
WHERE  customer_id IN (SELECT customer_id
                       FROM   Returns);

-- Q12. Find customers who have never returned products.
SELECT customer_id,
       customer_name
FROM   Customers
WHERE  customer_id NOT IN (SELECT customer_id
                           FROM   Returns);

-- =========================================================
-- 5. NOT IN NULL PITFALL DEMONSTRATION
-- =========================================================
-- Insert a NULL customer_id into a temporary demonstration table.
-- The actual Returns table has a NOT NULL foreign key column.
CREATE TABLE ReturnCustomerDemo (
    customer_id INT NULL
);

INSERT  INTO ReturnCustomerDemo
VALUES (101),
       (102),
       (NULL);

-- This query returns no rows because the subquery contains NULL.
SELECT customer_id,
       customer_name
FROM   Customers
WHERE  customer_id NOT IN (SELECT customer_id
                           FROM   ReturnCustomerDemo);

-- Correct solution using NOT EXISTS.
SELECT c.customer_id,
       c.customer_name
FROM   Customers AS c
WHERE  NOT EXISTS (SELECT 1
                   FROM   ReturnCustomerDemo AS d
                   WHERE  d.customer_id = c.customer_id);

DROP TABLE ReturnCustomerDemo;

-- =========================================================
-- 6. ANY AND ALL SUBQUERIES
-- Compare stores' refund values with other stores
-- in the same region.
-- =========================================================
-- Q13. ANY:
-- Stores whose refund value is greater than at least
-- one other store's refund value in the same region.
WITH   StoreRefunds
AS     (SELECT   s.store_id,
                 s.store_name,
                 s.region,
                 COALESCE (SUM(f.refund_amount), 0) AS total_refund
        FROM     Stores AS s
                 LEFT OUTER JOIN
                 Returns AS r
                 ON s.store_id = r.store_id
                 LEFT OUTER JOIN
                 Refunds AS f
                 ON r.return_id = f.return_id
        GROUP BY s.store_id, s.store_name, s.region)
SELECT sr.store_id,
       sr.store_name,
       sr.region,
       sr.total_refund
FROM   StoreRefunds AS sr
WHERE  sr.total_refund > ANY (SELECT sr2.total_refund
                              FROM   StoreRefunds AS sr2
                              WHERE  sr2.region = sr.region
                                     AND sr2.store_id <> sr.store_id);

-- Q14. ALL:
-- Stores whose refund value is greater than every
-- other store's refund value in the same region.
WITH   StoreRefunds
AS     (SELECT   s.store_id,
                 s.store_name,
                 s.region,
                 COALESCE (SUM(f.refund_amount), 0) AS total_refund
        FROM     Stores AS s
                 LEFT OUTER JOIN
                 Returns AS r
                 ON s.store_id = r.store_id
                 LEFT OUTER JOIN
                 Refunds AS f
                 ON r.return_id = f.return_id
        GROUP BY s.store_id, s.store_name, s.region)
SELECT sr.store_id,
       sr.store_name,
       sr.region,
       sr.total_refund
FROM   StoreRefunds AS sr
WHERE  sr.total_refund > ALL (SELECT sr2.total_refund
                              FROM   StoreRefunds AS sr2
                              WHERE  sr2.region = sr.region
                                     AND sr2.store_id <> sr.store_id);

-- =========================================================
-- 7. TWO NESTED SUBQUERIES
-- =========================================================
-- Q15. Find products whose total return count is
-- greater than the average return count per product.
SELECT p.product_id,
       p.product_name
FROM   Products AS p
WHERE  (SELECT COUNT(*)
        FROM   Returns AS r
        WHERE  r.product_id = p.product_id) > (SELECT AVG(return_count)
                                               FROM   (SELECT   product_id,
                                                                COUNT(*) AS return_count
                                                       FROM     Returns
                                                       GROUP BY product_id) AS ProductReturnCounts);

-- Q16. Find stores whose total refund value is
-- greater than the average total refund value
-- across all stores.
SELECT s.store_id,
       s.store_name
FROM   Stores AS s
WHERE  (SELECT COALESCE (SUM(f.refund_amount), 0)
        FROM   Returns AS r
               INNER JOIN
               Refunds AS f
               ON r.return_id = f.return_id
        WHERE  r.store_id = s.store_id) > (SELECT AVG(store_refund)
                                           FROM   (SELECT   st.store_id,
                                                            COALESCE (SUM(f.refund_amount), 0) AS store_refund
                                                   FROM     Stores AS st
                                                            LEFT OUTER JOIN
                                                            Returns AS r
                                                            ON st.store_id = r.store_id
                                                            LEFT OUTER JOIN
                                                            Refunds AS f
                                                            ON r.return_id = f.return_id
                                                   GROUP BY st.store_id) AS StoreRefundTotals);

-- =========================================================
-- 8. ADDITIONAL REPORTS
-- =========================================================
-- Q17. Total returns by product.
SELECT   p.product_name,
         COUNT(r.return_id) AS total_returns
FROM     Products AS p
         LEFT OUTER JOIN
         Returns AS r
         ON p.product_id = r.product_id
GROUP BY p.product_name;

-- Q18. Total refunds by customer.
SELECT   c.customer_name,
         COALESCE (SUM(f.refund_amount), 0) AS total_refunds
FROM     Customers AS c
         LEFT OUTER JOIN
         Returns AS r
         ON c.customer_id = r.customer_id
         LEFT OUTER JOIN
         Refunds AS f
         ON r.return_id = f.return_id
GROUP BY c.customer_id, c.customer_name;

-- Q19. Return details with customer feedback.
SELECT r.return_id,
       c.customer_name,
       p.product_name,
       rf.feedback_text,
       rf.rating
FROM   Returns AS r
       INNER JOIN
       Customers AS c
       ON r.customer_id = c.customer_id
       INNER JOIN
       Products AS p
       ON r.product_id = p.product_id
       LEFT OUTER JOIN
       ReturnFeedback AS rf
       ON r.return_id = rf.return_id;

-- Q20. Average feedback rating for each store.
SELECT   s.store_name,
         AVG(CAST (rf.rating AS DECIMAL (5, 2))) AS average_rating
FROM     Stores AS s
         LEFT OUTER JOIN
         Returns AS r
         ON s.store_id = r.store_id
         LEFT OUTER JOIN
         ReturnFeedback AS rf
         ON r.return_id = rf.return_id
GROUP BY s.store_id, s.store_name;


-- =========================================================
-- END OF RETAIL RETURNS AND REFUNDS
-- =========================================================