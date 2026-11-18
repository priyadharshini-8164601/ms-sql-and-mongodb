
# SQL and MongoDB Assignments

This repository contains my SQL Server and MongoDB assignments completed as part of the training. It includes hands-on exercises covering database creation, SQL queries, data manipulation, functions, joins, subqueries, and MongoDB aggregation pipelines.

## Repository Structure

```text
SQL-MongoDB-Assignments/
│
├── Day5/
│   ├── Set1/
│   ├── Set2/
│   └── Set3/
│
├── Day6/
│   ├── Set1/
│   ├── Set2/
│   └── Set3/
│
└── Day7/
    ├── Set1_Logistics_Shipment_Analysis/
    ├── Set2_Bank_Loan_Portfolio/
    └── Set3_Retail_Returns_and_Refunds/
```

## Contents

### Day 5

Contains three sets of assignments covering SQL Server and MongoDB fundamentals, database operations, table creation, data insertion, and querying.

### Day 6

Contains three sets of assignments covering SQL functions, aggregate functions, grouping, joins, and MongoDB aggregation.

### Day 7 – Joins, Subqueries and Lookups

Contains three business-oriented assignments using SQL Server 2025 and MongoDB 8.0.

**Set 1 – Logistics Shipment Analysis**
- INNER, LEFT, FULL OUTER and SELF JOINs.
- Subqueries using IN, EXISTS, ANY and ALL.
- Rewriting subqueries using JOINs.
- Nested subqueries to find the second-highest shipping cost per hub.
- MongoDB $lookup pipelines for shipments, customers, delivery events, and carrier delay statistics.

**Set 2 – Bank Loan Portfolio**
- Joins involving loans, customers, branches, repayments, and guarantors.
- Correlated and uncorrelated subqueries.
- EXISTS and NOT EXISTS for repayment analysis.
- Nested subqueries to compare branch maximum loan amounts.
- MongoDB $lookup pipelines for loan details, customer information, and repayment records.

**Set 3 – Retail Returns and Refunds**
- Joins involving products, customers, stores, sales, returns, and refunds.
- IN and NOT IN subqueries with NULL handling.
- NOT EXISTS to avoid the NULL pitfall.
- ANY and ALL comparisons between stores in the same region.
- Nested subqueries for return counts and refund analysis.
- MongoDB $lookup pipelines combining returns, refunds, products, customers, and feedback.

Each Day 7 set contains:
- `advanced_reports.sql` – SQL Server queries and solutions.
- `reports.js` – MongoDB sample data and aggregation pipelines.
- `README.md` – Assignment documentation and explanations.

## Tools Used

- Microsoft SQL Server 2025
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Compass
- MongoDB Shell (mongosh)

## Learning Outcomes

Through these assignments, I practiced:

- Creating and managing relational databases.
- Writing SQL queries to retrieve and manipulate data.
- Applying SQL built-in and aggregate functions.
- Using GROUP BY, HAVING, and ORDER BY.
- Combining multiple tables using different JOIN types.
- Writing correlated, uncorrelated, and nested subqueries.
- Understanding EXISTS, NOT EXISTS, IN, NOT IN, ANY, and ALL.
- Handling NULL values in SQL queries.
- Combining MongoDB collections using $lookup.
- Building MongoDB aggregation pipelines for business analysis.

## Execution

1. Open the respective `advanced_reports.sql` file in SQL Server Management Studio.
2. Execute the SQL script to create the database, tables, insert sample records, and run the queries.
3. Open the corresponding `reports.js` file in MongoDB Compass or mongosh.
4. Execute the MongoDB script to create collections, insert sample documents, and run aggregation pipelines.
5. Verify the query results and aggregation outputs.

---
**Repository:** SQL and MongoDB Assignments  
**Purpose:** Hands-on database training and practical assignment solutions.
