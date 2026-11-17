CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    date_of_birth DATE,
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(50)
);

CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    agent_id INT,
    start_date DATE,
    expiry_date DATE,
    annual_premium DECIMAL(10,2),
    status VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (agent_id)
        REFERENCES agents(agent_id)
);

CREATE TABLE premiums (
    payment_id INT PRIMARY KEY,
    policy_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,

    FOREIGN KEY (policy_id)
        REFERENCES policies(policy_id)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_amount DECIMAL(10,2),
    claim_date DATE,
    claim_status VARCHAR(30),
    settlement_date DATE,

    FOREIGN KEY (policy_id)
        REFERENCES policies(policy_id)
);


INSERT INTO customers VALUES
(1, 'Asha', '1990-05-10', 'Chennai'),
(2, 'Ravi', '1985-08-15', 'Coimbatore'),
(3, 'Meena', '1998-03-20', 'Chennai'),
(4, 'Karthik', '1975-11-12', 'Madurai'),
(5, 'Divya', '2002-06-25', 'Coimbatore'),
(6, 'Arun', '1968-04-18', 'Salem'),
(7, 'Nila', '1992-09-05', 'Chennai'),
(8, 'Vijay', '1980-01-30', 'Madurai');

INSERT INTO products VALUES
(1, 'Health Insurance'),
(2, 'Motor Insurance'),
(3, 'Life Insurance'),
(4, 'Travel Insurance');

INSERT INTO agents VALUES
(1, 'Anu'),
(2, 'Bala'),
(3, 'Charu'),
(4, 'Deepak');

INSERT INTO policies VALUES
(101, 1, 1, 1, '2025-01-05',
 DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), 12000, 'Active'),

(102, 1, 2, 1, '2025-01-20',
 DATEADD(DAY, 200, CAST(GETDATE() AS DATE)), 8000, 'Active'),

(103, 2, 3, 2, '2025-02-02',
 DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), 20000, 'Active'),

(104, 2, 1, 2, '2025-02-15',
 DATEADD(DAY, 300, CAST(GETDATE() AS DATE)), 10000, 'Active'),

(105, 3, 2, 3, '2025-02-20',
 DATEADD(DAY, 40, CAST(GETDATE() AS DATE)), 9000, 'Active'),

(106, 4, 3, 1, '2024-03-10',
 DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), 25000, 'Expired'),

(107, 5, 4, 4, '2025-03-05',
 DATEADD(DAY, 15, CAST(GETDATE() AS DATE)), 5000, 'Active'),

(108, 6, 1, 3, '2025-03-10',
 DATEADD(DAY, 60, CAST(GETDATE() AS DATE)), 15000, 'Active'),

(109, 7, 2, 4, '2025-03-15',
 DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), 11000, 'Active'),

(110, 8, 3, 2, '2025-04-01',
 DATEADD(DAY, 400, CAST(GETDATE() AS DATE)), 22000, 'Active');

 INSERT INTO premiums VALUES
(1, 101, 12000, '2025-01-05'),
(2, 102, 8000, '2025-01-20'),
(3, 103, 20000, '2025-02-02'),
(4, 104, 10000, '2025-02-15'),
(5, 105, 9000, '2025-02-20'),
(6, 106, 25000, '2024-03-10'),
(7, 107, 5000, '2025-03-05'),
(8, 108, 15000, '2025-03-10'),
(9, 109, 11000, '2025-03-15'),
(10, 110, 22000, '2025-04-01');

INSERT INTO claims VALUES
(501, 101, 3000, '2025-02-10', 'Settled', '2025-02-20'),

(502, 103, 8000, '2025-03-10', 'Settled', '2025-03-25'),

(503, 105, 4500, '2025-04-05', 'Approved', NULL),

(504, 106, 20000, '2024-05-10', 'Settled', '2024-06-10'),

(505, 108, 6000, '2025-05-15', 'Settled', '2025-05-25'),

(506, 109, 2000, '2025-06-01', 'Pending', NULL);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM agents;
SELECT * FROM policies;
SELECT * FROM premiums;
SELECT * FROM claims;

-- Query 1: Policies expiring in the next 30 days
SELECT
    p.policy_id,
    c.customer_name,
    pr.product_name,
    p.expiry_date,
    p.annual_premium
FROM policies p
JOIN customers c
    ON p.customer_id = c.customer_id
JOIN products pr
    ON p.product_id = pr.product_id
WHERE p.status = 'Active'
AND p.expiry_date BETWEEN CAST(GETDATE() AS DATE)
AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
ORDER BY p.expiry_date;

