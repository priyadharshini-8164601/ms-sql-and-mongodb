USE RetailOrderDB;
GO

CREATE OR ALTER PROCEDURE usp_CursorOrderFollowUps
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @OrderID INT;

    DECLARE OrderCursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT OrderID
        FROM Orders
        WHERE OrderStatus = 'Pending'
          AND OrderDate < DATEADD(DAY, -3, GETDATE())
          AND NOT EXISTS
          (
              SELECT 1
              FROM OrderFollowUps f
              WHERE f.OrderID = Orders.OrderID
          );

    OPEN OrderCursor;

    FETCH NEXT FROM OrderCursor INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        INSERT INTO OrderFollowUps
        (OrderID, FollowUpDate, FollowUpMessage, FollowUpStatus)
        VALUES
        (
            @OrderID,
            GETDATE(),
            'Customer follow-up required for delayed order.',
            'Open'
        );

        FETCH NEXT FROM OrderCursor INTO @OrderID;

    END;

    CLOSE OrderCursor;
    DEALLOCATE OrderCursor;

    PRINT 'Cursor processing completed.';

END;
GO

-- Execute cursor procedure
EXEC usp_CursorOrderFollowUps;
GO

-- View cursor-generated follow-ups
SELECT * FROM OrderFollowUps;
GO

INSERT INTO OrderFollowUps
(
    OrderID,
    FollowUpDate,
    FollowUpMessage,
    FollowUpStatus
)
SELECT
    o.OrderID,
    GETDATE(),
    'Customer follow-up required for delayed order.',
    'Open'
FROM Orders o
WHERE o.OrderStatus = 'Pending'
  AND o.OrderDate < DATEADD(DAY, -3, GETDATE())
  AND NOT EXISTS
  (
      SELECT 1
      FROM OrderFollowUps f
      WHERE f.OrderID = o.OrderID
  );
GO

-- Verify follow-up records
SELECT
    f.FollowUpID,
    f.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.OrderStatus,
    f.FollowUpDate,
    f.FollowUpMessage,
    f.FollowUpStatus
FROM OrderFollowUps f
INNER JOIN Orders o
    ON f.OrderID = o.OrderID;
GO

DECLARE @StartTime DATETIME2;
DECLARE @EndTime DATETIME2;

-- Cursor execution time
SET @StartTime = SYSDATETIME();

EXEC usp_CursorOrderFollowUps;

SET @EndTime = SYSDATETIME();

SELECT
    'Cursor Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;

-- Set-based execution time
SET @StartTime = SYSDATETIME();

INSERT INTO OrderFollowUps
(
    OrderID,
    FollowUpDate,
    FollowUpMessage,
    FollowUpStatus
)
SELECT
    o.OrderID,
    GETDATE(),
    'Customer follow-up required for delayed order.',
    'Open'
FROM Orders o
WHERE o.OrderStatus = 'Pending'
  AND o.OrderDate < DATEADD(DAY, -3, GETDATE())
  AND NOT EXISTS
  (
      SELECT 1
      FROM OrderFollowUps f
      WHERE f.OrderID = o.OrderID
  );

SET @EndTime = SYSDATETIME();

SELECT
    'Set-Based Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;
GO

