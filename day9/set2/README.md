# Day 9 – Set 2: Insurance Premium Processing

## Overview

This assignment implements insurance policy renewal and premium processing using SQL Server 2025 and MongoDB 8.0.

The main objective is to manage policy renewals, calculate premiums with no-claim discounts, identify lapsed policies, and maintain audit records.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Shell (mongosh)
- SQL and JavaScript

## Project Structure

```text
Set2_Insurance_Premium_Processing/
│
├── views.sql
├── procedures.sql
├── cursor.sql
├── mongo_view.js
└── README.md
```

## Database Design

Database name: `InsuranceDB`

The SQL Server database contains the following tables:

| Table | Description |
|---|---|
| Customers | Stores customer details and personal information. |
| Agents | Stores insurance agent details. |
| Policies | Stores policy information, premium amounts, and renewal dates. |
| Claims | Stores customer insurance claims and their status. |
| RenewalAudit | Maintains records of policy renewals and premium changes. |
| PolicyStatusLog | Stores policy status changes and their reasons. |

## Tasks Implemented

### 1. Views – views.sql

Created the `vw_policy_due` SQL Server view.

- Displays policies expiring within the next 30 days.
- Includes customer details, agent information, policy type, expiry date, and premium amount.
- Hides sensitive customer information such as National ID and bank account number.
- Displays only active policies.

### 2. Stored Procedures and Functions – procedures.sql

**usp_RenewPolicy**

Created a stored procedure to process insurance policy renewals.

The procedure:

1. Accepts a policy ID.
2. Checks whether the policy exists.
3. Validates that the policy is active.
4. Checks for pending claims.
5. Recalculates the premium using the no-claim discount function.
6. Updates the premium and policy dates.
7. Inserts an audit record into RenewalAudit.
8. Returns the renewed premium through an OUTPUT parameter.

Transaction handling is implemented using TRY...CATCH, COMMIT, and ROLLBACK.

**fn_PremiumWithNoClaimDiscount**

- Implements a scalar-valued function.
- Calculates the premium after applying a no-claim discount.
- Applies a 5% discount for every no-claim year, up to a maximum of 25%.

**fn_AgentRenewalQuotes**

- Implements an inline table-valued function.
- Accepts an agent ID.
- Returns renewal quotes for the agent's active policies expiring within 30 days.
- Displays the original premium and discounted renewal premium.

### 3. Cursors and Set-Based Processing – cursor.sql

**Cursor-based processing**

Created `usp_CursorLapsePolicies` to identify policies with overdue premiums.

The cursor:

- Retrieves active policies whose premium due date has passed.
- Processes policies individually.
- Changes the policy status to Lapsed.
- Inserts the old and new status into PolicyStatusLog.

**Set-based processing**

Implemented the same requirement using a single UPDATE statement with the OUTPUT clause.

The updated policy information is captured and inserted into PolicyStatusLog.

**Execution-time comparison**

Measured the execution time of cursor-based and set-based processing using SYSDATETIME() and DATEDIFF().

### 4. MongoDB Views – mongo_view.js

Created a MongoDB view named `unresolved_complaints` using `db.createView()`.

The view uses an aggregation pipeline with:

- `$match` to filter unresolved complaints.
- `$project` to select the required customer communication fields.

The view displays only customer communications that are complaints with an Unresolved status.

## SQL Server View vs MongoDB View

| SQL Server View | MongoDB View |
|---|---|
| Created using CREATE VIEW. | Created using db.createView(). |
| Based on SQL queries. | Based on aggregation pipelines. |
| Uses relational tables. | Uses collections. |
| Can support updates in certain conditions. | Read-only view. |
| Uses SELECT, JOIN, and WHERE. | Uses stages such as $match and $project. |

## Execution Order

Execute the files in the following order:

1. `views.sql` – Creates the database, tables, sample records, and policy view.
2. `procedures.sql` – Creates the stored procedure and functions.
3. `cursor.sql` – Executes cursor-based and set-based policy lapse processing.
4. `mongo_view.js` – Creates and queries the MongoDB view.

## Key Concepts Practiced

- SQL Server views
- Hiding sensitive columns
- Stored procedures
- Input and OUTPUT parameters
- Scalar-valued functions
- Inline table-valued functions
- No-claim premium discounts
- Transactions
- TRY...CATCH error handling
- Audit logging
- Cursors
- Set-based UPDATE operations
- OUTPUT clause
- Execution-time comparison
- MongoDB aggregation pipelines
- MongoDB views

## Conclusion

Successfully implemented insurance premium processing and policy renewal operations using SQL Server 2025 and MongoDB 8.0. The assignment demonstrates how database views, stored procedures, functions, cursors, and set-based operations help automate insurance business processes and maintain consistent records.