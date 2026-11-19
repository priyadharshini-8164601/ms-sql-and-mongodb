
# Day 8 – Set 3: Retail Inventory Reservation

## Business Scenario

An online retail store needs to manage product stock when customers place orders. Stock should be reduced when an order is placed and restored if the payment fails. The system should also generate sales reports to analyse product performance.

## Files Included

| File Name | Description |
|---|---|
| reservation.sql | Handles stock reservation, order creation, transactions and rollback. |
| rank_report.sql | Uses correlated subqueries, CTEs and window functions to generate inventory and sales reports. |
| stock_update.js | Demonstrates MongoDB stock updates using the $inc operator. |

## Tasks Performed

### 1. Inventory Reservation Using SQL Transactions

Created Products, Orders and OrderDetails tables and inserted sample product records.

Implemented a stock reservation process using SQL transactions.

The transaction:
- Checks product availability.
- Decreases the available stock.
- Creates a new order.
- Inserts the order details.
- Commits all operations together.

Used TRY...CATCH, COMMIT and ROLLBACK for error handling.

### 2. Rollback Demonstration

Attempted to place an order for 100 headphones when only 5 were available.

The transaction detected insufficient stock and raised an error.

Used ROLLBACK to cancel the transaction. Verified that stock remained unchanged and no order was created.

Also demonstrated releasing reserved stock when a payment fails by restoring the product quantity and updating the order status.

### 3. Correlated Subquery

Used a correlated subquery to identify products whose available stock is below the average stock of their respective categories.

Compared each product's stock quantity with the average stock of products in the same category.

### 4. CTE-Based Product Sales Ranking

Created sample sales records and generated a product sales report using CTEs.

Used:
- ROW_NUMBER(): Assigns a unique rank to each product.
- PARTITION BY: Separates product rankings by category.
- SUM(): Calculates total units sold and total sales.

Displayed the top three products in each category based on units sold.

### 5. Month-on-Month Sales Comparison

Used LEAD() and LAG() to compare monthly sales for each product.

- LAG(): Retrieves the previous month's sales.
- LEAD(): Retrieves the next month's sales.
- Month-on-Month Change: Calculates the difference between the current month's sales and the previous month's sales.

### 6. MongoDB Stock Updates

Implemented stock management using MongoDB 8.0.

Created a products collection and inserted sample product documents.

Used the following operations:

- updateOne(): Updates a product document.
- $inc: Increases or decreases the stock quantity.
- $gte: Checks whether sufficient stock is available.
- findOne(): Retrieves the updated product details.

Demonstrated stock reservation, insufficient stock handling and stock restoration after payment failure.

### 7. MongoDB Transactions vs Single-Document Atomic Updates

**Single-Document Atomic Updates:**

MongoDB guarantees atomicity for updates to a single document.

For example, when only the stock quantity of one product needs to be decreased, an update using $inc with a stock availability condition is sufficient.

**Multi-Document Transactions:**

Transactions are required when an operation must update multiple documents or collections together.

For example, placing an order may involve:
- Decreasing product stock.
- Creating an order document.
- Inserting order-line documents.

If all these operations must succeed or fail together, a multi-document transaction is required.

Transactions introduce additional processing overhead, so single-document atomic updates are preferable when they are sufficient.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio
- MongoDB 8.0
- MongoDB Shell (mongosh)

## Conclusion

Completed the retail inventory reservation scenario using SQL Server transactions and MongoDB atomic updates.

Demonstrated stock reservation, rollback handling, payment failure recovery, correlated subqueries, CTEs, product ranking and month-on-month sales analysis.