-- Query 2: Premium collected per product
SELECT
    pr.product_name,
    SUM(pm.amount) AS total_premium_collected
FROM products pr
JOIN policies p
    ON pr.product_id = p.product_id
JOIN premiums pm
    ON p.policy_id = pm.policy_id
GROUP BY pr.product_id, pr.product_name
ORDER BY total_premium_collected DESC;

-- Query 3: Customers with more than one active policy
SELECT
    c.customer_name,
    COUNT(p.policy_id) AS active_policy_count
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
WHERE p.status = 'Active'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.policy_id) > 1;

-- Query 4: Claim ratio per product
WITH PremiumSummary AS (
    SELECT
        p.product_id,
        SUM(pm.amount) AS total_premium
    FROM policies p
    JOIN premiums pm
        ON p.policy_id = pm.policy_id
    GROUP BY p.product_id
),
ClaimSummary AS (
    SELECT
        p.product_id,
        SUM(c.claim_amount) AS total_claims
    FROM policies p
    JOIN claims c
        ON p.policy_id = c.policy_id
    GROUP BY p.product_id
)
SELECT
    pr.product_name,
    COALESCE(cs.total_claims, 0) AS total_claims,
    ps.total_premium,
    ROUND(
        COALESCE(cs.total_claims, 0) * 100.0 /
        NULLIF(ps.total_premium, 0),
        2
    ) AS claim_ratio_percentage
FROM products pr
JOIN PremiumSummary ps
    ON pr.product_id = ps.product_id
LEFT JOIN ClaimSummary cs
    ON pr.product_id = cs.product_id
ORDER BY claim_ratio_percentage DESC;

-- Query 5: Policies without claims
SELECT
    p.policy_id,
    c.customer_name,
    pr.product_name,
    p.annual_premium
FROM policies p
JOIN customers c
    ON p.customer_id = c.customer_id
JOIN products pr
    ON p.product_id = pr.product_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
WHERE cl.claim_id IS NULL;

--Query 6: Average premium by age band
SELECT
    CASE
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(
                       YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth
                   ) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 18 AND 24
            THEN '18-24'

        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(
                       YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth
                   ) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 25 AND 34
            THEN '25-34'

        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(
                       YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth
                   ) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 35 AND 44
            THEN '35-44'

        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(
                       YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth
                   ) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 45 AND 54
            THEN '45-54'

        ELSE '55+'
    END AS age_band,

    ROUND(AVG(p.annual_premium), 2) AS average_premium

FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 18 AND 24 THEN '18-24'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR,
                       DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                       c.date_of_birth) > CAST(GETDATE() AS DATE)
                   THEN 1 ELSE 0
               END BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END
ORDER BY age_band;

-- Query 7: Monthly new policies
SELECT
    FORMAT(start_date, 'yyyy-MM') AS policy_month,
    COUNT(policy_id) AS new_policies
FROM policies
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY policy_month;

-- Query 8: Top 5 agents by premium
SELECT TOP 5
    a.agent_name,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    SUM(pm.amount) AS total_premium
FROM agents a
JOIN policies p
    ON a.agent_id = p.agent_id
JOIN premiums pm
    ON p.policy_id = pm.policy_id
GROUP BY a.agent_id, a.agent_name
ORDER BY total_premium DESC;

SELECT
    CONCAT(
        'POL-',
        REPLICATE('*', 5),
        RIGHT(CAST(p.policy_id AS VARCHAR(10)), 3)
    ) AS masked_policy_number,

    UPPER(c.customer_name) AS customer_name,

    CASE
        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                 WHEN DATEADD(
                     YEAR,
                     DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                     c.date_of_birth
                 ) > CAST(GETDATE() AS DATE)
                 THEN 1 ELSE 0
               END < 25
            THEN 'Young'

        WHEN DATEDIFF(YEAR, c.date_of_birth, GETDATE())
             - CASE
                 WHEN DATEADD(
                     YEAR,
                     DATEDIFF(YEAR, c.date_of_birth, GETDATE()),
                     c.date_of_birth
                 ) > CAST(GETDATE() AS DATE)
                 THEN 1 ELSE 0
               END BETWEEN 25 AND 40
            THEN 'Adult'

        ELSE 'Senior'
    END AS customer_age_band,

    DATEDIFF(DAY, p.start_date, p.expiry_date)
        AS policy_duration_days,

    p.status

FROM policies p
JOIN customers c
    ON p.customer_id = c.customer_id;

SELECT
    c.customer_name,
    COUNT(p.policy_id) AS active_policies
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id

WHERE p.status = 'Active'

GROUP BY c.customer_id, c.customer_name

HAVING COUNT(p.policy_id) > 1;


