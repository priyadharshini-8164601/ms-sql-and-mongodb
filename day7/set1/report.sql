CREATE DATABASE LogisticsDB;


GO
USE LogisticsDB;


GO
-- =========================================================
-- 1. CREATE TABLES
-- =========================================================
CREATE TABLE Hubs (
    hub_id   INT           PRIMARY KEY,
    hub_name VARCHAR (100),
    city     VARCHAR (100)
);

CREATE TABLE Carriers (
    carrier_id   INT           PRIMARY KEY,
    carrier_name VARCHAR (100)
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
    FOREIGN KEY (manager_id) REFERENCES Employees (employee_id)
);

CREATE TABLE Shipments (
    shipment_id            INT             PRIMARY KEY,
    customer_id            INT            ,
    carrier_id             INT            ,
    origin_hub_id          INT            ,
    destination_hub_id     INT            ,
    employee_id            INT            ,
    shipping_cost          DECIMAL (10, 2),
    shipped_date           DATE           ,
    expected_delivery_date DATE           ,
    actual_delivery_date   DATE            NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id),
    FOREIGN KEY (carrier_id) REFERENCES Carriers (carrier_id),
    FOREIGN KEY (origin_hub_id) REFERENCES Hubs (hub_id),
    FOREIGN KEY (destination_hub_id) REFERENCES Hubs (hub_id),
    FOREIGN KEY (employee_id) REFERENCES Employees (employee_id)
);

CREATE TABLE DeliveryEvents (
    event_id    INT           PRIMARY KEY,
    shipment_id INT          ,
    event_type  VARCHAR (100),
    event_date  DATE         ,
    remarks     VARCHAR (200),
    FOREIGN KEY (shipment_id) REFERENCES Shipments (shipment_id)
);

-- =========================================================
-- 2. INSERT SAMPLE DATA
-- =========================================================
INSERT  INTO Hubs
VALUES (1, 'Central Hub', 'Chennai'),
       (2, 'North Hub', 'Bangalore'),
       (3, 'South Hub', 'Coimbatore'),
       (4, 'East Hub', 'Hyderabad'),
       (5, 'West Hub', 'Mumbai');

INSERT  INTO Carriers
VALUES (1, 'FastTrack Logistics'),
       (2, 'BlueDart Express'),
       (3, 'SpeedShip');

INSERT  INTO Customers
VALUES (1, 'Arun', 'Chennai'),
       (2, 'Priya', 'Coimbatore'),
       (3, 'Karthik', 'Bangalore'),
       (4, 'Divya', 'Hyderabad'),
       (5, 'Rahul', 'Mumbai');

INSERT  INTO Employees
VALUES (101, 'Ramesh', NULL),
       (102, 'Suresh', 101),
       (103, 'Anitha', 101),
       (104, 'Kumar', 102),
       (105, 'Meena', 102);

INSERT  INTO Shipments
VALUES (1001, 1, 1, 1, 2, 102, 500, '2026-10-01', '2026-10-03', '2026-10-06'),
       (1002, 1, 2, 1, 3, 103, 700, '2026-10-02', '2026-10-05', '2026-10-05'),
       (1003, 1, 1, 2, 4, 104, 900, '2026-10-03', '2026-10-06', '2026-10-10'),
       (1004, 1, 3, 3, 5, 105, 600, '2026-10-04', '2026-10-07', '2026-10-07'),
       (1005, 1, 2, 4, 1, 102, 800, '2026-10-05', '2026-10-08', '2026-10-12'),
       (1006, 2, 1, 1, 2, 103, 450, '2026-10-06', '2026-10-08', '2026-10-08'),
       (1007, 2, 2, 2, 3, 104, 550, '2026-10-07', '2026-10-10', '2026-10-14'),
       (1008, 3, 3, 3, 4, 105, 750, '2026-10-08', '2026-10-11', '2026-10-11'),
       (1009, 3, 1, 1, 5, 102, 650, '2026-10-09', '2026-10-12', NULL),
       (1010, 4, 2, 4, 2, 103, 950, '2026-10-10', '2026-10-13', '2026-10-18'),
       (1011, 5, 3, 5, 1, 104, 400, '2026-10-11', '2026-10-14', '2026-10-14');

