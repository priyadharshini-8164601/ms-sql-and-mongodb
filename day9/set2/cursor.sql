
USE InsuranceDB;
GO

CREATE OR ALTER PROCEDURE usp_CursorLapsePolicies
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PolicyID INT;
    DECLARE @OldStatus VARCHAR(20);

    DECLARE PolicyCursor CURSOR LOCAL FAST_FORWARD
    FOR
        SELECT PolicyID, PolicyStatus
        FROM Policies
        WHERE PremiumDueDate < CAST(GETDATE() AS DATE)
          AND PolicyStatus = 'Active';

    OPEN PolicyCursor;

    FETCH NEXT FROM PolicyCursor
    INTO @PolicyID, @OldStatus;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        UPDATE Policies
        SET PolicyStatus = 'Lapsed'
        WHERE PolicyID = @PolicyID
          AND PolicyStatus = 'Active';

        IF @@ROWCOUNT > 0
        BEGIN
            INSERT INTO PolicyStatusLog
            (
                PolicyID,
                OldStatus,
                NewStatus,
                ChangeDate,
                ChangeReason
            )
            VALUES
            (
                @PolicyID,
                @OldStatus,
                'Lapsed',
                GETDATE(),
                'Premium payment due date has passed.'
            );
        END;

        FETCH NEXT FROM PolicyCursor
        INTO @PolicyID, @OldStatus;

    END;

    CLOSE PolicyCursor;
    DEALLOCATE PolicyCursor;
END;
GO

EXEC usp_CursorLapsePolicies;
GO

SELECT * FROM Policies;
SELECT * FROM PolicyStatusLog;
GO

DECLARE @ChangedPolicies TABLE
(
    PolicyID INT,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20)
);

UPDATE Policies
SET PolicyStatus = 'Lapsed'
OUTPUT
    deleted.PolicyID,
    deleted.PolicyStatus,
    inserted.PolicyStatus
INTO @ChangedPolicies
WHERE PremiumDueDate < CAST(GETDATE() AS DATE)
  AND PolicyStatus = 'Active';

INSERT INTO PolicyStatusLog
(
    PolicyID,
    OldStatus,
    NewStatus,
    ChangeDate,
    ChangeReason
)
SELECT
    PolicyID,
    OldStatus,
    NewStatus,
    GETDATE(),
    'Premium payment due date has passed.'
FROM @ChangedPolicies;
GO

SELECT
    p.PolicyID,
    p.PolicyStatus,
    p.PremiumDueDate,
    l.OldStatus,
    l.NewStatus,
    l.ChangeDate,
    l.ChangeReason
FROM Policies p
INNER JOIN PolicyStatusLog l
    ON p.PolicyID = l.PolicyID
ORDER BY l.ChangeDate DESC;
GO

DECLARE @StartTime DATETIME2;
DECLARE @EndTime DATETIME2;

DELETE FROM PolicyStatusLog
WHERE ChangeReason = 'Premium payment due date has passed.';

UPDATE Policies
SET PolicyStatus = 'Active'
WHERE PremiumDueDate < CAST(GETDATE() AS DATE)
  AND PolicyStatus = 'Lapsed';

SET @StartTime = SYSDATETIME();

EXEC usp_CursorLapsePolicies;

SET @EndTime = SYSDATETIME();

SELECT
    'Cursor Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;

DELETE FROM PolicyStatusLog
WHERE ChangeReason = 'Premium payment due date has passed.';

UPDATE Policies
SET PolicyStatus = 'Active'
WHERE PremiumDueDate < CAST(GETDATE() AS DATE)
  AND PolicyStatus = 'Lapsed';

SET @StartTime = SYSDATETIME();

DECLARE @TimingChanges TABLE
(
    PolicyID INT,
    OldStatus VARCHAR(20),
    NewStatus VARCHAR(20)
);

UPDATE Policies
SET PolicyStatus = 'Lapsed'
OUTPUT
    deleted.PolicyID,
    deleted.PolicyStatus,
    inserted.PolicyStatus
INTO @TimingChanges
WHERE PremiumDueDate < CAST(GETDATE() AS DATE)
  AND PolicyStatus = 'Active';

INSERT INTO PolicyStatusLog
(
    PolicyID,
    OldStatus,
    NewStatus,
    ChangeDate,
    ChangeReason
)
SELECT
    PolicyID,
    OldStatus,
    NewStatus,
    GETDATE(),
    'Premium payment due date has passed.'
FROM @TimingChanges;

SET @EndTime = SYSDATETIME();

SELECT
    'Set-Based Approach' AS Method,
    DATEDIFF(MICROSECOND, @StartTime, @EndTime)
        AS ExecutionTimeMicroseconds;
GO

SELECT * FROM PolicyStatusLog;
GO
