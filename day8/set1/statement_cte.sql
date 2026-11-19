USE BankTransferDB;
GO

-- Select the month for the statement.
DECLARE @ReportYear INT = 2026;
DECLARE @ReportMonth INT = 11;


;WITH TransactionHistory AS
(
    SELECT
        TransactionID,
        AccountID,
        TransactionDate,
        TransactionType,
        Amount,
        BalanceAfter,
        Description,

        -- Assign a sequence number to each transaction.
        ROW_NUMBER() OVER
        (
            PARTITION BY AccountID
            ORDER BY TransactionDate, TransactionID
        ) AS RowNumber,

        -- Retrieve the previous transaction balance.
        LAG(BalanceAfter, 1, 0) OVER
        (
            PARTITION BY AccountID
            ORDER BY TransactionDate, TransactionID
        ) AS PreviousBalance

    FROM dbo.AccountTransactions
)

SELECT
    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,
    PreviousBalance,
    BalanceAfter,
    Description,
    RowNumber

FROM TransactionHistory

WHERE YEAR(TransactionDate) = @ReportYear
  AND MONTH(TransactionDate) = @ReportMonth

ORDER BY AccountID, TransactionDate, TransactionID;
GO


DECLARE @Year INT = 2026;
DECLARE @Month INT = 11;

;WITH MonthlySummary AS
(
    SELECT
        AccountID,

        COUNT(*) AS TotalTransactions,

        SUM(CASE
            WHEN TransactionType = 'Credit'
            THEN Amount ELSE 0
        END) AS TotalCredits,

        SUM(CASE
            WHEN TransactionType = 'Debit'
            THEN Amount ELSE 0
        END) AS TotalDebits

    FROM dbo.AccountTransactions

    WHERE YEAR(TransactionDate) = @Year
      AND MONTH(TransactionDate) = @Month

    GROUP BY AccountID
)

SELECT
    AccountID,
    TotalTransactions,
    TotalCredits,
    TotalDebits,
    TotalCredits - TotalDebits AS NetTransactionAmount

FROM MonthlySummary
ORDER BY AccountID;
GO


SELECT
    AccountID,
    TransactionID,
    TransactionType,
    Amount,

    ROW_NUMBER() OVER
    (
        PARTITION BY AccountID
        ORDER BY TransactionDate, TransactionID
    ) AS TransactionNumber

FROM dbo.AccountTransactions

ORDER BY AccountID, TransactionNumber;
GO
