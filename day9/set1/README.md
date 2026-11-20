# Day 9 – Set 1: Retail Order Fulfilment

## Overview

This assignment implements database-level business logic for a Retail Order Fulfilment System using SQL Server 2025 and MongoDB 8.0.

The main objective is to centralize order processing, stock validation, calculations, and follow-up operations at the database level so that applications can use consistent business rules.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Shell (mongosh)
- SQL and JavaScript

## Project Structure

```text
Set1_Retail_Order_Fulfilment/
│
├── views.sql
├── procedures.sql
├── cursor.sql
├── mongo_view.js
└── README.md
```

## Database Design

Database name: `RetailOrderDB`

The SQL Server database contains the following tables:

| Table | Description |
|---|---|
| Customers | Stores customer information. |
| Suppliers | Stores supplier details. |
| Products | Stores product prices, supplier references, and stock quantities. |
| Orders | Stores customer order information and order status. |
| OrderItems | Stores the products and quantities included in each order. |
| OrderFollowUps | Stores follow-up records for delayed orders. |

## Tasks Implemented

### 1. Views – views.sql

Created three SQL Server views.

**vw_order_summary**

- Displays order details along with customer and product information.
- Shows order ID, customer name, product name, quantity, selling price, and line total.
- Hides sensitive product information such as cost price and supplier details.

**vw_low_stock**

- Identifies products whose stock quantity is less than or equal to their reorder level.
- Helps the fulfilment team identify products that require restocking.

**vw_available_products**

- Displays only active products.
- Demonstrates an updatable view.
- Uses `WITH CHECK OPTION` to prevent updates that violate the view's filtering condition.

### 2. Stored Procedures and Functions – procedures.sql

**usp_PlaceOrder**

Created a stored procedure to process customer orders.

The procedure:

1. Accepts a customer ID and multiple order items.
2. Accepts product IDs and quantities through a table-valued parameter.
3. Validates the customer and product details.
4. Checks whether sufficient stock is available.
5. Inserts the order and order-item records.
6. Updates product stock quantities.
7. Returns the generated order number through an OUTPUT parameter.

Transaction handling is implemented using `BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`, and `TRY...CATCH` to maintain data consistency.

**fn_OrderTotalWithTax**

- Implements a scalar-valued function.
- Calculates the total order amount including 5% tax.
- Returns a single calculated value for a given order ID.

**fn_CustomerOrders**

- Implements an inline table-valued function.
- Accepts a customer ID.
- Returns the customer's orders with subtotal, tax amount, and total amount including tax.

### 3. Cursors and Set-Based Processing – cursor.sql

**Cursor-based processing**

Created `usp_CursorOrderFollowUps` to identify orders that have remained in Pending status for more than three days.

The cursor:

- Retrieves eligible order IDs.
- Processes each order individually.
- Inserts a follow-up record into `OrderFollowUps`.
- Avoids duplicate follow-up records.

**Set-based processing**

Reimplemented the same requirement using a single `INSERT INTO ... SELECT` statement.

This approach processes all eligible orders together rather than handling each order individually.

**Execution-time comparison**

Measured the execution time of both approaches using `SYSDATETIME()` and `DATEDIFF()`.

The comparison demonstrates why set-based operations are generally preferred for processing multiple records.

### 4. MongoDB Views – mongo_view.js

Created a MongoDB view named `order_status_counts` using `db.createView()`.

The view uses an aggregation pipeline with:

- `$group` to group orders by status.
- `$sum` to calculate the number of orders and total order value.
- `$project` to format the output fields.
- `$sort` to arrange the results by order status.

The view provides a summary of orders grouped into Pending, Processing, Delivered, and Cancelled statuses.

## SQL Server View vs MongoDB View

| SQL Server View | MongoDB View |
|---|---|
| Created using `CREATE VIEW`. | Created using `db.createView()`. |
| Based on SQL queries. | Based on aggregation pipelines. |
| Uses SELECT, JOIN, GROUP BY, etc. | Uses stages such as `$match`, `$group`, and `$project`. |
| Can support updates in certain conditions. | Read-only view. |
| Uses relational tables. | Uses collections. |

## Execution Order

Execute the files in the following order:

1. `views.sql` – Creates the database, tables, sample records, and views.
2. `procedures.sql` – Creates the table type, stored procedure, and functions.
3. `cursor.sql` – Creates and executes cursor-based and set-based processing.
4. `mongo_view.js` – Creates and queries the MongoDB view.

## Key Concepts Practiced

- SQL Server views
- Updatable views
- WITH CHECK OPTION
- Stored procedures
- Input and OUTPUT parameters
- Table-valued parameters
- Scalar-valued functions
- Inline table-valued functions
- Transactions
- TRY...CATCH error handling
- Cursors
- Set-based processing
- Execution-time comparison
- MongoDB aggregation pipelines
- MongoDB views

## Conclusion

Successfully implemented database-level business logic for retail order fulfilment using SQL Server 2025 and MongoDB 8.0. The assignment demonstrates how views, stored procedures, functions, cursors, and set-based operations help centralize business rules, maintain data consistency, and simplify database operations.