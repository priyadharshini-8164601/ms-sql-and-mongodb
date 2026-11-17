USE RetailSalesDB;
GO

INSERT INTO customers VALUES
(1, 'Asha', 'Chennai'),
(2, 'Ravi', 'Coimbatore'),
(3, 'Meena', 'Chennai'),
(4, 'Karthik', 'Madurai'),
(5, 'Divya', 'Coimbatore'),
(6, 'Arun', 'Salem');

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 50000),
(2, 'Phone', 'Electronics', 20000),
(3, 'Chair', 'Furniture', 5000),
(4, 'Desk', 'Furniture', 10000),
(5, 'Headphones', 'Electronics', 2000);

INSERT INTO orders VALUES
(101, 1, '2025-01-05'),
(102, 1, '2025-01-20'),
(103, 2, '2025-01-21'),
(104, 2, '2025-02-02'),
(105, 2, '2025-02-15'),
(106, 2, '2025-03-01'),
(107, 3, '2025-02-10'),
(108, 4, '2025-03-05'),
(109, 5, '2025-03-06'),
(110, 5, '2025-03-07');

INSERT INTO order_items VALUES
(1, 101, 1, 1, 50000),
(2, 101, 5, 2, 2000),
(3, 102, 2, 1, 20000),
(4, 103, 3, 2, 5000),
(5, 104, 2, 1, 20000),
(6, 105, 4, 1, 10000),
(7, 106, 5, 3, 2000),
(8, 107, 1, 1, 50000),
(9, 108, 3, 1, 5000),
(10, 109, 4, 2, 10000),
(11, 110, 2, 1, 20000);

INSERT INTO payments VALUES
(1, 101, 54000, '2025-01-05'),
(2, 102, 20000, '2025-01-20'),
(3, 103, 10000, '2025-01-21'),
(4, 104, 20000, '2025-02-02'),
(5, 105, 10000, '2025-02-15'),
(6, 106, 6000, '2025-03-01'),
(7, 107, 50000, '2025-02-10'),
(8, 109, 20000, '2025-03-06'),
(9, 110, 20000, '2025-03-07');

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;