INSERT  INTO DeliveryEvents
VALUES (1, 1001, 'Picked Up', '2026-10-01', 'Shipment collected'),
       (2, 1001, 'In Transit', '2026-10-02', 'Shipment moving'),
       (3, 1001, 'Delivered', '2026-10-06', 'Delivered late'),
       (4, 1002, 'Picked Up', '2026-10-02', 'Shipment collected'),
       (5, 1002, 'Delivered', '2026-10-05', 'Delivered on time'),
       (6, 1003, 'In Transit', '2026-10-05', 'Delayed in transit'),
       (7, 1003, 'Delivered', '2026-10-10', 'Delivered late'),
       (8, 1006, 'Delivered', '2026-10-08', 'Delivered on time');

-- =========================================================
-- 3. TEN BUSINESS QUESTIONS USING JOINS
-- =========================================================
-- Q1. Shipments delayed by more than two days with carrier names.
SELECT s.shipment_id,
       c.carrier_name,
       s.expected_delivery_date,
       s.actual_delivery_date,
       DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS delay_days
FROM   Shipments AS s
       INNER JOIN
       Carriers AS c
       ON s.carrier_id = c.carrier_id
WHERE  s.actual_delivery_date IS NOT NULL
       AND DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) > 2;

-- Q2. Display all hubs and their outbound shipment counts,
-- including hubs having zero outbound shipments.
SELECT   h.hub_id,
         h.hub_name,
         COUNT(s.shipment_id) AS outbound_shipments
FROM     Hubs AS h
         LEFT OUTER JOIN
         Shipments AS s
         ON h.hub_id = s.origin_hub_id
GROUP BY h.hub_id, h.hub_name;

-- Q3. Display employees and their respective supervisors.
-- SELF JOIN
SELECT e.employee_name AS employee,
       m.employee_name AS supervisor
FROM   Employees AS e
       LEFT OUTER JOIN
       Employees AS m
       ON e.manager_id = m.employee_id;

-- Q4. Display all shipments with customer and carrier details.
SELECT s.shipment_id,
       cu.customer_name,
       ca.carrier_name,
       s.shipping_cost
FROM   Shipments AS s
       INNER JOIN
       Customers AS cu
       ON s.customer_id = cu.customer_id
       INNER JOIN
       Carriers AS ca
       ON s.carrier_id = ca.carrier_id;

-- Q5. Display all customers, including customers without shipments.
SELECT cu.customer_id,
       cu.customer_name,
       s.shipment_id
FROM   Customers AS cu
       LEFT OUTER JOIN
       Shipments AS s
       ON cu.customer_id = s.customer_id;

-- Q6. Display all hubs and shipments,
-- including hubs without outbound shipments
-- and shipments with their corresponding origin hubs.
SELECT h.hub_name,
       s.shipment_id,
       s.shipping_cost
FROM   Hubs AS h
       FULL OUTER JOIN
       Shipments AS s
       ON h.hub_id = s.origin_hub_id;

-- Q7. Display shipment origin and destination hub names.
SELECT s.shipment_id,
       h1.hub_name AS origin_hub,
       h2.hub_name AS destination_hub
FROM   Shipments AS s
       INNER JOIN
       Hubs AS h1
       ON s.origin_hub_id = h1.hub_id
       INNER JOIN
       Hubs AS h2
       ON s.destination_hub_id = h2.hub_id;

-- Q8. Display shipments along with their delivery events.
SELECT s.shipment_id,
       d.event_type,
       d.event_date,
       d.remarks
FROM   Shipments AS s
       LEFT OUTER JOIN
       DeliveryEvents AS d
       ON s.shipment_id = d.shipment_id;

-- Q9. Display carriers and their total shipment counts,
-- including carriers without shipments.
SELECT   c.carrier_name,
         COUNT(s.shipment_id) AS total_shipments
FROM     Carriers AS c
         LEFT OUTER JOIN
         Shipments AS s
         ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name;

-- Q10. Display customers and their shipment destinations.
SELECT cu.customer_name,
       h.hub_name AS destination_hub,
       s.shipment_id
FROM   Customers AS cu
       INNER JOIN
       Shipments AS s
       ON cu.customer_id = s.customer_id
       INNER JOIN
       Hubs AS h
       ON s.destination_hub_id = h.hub_id;

