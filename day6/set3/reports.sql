CREATE DATABASE TelecomDB;
GO

USE TelecomDB;
GO

CREATE TABLE circles (
    circle_id INT PRIMARY KEY,
    circle_name VARCHAR(50)
);

CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    subscriber_name VARCHAR(50),
    mobile_number VARCHAR(15),
    circle_id INT,
    plan_id INT,
    FOREIGN KEY (circle_id) REFERENCES circles(circle_id)
);

CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    data_limit_gb DECIMAL(10,2),
    monthly_price DECIMAL(10,2)
);

CREATE TABLE call_records (
    record_id INT PRIMARY KEY,
    subscriber_id INT,
    call_date DATETIME,
    call_minutes DECIMAL(10,2),
    data_used_gb DECIMAL(10,2),

    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id)
);

CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    subscriber_id INT,
    invoice_date DATE,
    due_date DATE,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),

    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id)
);

ALTER TABLE subscribers
ADD CONSTRAINT FK_Subscribers_Plans
FOREIGN KEY (plan_id)
REFERENCES plans(plan_id);


INSERT INTO circles VALUES
(1, 'Chennai'),
(2, 'Coimbatore'),
(3, 'Madurai'),
(4, 'Salem');

INSERT INTO plans VALUES
(101, 'Basic Plan', 2, 199),
(102, 'Standard Plan', 5, 399),
(103, 'Premium Plan', 10, 599),
(104, 'Unlimited Plan', 20, 999);

INSERT INTO subscribers VALUES
(1, 'Asha', '9876543210', 1, 101),
(2, 'Ravi', '9876543211', 2, 102),
(3, 'Meena', '9876543212', 1, 103),
(4, 'Karthik', '9876543213', 3, 101),
(5, 'Divya', '9876543214', 2, 104),
(6, 'Arun', '9876543215', 4, 102);

INSERT INTO call_records VALUES
(1, 1, '2025-01-05 10:00:00', 30, 1.5),
(2, 1, '2025-01-06 11:00:00', 20, 1.2),

(3, 2, '2025-01-07 12:00:00', 45, 3.0),
(4, 2, '2025-01-08 13:00:00', 25, 2.5),

(5, 3, '2025-01-09 14:00:00', 60, 6.0),
(6, 3, '2025-01-10 15:00:00', 40, 5.0),

(7, 4, '2025-01-11 16:00:00', 15, 0.5),

(8, 5, '2025-01-12 17:00:00', 90, 12.0),
(9, 5, '2025-01-13 18:00:00', 30, 10.0);

INSERT INTO invoices VALUES
(1001, 1, '2025-01-01',
 DATEADD(DAY, -20, CAST(GETDATE() AS DATE)),
 199, 'Unpaid'),

(1002, 2, '2025-01-01',
 DATEADD(DAY, -10, CAST(GETDATE() AS DATE)),
 399, 'Unpaid'),

(1003, 3, '2025-02-01',
 DATEADD(DAY, -25, CAST(GETDATE() AS DATE)),
 599, 'Unpaid'),

(1004, 4, '2025-02-01',
 DATEADD(DAY, 10, CAST(GETDATE() AS DATE)),
 199, 'Paid'),

(1005, 5, '2025-03-01',
 DATEADD(DAY, -40, CAST(GETDATE() AS DATE)),
 999, 'Unpaid'),

(1006, 6, '2025-03-01',
 DATEADD(DAY, 5, CAST(GETDATE() AS DATE)),
 399, 'Paid');

 SELECT * FROM circles;
SELECT * FROM plans;
SELECT * FROM subscribers;
SELECT * FROM call_records;
SELECT * FROM invoices;

-- Query 1: Total call minutes per plan
SELECT
    p.plan_name,
    SUM(cr.call_minutes) AS total_call_minutes
FROM plans p
JOIN subscribers s
    ON p.plan_id = s.plan_id
JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
GROUP BY p.plan_id, p.plan_name
ORDER BY total_call_minutes DESC;

-- Query 2: Subscribers exceeding their data limit
SELECT
    s.subscriber_name,
    p.plan_name,
    p.data_limit_gb,
    SUM(cr.data_used_gb) AS total_data_used
FROM subscribers s
JOIN plans p
    ON s.plan_id = p.plan_id
JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
GROUP BY
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name,
    p.data_limit_gb
HAVING SUM(cr.data_used_gb) > p.data_limit_gb;

-- Query 3: Month-wise revenue
SELECT
    FORMAT(invoice_date, 'yyyy-MM') AS revenue_month,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY FORMAT(invoice_date, 'yyyy-MM')
ORDER BY revenue_month;

-- Query 4: Invoices overdue by more than 15 days
SELECT
    invoice_id,
    subscriber_id,
    amount,
    due_date,
    DATEDIFF(DAY, due_date, CAST(GETDATE() AS DATE))
        AS overdue_days
FROM invoices
WHERE payment_status = 'Unpaid'
AND DATEDIFF(DAY, due_date, CAST(GETDATE() AS DATE)) > 15
ORDER BY overdue_days DESC;

-- Query 5: Subscribers with no usage
SELECT
    s.subscriber_id,
    s.subscriber_name,
    s.mobile_number
FROM subscribers s
LEFT JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
WHERE cr.record_id IS NULL;

-- Query 6: Average revenue per user (ARPU) by circle
SELECT
    c.circle_name,
    SUM(i.amount) AS total_revenue,
    COUNT(DISTINCT s.subscriber_id) AS total_subscribers,
    ROUND(
        SUM(i.amount) * 1.0 /
        COUNT(DISTINCT s.subscriber_id),
        2
    ) AS ARPU
FROM circles c
JOIN subscribers s
    ON c.circle_id = s.circle_id
JOIN invoices i
    ON s.subscriber_id = i.subscriber_id
GROUP BY c.circle_id, c.circle_name
ORDER BY ARPU DESC;

-- Query 7: Plan popularity
SELECT
    p.plan_name,
    COUNT(s.subscriber_id) AS total_subscribers
FROM plans p
LEFT JOIN subscribers s
    ON p.plan_id = s.plan_id
GROUP BY p.plan_id, p.plan_name
ORDER BY total_subscribers DESC;

-- Query 8: Top 10 data consumers
SELECT TOP 10
    s.subscriber_name,
    p.plan_name,
    SUM(cr.data_used_gb) AS total_data_used
FROM subscribers s
JOIN plans p
    ON s.plan_id = p.plan_id
JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
GROUP BY
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name
ORDER BY total_data_used DESC;


SELECT
    CONCAT(
        'INV-',
        RIGHT(CONCAT('00000', CAST(invoice_id AS VARCHAR(10))), 5)
    ) AS formatted_invoice_number,

    UPPER(s.subscriber_name) AS subscriber_name,

    FORMAT(i.invoice_date, 'dd-MMM-yyyy') AS invoice_date,

    FORMAT(i.due_date, 'dd-MMM-yyyy') AS due_date,

    DATEDIFF(
        DAY,
        i.due_date,
        CAST(GETDATE() AS DATE)
    ) AS days_from_due_date,

    CASE
        WHEN i.payment_status = 'Paid'
            THEN 'Paid'

        WHEN i.due_date < CAST(GETDATE() AS DATE)
            THEN 'Overdue'

        ELSE 'Due Soon'
    END AS due_date_status

FROM invoices i
JOIN subscribers s
    ON i.subscriber_id = s.subscriber_id

ORDER BY i.invoice_id;


SELECT
    COUNT(*) AS total_rows,

    COUNT(cr.data_used_gb) AS usage_records,

    SUM(cr.data_used_gb) AS total_data_used,

    AVG(cr.data_used_gb) AS average_data_used

FROM subscribers s
LEFT JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id;


