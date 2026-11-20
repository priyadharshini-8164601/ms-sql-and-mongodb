
USE InsuranceDB;
GO

CREATE OR ALTER FUNCTION fn_PremiumWithNoClaimDiscount
(
    @Premium DECIMAL(12,2),
    @NoClaimYears INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @DiscountRate DECIMAL(5,2);

    SET @DiscountRate =
        CASE
            WHEN @NoClaimYears >= 5 THEN 0.25
            ELSE @NoClaimYears * 0.05
        END;

    RETURN CAST(
        @Premium * (1 - @DiscountRate)
        AS DECIMAL(12,2)
    );
END;
GO

CREATE OR ALTER PROCEDURE usp_RenewPolicy
    @PolicyID INT,
    @NewPremium DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldPremium DECIMAL(12,2);
    DECLARE @NoClaimYears INT;
    DECLARE @PolicyStatus VARCHAR(20);
    DECLARE @NewExpiryDate DATE;

    SET @NewPremium = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @OldPremium = PremiumAmount,
            @NoClaimYears = NoClaimYears,
            @PolicyStatus = PolicyStatus,
            @NewExpiryDate = PolicyExpiryDate
        FROM Policies WITH (UPDLOCK, HOLDLOCK)
        WHERE PolicyID = @PolicyID;

        IF @OldPremium IS NULL
        BEGIN
            THROW 50001, 'Policy does not exist.', 1;
        END;

        IF @PolicyStatus <> 'Active'
        BEGIN
            THROW 50002, 'Only active policies can be renewed.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM Claims
            WHERE PolicyID = @PolicyID
              AND ClaimStatus = 'Pending'
        )
        BEGIN
            THROW 50003, 'Policy has a pending claim.', 1;
        END;

        SET @NewPremium =
            dbo.fn_PremiumWithNoClaimDiscount(
                @OldPremium,
                @NoClaimYears
            );

        UPDATE Policies
        SET PremiumAmount = @NewPremium,
            PolicyStartDate = PolicyExpiryDate,
            PolicyExpiryDate = DATEADD(YEAR, 1, PolicyExpiryDate),
            PremiumDueDate = DATEADD(YEAR, 1, PolicyExpiryDate)
        WHERE PolicyID = @PolicyID;

        INSERT INTO RenewalAudit
        (
            PolicyID,
            RenewalDate,
            OldPremium,
            NewPremium,
            AuditMessage
        )
        VALUES
        (
            @PolicyID,
            GETDATE(),
            @OldPremium,
            @NewPremium,
            'Policy renewed successfully.'
        );

        COMMIT TRANSACTION;

        SELECT
            @PolicyID AS PolicyID,
            @NewPremium AS RenewedPremium,
            'Policy renewed successfully' AS Message;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @NewPremium = NULL;

        THROW;

    END CATCH
END;
GO

DECLARE @RenewedPremium DECIMAL(12,2);

EXEC usp_RenewPolicy
    @PolicyID = 1001,
    @NewPremium = @RenewedPremium OUTPUT;

SELECT @RenewedPremium AS NewPremium;
GO

SELECT * FROM RenewalAudit;
GO

CREATE OR ALTER FUNCTION fn_AgentRenewalQuotes
(
    @AgentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.PolicyID,
        p.CustomerID,
        c.CustomerName,
        p.AgentID,
        a.AgentName,
        p.PolicyType,
        p.PremiumAmount AS OriginalPremium,
        p.NoClaimYears,
        dbo.fn_PremiumWithNoClaimDiscount(
            p.PremiumAmount,
            p.NoClaimYears
        ) AS RenewalQuote,
        p.PolicyExpiryDate
    FROM Policies p
    INNER JOIN Customers c
        ON p.CustomerID = c.CustomerID
    INNER JOIN Agents a
        ON p.AgentID = a.AgentID
    WHERE p.AgentID = @AgentID
      AND p.PolicyStatus = 'Active'
      AND p.PolicyExpiryDate BETWEEN
          CAST(GETDATE() AS DATE)
          AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE))
);
GO

SELECT *
FROM dbo.fn_AgentRenewalQuotes(1);
GO

SELECT
    PolicyID,
    PremiumAmount,
    NoClaimYears,
    dbo.fn_PremiumWithNoClaimDiscount(
        PremiumAmount,
        NoClaimYears
    ) AS DiscountedPremium
FROM Policies;
GO
