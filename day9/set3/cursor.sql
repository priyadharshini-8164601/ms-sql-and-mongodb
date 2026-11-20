
USE TelecomDB;
GO

CREATE OR ALTER PROCEDURE usp_CursorLowBalanceNotifications
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SubscriberID INT;
    DECLARE @SubscriberName VARCHAR(100);
    DECLARE @Balance DECIMAL(10,2);

    DECLARE SubscriberCursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT
            SubscriberID,
            SubscriberName,
            Balance
        FROM Subscribers
        WHERE SubscriberType = 'Prepaid'
          AND SubscriberStatus = 'Active'
          AND Balance < 50;

    OPEN SubscriberCursor;

    FETCH NEXT FROM SubscriberCursor
    INTO @SubscriberID, @SubscriberName, @Balance;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF NOT EXISTS (
            SELECT 1
            FROM NotificationLog
            WHERE SubscriberID = @SubscriberID
              AND NotificationMessage =
                  'Low balance alert: Please recharge your account.'
              AND IsRead = 0
        )
        BEGIN
            INSERT INTO NotificationLog
            (
                SubscriberID,
                NotificationMessage,
                NotificationDate,
                IsRead
            )
            VALUES
            (
                @SubscriberID,
                'Low balance alert: Please recharge your account.',
                GETDATE(),
                0
            );
        END;

        FETCH NEXT FROM SubscriberCursor
        INTO @SubscriberID, @SubscriberName, @Balance;

    END;

    CLOSE SubscriberCursor;
    DEALLOCATE SubscriberCursor;
END;
GO

EXEC usp_CursorLowBalanceNotifications;
GO

SELECT
    n.NotificationID,
    s.SubscriberName,
    s.PhoneNumber,
    s.Balance,
    n.NotificationMessage,
    n.NotificationDate,
    n.IsRead
FROM NotificationLog n
INNER JOIN Subscribers s
    ON n.SubscriberID = s.SubscriberID;
GO

DELETE FROM NotificationLog
WHERE NotificationMessage =
    'Low balance alert: Please recharge your account.';
GO

INSERT INTO NotificationLog
(
    SubscriberID,
    NotificationMessage,
    NotificationDate,
    IsRead
)
SELECT
    SubscriberID,
    'Low balance alert: Please recharge your account.',
    GETDATE(),
    0
FROM Subscribers s
WHERE SubscriberType = 'Prepaid'
  AND SubscriberStatus = 'Active'
  AND Balance < 50
  AND NOT EXISTS
  (
      SELECT 1
      FROM NotificationLog n
      WHERE n.SubscriberID = s.SubscriberID
        AND n.NotificationMessage =
            'Low balance alert: Please recharge your account.'
        AND n.IsRead = 0
  );
GO

SELECT
    n.NotificationID,
    s.SubscriberName,
    s.PhoneNumber,
    s.Balance,
    n.NotificationMessage,
    n.NotificationDate,
    n.IsRead
FROM NotificationLog n
INNER JOIN Subscribers s
    ON n.SubscriberID = s.SubscriberID;
GO

DECLARE @StartTime DATETIME2;
DECLARE @EndTime DATETIME2;

DELETE FROM NotificationLog
WHERE NotificationMessage =
    'Low balance alert: Please recharge your account.';

SET @StartTime = SYSDATETIME();

EXEC usp_CursorLowBalanceNotifications;

SET @EndTime = SYSDATETIME();

SELECT
    'Cursor Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;

DELETE FROM NotificationLog
WHERE NotificationMessage =
    'Low balance alert: Please recharge your account.';

SET @StartTime = SYSDATETIME();

INSERT INTO NotificationLog
(
    SubscriberID,
    NotificationMessage,
    NotificationDate,
    IsRead
)
SELECT
    s.SubscriberID,
    'Low balance alert: Please recharge your account.',
    GETDATE(),
    0
FROM Subscribers s
WHERE s.SubscriberType = 'Prepaid'
  AND s.SubscriberStatus = 'Active'
  AND s.Balance < 50
  AND NOT EXISTS
  (
      SELECT 1
      FROM NotificationLog n
      WHERE n.SubscriberID = s.SubscriberID
        AND n.NotificationMessage =
            'Low balance alert: Please recharge your account.'
        AND n.IsRead = 0
  );

SET @EndTime = SYSDATETIME();

SELECT
    'Set-Based Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;
GO

SELECT * FROM NotificationLog;
GO
