
# Day 8 – Set 1: Bank Funds Transfer

## Business Scenario

A bank needs to transfer money between two customer accounts. The transfer must be completed safely. If the debit or credit operation fails, the entire transaction should be rolled back so that no money is lost.

## Files Included

| File Name | Description |
|---|---|
| transfer.sql | Implements funds transfer using SQL transactions, error handling, rollback and savepoints. |
| statement_cte.sql | Generates monthly account statements using CTEs and window functions. |
| transaction.js | Implements funds transfer using MongoDB multi-document transactions. |

## Tasks Performed

### 1. Funds Transfer Using SQL Transactions

Created bank account and transaction tables and inserted sample account records.

Implemented a funds transfer using:
- BEGIN TRANSACTION
- COMMIT TRANSACTION
- ROLLBACK TRANSACTION
- TRY...CATCH
- THROW

Validated account status and available balance before performing the transfer.

### 2. Rollback Demonstration

Simulated an error after debiting money from the source account.

Used ROLLBACK to reverse the debit operation.

Compared account balances before and after the failure to verify that the original balances remained unchanged.

### 3. Savepoint Demonstration

Used SAVE TRANSACTION to create a savepoint before posting the transfer fee.

Simulated a fee-posting failure and rolled back only the fee operation.

The main funds transfer was retained and committed successfully.

### 4. Monthly Statement Using CTEs

Created a monthly bank statement report using a Common Table Expression (CTE).

Used the following SQL window functions:

- ROW_NUMBER(): Assigns sequential numbers to transactions.
- PARTITION BY: Separates transactions account-wise.
- LAG(): Retrieves the previous transaction balance.

Also generated an account-wise monthly summary showing total credits, debits and net transaction amounts.

### 5. Isolation Levels

Studied READ COMMITTED and SNAPSHOT isolation levels using two SQL Server sessions.

**READ COMMITTED:**
- Reads only committed data.
- Under locking READ COMMITTED, a query may wait if another session holds conflicting locks.
- When READ_COMMITTED_SNAPSHOT is enabled, reads can use row versions instead.

**SNAPSHOT:**
- Reads data from a consistent snapshot taken at the beginning of the transaction.
- Does not see changes committed by other transactions after its snapshot was established.

#### Two-Session Demonstration

**Before testing SNAPSHOT isolation, enable it once:**

```sql
ALTER DATABASE BankTransferDB
SET ALLOW_SNAPSHOT_ISOLATION ON;
```

**READ COMMITTED – Session 1:**

```sql
USE BankTransferDB;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE dbo.BankAccounts
SET Balance = Balance - 100
WHERE AccountID = 101;

-- Keep this transaction open.
-- Run Session 2 before committing.

COMMIT TRANSACTION;
```

**READ COMMITTED – Session 2:**

```sql
USE BankTransferDB;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT Balance
FROM dbo.BankAccounts
WHERE AccountID = 101;
```

Under locking READ COMMITTED, Session 2 waits until Session 1 commits or rolls back.

**SNAPSHOT – Session 1:**

```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRANSACTION;

SELECT Balance
FROM dbo.BankAccounts
WHERE AccountID = 101;

-- Run Session 2 and commit its update.
-- Then execute the SELECT again.

SELECT Balance
FROM dbo.BankAccounts
WHERE AccountID = 101;

COMMIT TRANSACTION;
```

**SNAPSHOT – Session 2:**

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

UPDATE dbo.BankAccounts
SET Balance = Balance - 200
WHERE AccountID = 101;

COMMIT TRANSACTION;
```

Session 1 continues to see its original snapshot, even after Session 2 commits its update.

Note: Run the SNAPSHOT example after the READ COMMITTED example has completed. The two-session examples are separate demonstrations.

### 6. MongoDB Multi-Document Transactions

Implemented the same funds transfer using MongoDB 8.0 and the Node.js MongoDB driver.

Used:
- MongoClient
- Client Session
- withTransaction()
- updateOne()
- $inc
- insertOne()

The transaction updates both account documents and inserts the debit and credit records.

If any operation fails, the transaction is aborted and all changes are rolled back.

**Transaction Cost:**

Multi-document transactions provide atomicity across multiple documents, but they introduce additional overhead.

- Higher processing and coordination overhead.
- Additional memory and storage requirements for transaction processing.
- Increased latency compared with individual document updates.
- Possible transaction retries during write conflicts.

Transactions should therefore be kept short and used when multiple document operations must succeed or fail together.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio (SSMS)
- MongoDB 8.0
- MongoDB Node.js Driver
- JavaScript

## Conclusion

Completed the bank funds transfer scenario using SQL Server transactions and MongoDB multi-document transactions.

Demonstrated successful transfers, rollback handling, savepoints, CTEs, window functions and transaction isolation levels.
