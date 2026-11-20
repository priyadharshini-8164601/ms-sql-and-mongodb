
USE TelecomDB;
GO

CREATE OR ALTER PROCEDURE usp_Recharge
    @SubscriberID INT,
    @PlanID INT,
    @RechargeAmount DECIMAL(10,2),
    @NewBalance DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentBalance DECIMAL(10,2);
    DECLARE @PlanAmount DECIMAL(10,2);
    DECLARE @ValidityDays INT;
    DECLARE @SubscriberType VARCHAR(20);
    DECLARE @SubscriberStatus VARCHAR(20);
    DECLARE @PlanType VARCHAR(20);
    DECLARE @NewValidityEndDate DATE;

    SET @NewBalance = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @RechargeAmount <= 0
        BEGIN
            THROW 50001, 'Recharge amount must be greater than zero.', 1;
        END;

        SELECT
            @CurrentBalance = Balance,
            @SubscriberType = SubscriberType,
            @SubscriberStatus = SubscriberStatus
        FROM Subscribers WITH (UPDLOCK, HOLDLOCK)
        WHERE SubscriberID = @SubscriberID;

        IF @CurrentBalance IS NULL
        BEGIN
            THROW 50002, 'Subscriber does not exist.', 1;
        END;

        IF @SubscriberType <> 'Prepaid'
        BEGIN
            THROW 50003, 'Recharge is available only for prepaid subscribers.', 1;
        END;

        IF @SubscriberStatus <> 'Active'
        BEGIN
            THROW 50004, 'Subscriber account is not active.', 1;
        END;

        SELECT
            @PlanAmount = PlanAmount,
            @ValidityDays = ValidityDays,
            @PlanType = PlanType
        FROM Plans
        WHERE PlanID = @PlanID
          AND IsActive = 1;

        IF @PlanAmount IS NULL
        BEGIN
            THROW 50005, 'Invalid or inactive recharge plan.', 1;
        END;

        IF @PlanType <> 'Prepaid'
        BEGIN
            THROW 50006, 'Only prepaid plans are allowed.', 1;
        END;

        IF @RechargeAmount <> @PlanAmount
        BEGIN
            THROW 50007, 'Recharge amount does not match the selected plan.', 1;
        END;

        SET @NewBalance = @CurrentBalance + @RechargeAmount;

        SET @NewValidityEndDate =
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM Subscribers
                    WHERE SubscriberID = @SubscriberID
                      AND ValidityEndDate >= CAST(GETDATE() AS DATE)
                )
                THEN DATEADD(DAY, @ValidityDays,
                    (SELECT ValidityEndDate
                     FROM Subscribers
                     WHERE SubscriberID = @SubscriberID))
                ELSE DATEADD(DAY, @ValidityDays, CAST(GETDATE() AS DATE))
            END;

        UPDATE Subscribers
        SET Balance = @NewBalance,
            PlanID = @PlanID,
            ValidityEndDate = @NewValidityEndDate
        WHERE SubscriberID = @SubscriberID;

        INSERT INTO RechargeHistory
        (
            SubscriberID,
            PlanID,
            RechargeAmount,
            RechargeDate,
            ValidityEndDate,
            RechargeStatus
        )
        VALUES
        (
            @SubscriberID,
            @PlanID,
            @RechargeAmount,
            GETDATE(),
            @NewValidityEndDate,
            'Success'
        );

        COMMIT TRANSACTION;

        SELECT
            @SubscriberID AS SubscriberID,
            @NewBalance AS NewBalance,
            @NewValidityEndDate AS ValidityEndDate,
            'Recharge successful' AS Message;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @NewBalance = NULL;

        THROW;

    END CATCH
END;
GO

DECLARE @BalanceAfterRecharge DECIMAL(10,2);

EXEC usp_Recharge
    @SubscriberID = 1001,
    @PlanID = 1,
    @RechargeAmount = 199,
    @NewBalance = @BalanceAfterRecharge OUTPUT;

SELECT @BalanceAfterRecharge AS NewBalance;
GO

SELECT * FROM Subscribers;
SELECT * FROM RechargeHistory;
GO

CREATE OR ALTER FUNCTION fn_ValidityDaysLeft
(
    @SubscriberID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @DaysLeft INT;

    SELECT
        @DaysLeft = DATEDIFF(
            DAY,
            CAST(GETDATE() AS DATE),
            ValidityEndDate
        )
    FROM Subscribers
    WHERE SubscriberID = @SubscriberID;

    RETURN @DaysLeft;
END;
GO

SELECT
    SubscriberID,
    SubscriberName,
    ValidityEndDate,
    dbo.fn_ValidityDaysLeft(SubscriberID) AS ValidityDaysLeft
FROM Subscribers;
GO

CREATE OR ALTER FUNCTION fn_SubscriberLastFiveRecharges
(
    @SubscriberID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (5)
        RechargeID,
        SubscriberID,
        PlanID,
        RechargeAmount,
        RechargeDate,
        ValidityEndDate,
        RechargeStatus
    FROM RechargeHistory
    WHERE SubscriberID = @SubscriberID
      AND RechargeStatus = 'Success'
    ORDER BY RechargeDate DESC, RechargeID DESC
);
GO

SELECT *
FROM dbo.fn_SubscriberLastFiveRecharges(1001);
GO
