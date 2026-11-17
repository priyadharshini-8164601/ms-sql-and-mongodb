-- Query 1: Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- Query 2: Month-wise sales
SELECT
    FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS monthly_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY sales_month;

-- Query 3: Customers with more than three orders (HAVING)
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3;

-- Query 4: Average basket value per city
SELECT
    c.city,
    ROUND(
        AVG(order_total),
        2
    ) AS average_basket_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) ot
    ON o.order_id = ot.order_id
GROUP BY c.city
ORDER BY average_basket_value DESC;

-- Query 5: Orders without payment (LEFT JOIN)
SELECT
    o.order_id,
    c.customer_name,
    o.order_date
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN payments p
    ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

-- Query 6: Customers with no orders
SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Query 7: Product-category revenue share
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        (SELECT SUM(quantity * unit_price)
         FROM order_items),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- Query 8: Day with the highest sales
SELECT TOP 1
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS daily_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY daily_sales DESC;

-- task2: demonstrate UPPER, CONCAT, DATEDIFF, FORMAT and ROUND.

SELECT
    o.order_id,

    CONCAT(
        UPPER(c.customer_name),
        ' - ',
        UPPER(c.city)
    ) AS customer_details,

    FORMAT(o.order_date, 'dd-MMM-yyyy') AS formatted_order_date,

    DATEDIFF(DAY, o.order_date, GETDATE()) AS days_since_order,

    ROUND(
        SUM(oi.quantity * oi.unit_price),
        2
    ) AS order_amount

FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    o.order_id,
    c.customer_name,
    c.city,
    o.order_date

ORDER BY o.order_id;

-- task3:demonstrate the difference between COUNT(*), COUNT(column) and AVG(column).
SELECT
    COUNT(*) AS total_orders,

    COUNT(p.payment_id) AS paid_orders,

    AVG(p.payment_amount) AS average_payment

FROM orders o
LEFT JOIN payments p
    ON o.order_id = p.order_id;