-- =========================================================
-- 4. SUBQUERIES: IN, EXISTS, ANY AND ALL
-- =========================================================
-- Q11. Find customers who have shipped to every hub.
-- IN + NOT EXISTS (relational division)
SELECT cu.customer_id,
       cu.customer_name
FROM   Customers AS cu
WHERE  NOT EXISTS (SELECT 1
                   FROM   Hubs AS h
                   WHERE  h.hub_id NOT IN (SELECT s.destination_hub_id
                                           FROM   Shipments AS s
                                           WHERE  s.customer_id = cu.customer_id));

-- Q12. Find customers who have shipped to at least one hub.
-- IN
SELECT *
FROM   Customers
WHERE  customer_id IN (SELECT customer_id
                       FROM   Shipments);

-- Q13. Find customers who have at least one shipment.
-- EXISTS (correlated subquery)
SELECT cu.customer_id,
       cu.customer_name
FROM   Customers AS cu
WHERE  EXISTS (SELECT 1
               FROM   Shipments AS s
               WHERE  s.customer_id = cu.customer_id);

-- Q14. Find carriers whose average shipment delay
-- is above the overall average shipment delay.
SELECT   c.carrier_id,
         c.carrier_name,
         AVG(CAST (DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS DECIMAL (10, 2))) AS avg_delay
FROM     Carriers AS c
         INNER JOIN
         Shipments AS s
         ON c.carrier_id = s.carrier_id
WHERE    s.actual_delivery_date IS NOT NULL
GROUP BY c.carrier_id, c.carrier_name
HAVING   AVG(CAST (DATEDIFF(DAY, s.expected_delivery_date, s.actual_delivery_date) AS DECIMAL (10, 2))) > (SELECT AVG(CAST (DATEDIFF(DAY, expected_delivery_date, actual_delivery_date) AS DECIMAL (10, 2)))
                                                                                                           FROM   Shipments
                                                                                                           WHERE  actual_delivery_date IS NOT NULL);

-- Q15. Find shipment costs greater than ANY shipment
-- cost handled by carrier 1.
SELECT shipment_id,
       shipping_cost
FROM   Shipments
WHERE  shipping_cost > ANY (SELECT shipping_cost
                            FROM   Shipments
                            WHERE  carrier_id = 1);

-- Q16. Find shipment costs greater than ALL shipment
-- costs handled by carrier 1.
SELECT shipment_id,
       shipping_cost
FROM   Shipments
WHERE  shipping_cost > ALL (SELECT shipping_cost
                            FROM   Shipments
                            WHERE  carrier_id = 1);

-- =========================================================
-- 5. REWRITE SUBQUERIES AS JOINS
-- =========================================================
-- Q17. SUBQUERY VERSION:
-- Customers who have shipments.
SELECT customer_id,
       customer_name
FROM   Customers
WHERE  customer_id IN (SELECT customer_id
                       FROM   Shipments);

-- JOIN VERSION:
SELECT DISTINCT cu.customer_id,
                cu.customer_name
FROM   Customers AS cu
       INNER JOIN
       Shipments AS s
       ON cu.customer_id = s.customer_id;

-- Q18. SUBQUERY VERSION:
-- Shipments handled by FastTrack Logistics.
SELECT *
FROM   Shipments
WHERE  carrier_id IN (SELECT carrier_id
                      FROM   Carriers
                      WHERE  carrier_name = 'FastTrack Logistics');

-- JOIN VERSION:
SELECT s.*
FROM   Shipments AS s
       INNER JOIN
       Carriers AS c
       ON s.carrier_id = c.carrier_id
WHERE  c.carrier_name = 'FastTrack Logistics';

-- =========================================================
-- 6. NESTED SUBQUERY
-- Second-highest shipping cost per hub
-- =========================================================
SELECT h.hub_name,
       (SELECT MAX(s1.shipping_cost)
        FROM   Shipments AS s1
        WHERE  s1.origin_hub_id = h.hub_id
               AND s1.shipping_cost < (SELECT MAX(s2.shipping_cost)
                                       FROM   Shipments AS s2
                                       WHERE  s2.origin_hub_id = h.hub_id)) AS second_highest_shipping_cost
FROM   Hubs AS h;