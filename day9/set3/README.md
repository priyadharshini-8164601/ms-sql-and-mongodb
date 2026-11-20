# Day 9 – Set 3: Telecom Low-Balance Follow-up

## Overview

This assignment implements prepaid subscriber management and low-balance notification processing using SQL Server 2025 and MongoDB 8.0.

The main objective is to manage prepaid recharges, track subscriber balances, calculate remaining validity, and generate notifications for subscribers whose balance falls below a specified threshold.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Shell (mongosh)
- SQL and JavaScript

## Project Structure

```text
Set3_Telecom_Low_Balance_Followup/
│
├── views.sql
├── procedures.sql
├── cursor.sql
├── mongo_view.js
└── README.md
```

## Database Design

Database name: `TelecomDB`

The SQL Server database contains the following tables:

| Table | Description |
|---|---|
| Plans | Stores prepaid and postpaid recharge plans. |
| Subscribers | Stores subscriber details, account type, balance, and validity. |
| RechargeHistory | Maintains subscriber recharge transactions. |
| NotificationLog | Stores low-balance notifications and their read status. |

## Tasks Implemented

### 1. Views – views.sql

Created three SQL Server views.

**vw_prepaid_subscribers**

- Displays prepaid subscriber details.
- Includes subscriber name, phone number, plan, balance, and validity.
- Excludes postpaid subscribers.

**vw_recharge_summary**

- Displays recharge statistics for subscribers.
- Calculates total recharge count and total recharge amount.
- Shows the date of the latest successful recharge.
- Uses LEFT JOIN to include subscribers who have no recharge history.

**vw_prepaid_only**

- Displays only prepaid subscribers.
- Demonstrates row-level filtering through a view.
- Uses WITH CHECK OPTION to prevent updates that violate the view condition.

### 2. Stored Procedures and Functions – procedures.sql

**usp_Recharge**

Created a stored procedure to process prepaid subscriber recharges.

The procedure:

1. Accepts subscriber ID, plan ID, and recharge amount.
2. Validates the recharge amount.
3. Checks whether the subscriber exists and is active.
4. Validates the selected prepaid plan.
5. Checks whether the recharge amount matches the plan amount.
6. Updates the subscriber balance and validity.
7. Inserts the recharge transaction into RechargeHistory.
8. Returns the updated balance through an OUTPUT parameter.

Transaction handling is implemented using TRY...CATCH, COMMIT, and ROLLBACK.

**fn_ValidityDaysLeft**

- Implements a scalar-valued function.
- Accepts a subscriber ID.
- Calculates the remaining validity days using the subscriber's validity end date.

**fn_SubscriberLastFiveRecharges**

- Implements an inline table-valued function.
- Accepts a subscriber ID.
- Returns the five latest successful recharge transactions.
- Displays recharge amount, date, plan ID, and validity end date.

### 3. Cursors and Set-Based Processing – cursor.sql

**Cursor-based processing**

Created `usp_CursorLowBalanceNotifications` to identify prepaid subscribers whose balance is below 50 currency units.

The cursor:

- Retrieves eligible prepaid subscribers.
- Processes each subscriber individually.
- Inserts a low-balance notification into NotificationLog.
- Avoids duplicate unread notifications.

**Set-based processing**

Implemented the same requirement using a single `INSERT INTO ... SELECT` statement.

This approach inserts notifications for all eligible subscribers together.

**Execution-time comparison**

Measured the execution time of both approaches using SYSDATETIME() and DATEDIFF().

The comparison demonstrates the difference between row-by-row cursor processing and set-based operations.

### 4. MongoDB Views – mongo_view.js

Created a MongoDB view named `unread_notification_counts` using `db.createView()`.

The view uses an aggregation pipeline with:

- `$match` to filter unread notifications.
- `$group` to group notifications by subscriber ID.
- `$sum` to calculate unread notification counts.
- `$project` to format the output fields.
- `$sort` to arrange results by subscriber ID.

The view displays the unread notification count for each subscriber.

## SQL Server View vs MongoDB View

| SQL Server View | MongoDB View |
|---|---|
| Created using CREATE VIEW. | Created using db.createView(). |
| Based on SQL queries. | Based on aggregation pipelines. |
| Uses relational tables. | Uses collections. |
| Can support updates in certain conditions. | Read-only view. |
| Uses SELECT, JOIN, and GROUP BY. | Uses stages such as $match, $group, and $project. |

## Execution Order

Execute the files in the following order:

1. `views.sql` – Creates the database, tables, sample records, and views.
2. `procedures.sql` – Creates the recharge procedure and functions.
3. `cursor.sql` – Executes cursor-based and set-based notification processing.
4. `mongo_view.js` – Creates and queries the MongoDB view.

## Key Concepts Practiced

- SQL Server views
- Row-level filtering through views
- WITH CHECK OPTION
- Stored procedures
- Input and OUTPUT parameters
- Scalar-valued functions
- Inline table-valued functions
- Transactions
- TRY...CATCH error handling
- Recharge processing
- Balance and validity management
- Cursors
- Set-based INSERT operations
- Execution-time comparison
- MongoDB aggregation pipelines
- MongoDB views

## Conclusion

Successfully implemented telecom prepaid recharge and low-balance notification operations using SQL Server 2025 and MongoDB 8.0. The assignment demonstrates how views, stored procedures, functions, cursors, and set-based operations help manage subscriber information, process recharges, and automate notifications.