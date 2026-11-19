-- Create Database
IF DB_ID('BankTransferDB') IS NULL
    CREATE DATABASE BankTransferDB;
GO

USE BankTransferDB;
GO


IF OBJECT_ID('dbo.AccountTransactions', 'U') IS NOT NULL
    DROP TABLE dbo.AccountTransactions;

IF OBJECT_ID('dbo.BankAccounts', 'U') IS NOT NULL
    DROP TABLE dbo.BankAccounts;
GO

CREATE TABLE dbo.BankAccounts
(
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(100) NOT NULL,
    Balance DECIMAL(12,2) NOT NULL,
    AccountStatus VARCHAR(20) NOT NULL
        CHECK (AccountStatus IN ('Active', 'Inactive'))
);

CREATE TABLE dbo.AccountTransactions
(
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionDate DATETIME2 DEFAULT SYSDATETIME(),
    TransactionType VARCHAR(30),
    Amount DECIMAL(12,2),
    BalanceAfter DECIMAL(12,2),
    Description VARCHAR(200),

    FOREIGN KEY (AccountID)
        REFERENCES dbo.BankAccounts(AccountID)
);
GO


INSERT INTO dbo.BankAccounts
(AccountID, AccountHolder, Balance, AccountStatus)
VALUES
(101, 'Arun', 10000.00, 'Active'),
(102, 'Priya', 5000.00, 'Active'),
(103, 'Kumar', 2000.00, 'Inactive');

SELECT * FROM dbo.BankAccounts;
GO


DECLARE @FromAccount INT = 101;
DECLARE @ToAccount INT = 102;
DECLARE @TransferAmount DECIMAL(12,2) = 2000.00;

BEGIN TRY

    BEGIN TRANSACTION;

    -- Validate that both accounts exist and are active.
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @FromAccount
          AND AccountStatus = 'Active'
    )
        THROW 50001, 'Source account is invalid or inactive.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.BankAccounts WITH (UPDLOCK, HOLDLOCK)
        WHERE AccountID = @ToAccount
          AND AccountStatus = 'Active'
    )
        THROW 50002, 'Destination account is invalid or inactive.', 1;

    IF @FromAccount = @ToAccount
        THROW 50003, 'Source and destination accounts must differ.', 1;

    IF @TransferAmount <= 0
        THROW 50004, 'Transfer amount must be positive.', 1;

    -- Validate sufficient balance and debit.
    UPDATE dbo.BankAccounts
    SET Balance = Balance - @TransferAmount
    WHERE AccountID = @FromAccount
      AND Balance >= @TransferAmount
      AND AccountStatus = 'Active';

    IF @@ROWCOUNT = 0
        THROW 50005, 'Insufficient balance or invalid source account.', 1;

    -- Credit destination account.
    UPDATE dbo.BankAccounts
    SET Balance = Balance + @TransferAmount
    WHERE AccountID = @ToAccount
      AND AccountStatus = 'Active';

    IF @@ROWCOUNT = 0
        THROW 50006, 'Unable to credit destination account.', 1;

    -- Record debit transaction.
    INSERT INTO dbo.AccountTransactions
    (AccountID, TransactionType, Amount, BalanceAfter, Description)
    SELECT AccountID, 'Debit', @TransferAmount, Balance,
           'Funds transferred to Account 102'
    FROM dbo.BankAccounts
    WHERE AccountID = @FromAccount;

    -- Record credit transaction.
    INSERT INTO dbo.AccountTransactions
    (AccountID, TransactionType, Amount, BalanceAfter, Description)
    SELECT AccountID, 'Credit', @TransferAmount, Balance,
           'Funds received from Account 101'
    FROM dbo.BankAccounts
    WHERE AccountID = @ToAccount;

    COMMIT TRANSACTION;

    PRINT 'Funds transfer completed successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Transfer failed.';
    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;
GO

-- Check successful transfer balances.
SELECT * FROM dbo.BankAccounts;
SELECT * FROM dbo.AccountTransactions;
GO


-- Capture balances before the transaction.
SELECT * INTO #BalanceBefore
FROM dbo.BankAccounts;

BEGIN TRY

    BEGIN TRANSACTION;

    -- Debit Account 101.
    UPDATE dbo.BankAccounts
    SET Balance = Balance - 1000
    WHERE AccountID = 101
      AND Balance >= 1000;

    IF @@ROWCOUNT = 0
        THROW 50007, 'Debit failed.', 1;

    PRINT 'Debit completed inside transaction.';

    -- Deliberate failure after debit.
    THROW 50008, 'Simulated failure after debit.', 1;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Error occurred: ' + ERROR_MESSAGE();
    PRINT 'Transaction rolled back successfully.';

END CATCH;

-- Compare balances before and after rollback.
SELECT
    B.AccountID,
    B.Balance AS BalanceBefore,
    A.Balance AS BalanceAfter,
    CASE
        WHEN B.Balance = A.Balance THEN 'Rollback Successful'
        ELSE 'Balance Changed'
    END AS RollbackStatus
FROM #BalanceBefore B
JOIN dbo.BankAccounts A
    ON B.AccountID = A.AccountID;

DROP TABLE #BalanceBefore;
GO


BEGIN TRY

    BEGIN TRANSACTION;

    -- Transfer money from Account 101 to Account 102.
    UPDATE dbo.BankAccounts
    SET Balance = Balance - 500
    WHERE AccountID = 101
      AND Balance >= 500;

    IF @@ROWCOUNT = 0
        THROW 50009, 'Insufficient balance.', 1;

    UPDATE dbo.BankAccounts
    SET Balance = Balance + 500
    WHERE AccountID = 102
      AND AccountStatus = 'Active';

    IF @@ROWCOUNT = 1
    BEGIN
        INSERT INTO dbo.AccountTransactions
        (AccountID, TransactionType, Amount, BalanceAfter, Description)
        SELECT AccountID, 'Debit', 500, Balance,
               'Savepoint transfer debit'
        FROM dbo.BankAccounts
        WHERE AccountID = 101;

        INSERT INTO dbo.AccountTransactions
        (AccountID, TransactionType, Amount, BalanceAfter, Description)
        SELECT AccountID, 'Credit', 500, Balance,
               'Savepoint transfer credit'
        FROM dbo.BankAccounts
        WHERE AccountID = 102;
    END
    ELSE
        THROW 50010, 'Destination account update failed.', 1;

    -- Create savepoint after successful transfer.
    SAVE TRANSACTION FeeSavepoint;

    BEGIN TRY

        -- Simulate fee posting.
        INSERT INTO dbo.AccountTransactions
        (AccountID, TransactionType, Amount, BalanceAfter, Description)
        VALUES
        (101, 'Fee', 50, NULL, 'Transfer processing fee');

        -- Simulate a fee-posting failure.
        THROW 50011, 'Simulated fee posting failure.', 1;

    END TRY

    BEGIN CATCH

        -- Roll back only the fee operation.
        IF XACT_STATE() = 1
            ROLLBACK TRANSACTION FeeSavepoint;

        PRINT 'Fee posting failed.';
        PRINT 'Only fee operation was rolled back.';
        PRINT 'Main transfer is retained.';

    END CATCH;

    COMMIT TRANSACTION;

    PRINT 'Transfer committed successfully without fee.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Transfer failed: ' + ERROR_MESSAGE();

    THROW;

END CATCH;
GO


SELECT * FROM dbo.BankAccounts;

SELECT * FROM dbo.AccountTransactions
ORDER BY TransactionID;
GO
