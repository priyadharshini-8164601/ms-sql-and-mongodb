USE RetailOrderDB;
GO


CREATE TYPE OrderItemType AS TABLE
(
    ProductID INT,
    Quantity INT
);
GO

CREATE OR ALTER PROCEDURE usp_PlaceOrder
    @CustomerID INT,
    @Items OrderItemType READONLY,
    @OrderNumber INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @OrderNumber = NULL;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Validate customer
        IF NOT EXISTS (
            SELECT 1
            FROM Customers
            WHERE CustomerID = @CustomerID
        )
        BEGIN
            THROW 50001, 'Invalid customer ID.', 1;
        END;

        -- Validate order items
        IF NOT EXISTS (SELECT 1 FROM @Items)
        BEGIN
            THROW 50002, 'Order must contain at least one item.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM @Items
            WHERE Quantity <= 0
        )
        BEGIN
            THROW 50003, 'Quantity must be greater than zero.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM @Items i
            LEFT JOIN Products p
                ON i.ProductID = p.ProductID
            WHERE p.ProductID IS NULL
               OR p.IsActive = 0
        )
        BEGIN
            THROW 50004, 'Invalid or inactive product.', 1;
        END;

        -- Validate available stock
        IF EXISTS (
            SELECT 1
            FROM @Items i
            INNER JOIN Products p WITH (UPDLOCK, HOLDLOCK)
                ON i.ProductID = p.ProductID
            GROUP BY p.ProductID, p.StockQuantity
            HAVING SUM(i.Quantity) > p.StockQuantity
        )
        BEGIN
            THROW 50005, 'Insufficient stock available.', 1;
        END;

        -- Insert order
        INSERT INTO Orders
        (CustomerID, OrderDate, OrderStatus, SubTotal)
        VALUES
        (@CustomerID, GETDATE(), 'Pending', 0);

        SET @OrderNumber = SCOPE_IDENTITY();

        -- Insert order items
        INSERT INTO OrderItems
        (OrderID, ProductID, Quantity, UnitPrice)
        SELECT
            @OrderNumber,
            i.ProductID,
            i.Quantity,
            p.SellingPrice
        FROM @Items i
        INNER JOIN Products p
            ON i.ProductID = p.ProductID;

        -- Update product stock
        ;WITH ItemTotals AS
        (
            SELECT ProductID, SUM(Quantity) AS TotalQuantity
            FROM @Items
            GROUP BY ProductID
        )
        UPDATE p
        SET p.StockQuantity =
            p.StockQuantity - i.TotalQuantity
        FROM Products p
        INNER JOIN ItemTotals i
            ON p.ProductID = i.ProductID;

        -- Calculate subtotal
        UPDATE Orders
        SET SubTotal = (
            SELECT SUM(Quantity * UnitPrice)
            FROM OrderItems
            WHERE OrderID = @OrderNumber
        )
        WHERE OrderID = @OrderNumber;

        COMMIT TRANSACTION;

        SELECT
            @OrderNumber AS OrderNumber,
            'Order placed successfully' AS Message;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @OrderNumber = NULL;

        THROW;

    END CATCH
END;
GO


DECLARE @NewItems OrderItemType;

INSERT INTO @NewItems (ProductID, Quantity)
VALUES
(1, 1),
(4, 2);

DECLARE @NewOrderNumber INT;

EXEC usp_PlaceOrder
    @CustomerID = 1,
    @Items = @NewItems,
    @OrderNumber = @NewOrderNumber OUTPUT;

SELECT @NewOrderNumber AS GeneratedOrderNumber;
GO

-- Verify order
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Products;
GO


CREATE OR ALTER FUNCTION fn_OrderTotalWithTax
(
    @OrderID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN

    DECLARE @Total DECIMAL(12,2);

    SELECT
        @Total = SUM(Quantity * UnitPrice) * 1.05
    FROM OrderItems
    WHERE OrderID = @OrderID;

    RETURN ISNULL(@Total, 0);

END;
GO

-- Test scalar function
SELECT
    OrderID,
    dbo.fn_OrderTotalWithTax(OrderID) AS TotalWithTax
FROM Orders;
GO

CREATE OR ALTER FUNCTION fn_CustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        o.OrderStatus,
        o.SubTotal,
        CAST(o.SubTotal * 0.05 AS DECIMAL(12,2))
            AS TaxAmount,
        CAST(o.SubTotal * 1.05 AS DECIMAL(12,2))
            AS TotalWithTax
    FROM Orders o
    WHERE o.CustomerID = @CustomerID
);
GO

-- Test table-valued function
SELECT *
FROM dbo.fn_CustomerOrders(1);
GO

SELECT
    OrderID,
    dbo.fn_OrderTotalWithTax(OrderID) AS ScalarFunctionTotal
FROM Orders;
GO

SELECT *
FROM dbo.fn_CustomerOrders(1);
GO

