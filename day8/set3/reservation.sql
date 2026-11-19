
IF DB_ID('RetailInventoryDB') IS NULL
    CREATE DATABASE RetailInventoryDB;
GO

USE RetailInventoryDB;
GO

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL
    DROP TABLE dbo.OrderDetails;

IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Orders;

IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    StockQuantity INT,
    Price DECIMAL(10,2)
);

CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100),
    OrderDate DATETIME2 DEFAULT SYSDATETIME(),
    OrderStatus VARCHAR(30)
);

CREATE TABLE dbo.OrderDetails
(
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),

    FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID),

    CHECK (Quantity > 0)
);
GO

INSERT INTO dbo.Products
VALUES
(1, 'Laptop', 'Electronics', 10, 50000),
(2, 'Mobile', 'Electronics', 20, 20000),
(3, 'Headphones', 'Electronics', 5, 2000),
(4, 'Chair', 'Furniture', 15, 3000),
(5, 'Table', 'Furniture', 8, 7000),
(6, 'Notebook', 'Stationery', 50, 100),
(7, 'Pen', 'Stationery', 100, 20);
GO

SELECT * FROM dbo.Products;
GO

-- Successful order reservation

DECLARE @CustomerName VARCHAR(100) = 'Priya';
DECLARE @ProductID INT = 1;
DECLARE @Quantity INT = 2;
DECLARE @OrderID INT;

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE dbo.Products
    SET StockQuantity = StockQuantity - @Quantity
    WHERE ProductID = @ProductID
      AND StockQuantity >= @Quantity;

    IF @@ROWCOUNT = 0
        THROW 50001, 'Insufficient stock or product not found.', 1;

    INSERT INTO dbo.Orders
    (CustomerName, OrderStatus)
    VALUES
    (@CustomerName, 'Reserved');

    SET @OrderID = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderDetails
    (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        @OrderID,
        ProductID,
        @Quantity,
        Price
    FROM dbo.Products
    WHERE ProductID = @ProductID;

    COMMIT TRANSACTION;

    PRINT 'Order placed and stock reserved successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

END CATCH;
GO

SELECT * FROM dbo.Products;
SELECT * FROM dbo.Orders;
SELECT * FROM dbo.OrderDetails;
GO

-- Demonstrate rollback when stock is insufficient

DECLARE @ProductID2 INT = 3;
DECLARE @Quantity2 INT = 100;
DECLARE @OrderID2 INT;

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE dbo.Products
    SET StockQuantity = StockQuantity - @Quantity2
    WHERE ProductID = @ProductID2
      AND StockQuantity >= @Quantity2;

    IF @@ROWCOUNT = 0
        THROW 50002, 'Insufficient stock. Order cannot be placed.', 1;

    INSERT INTO dbo.Orders
    (CustomerName, OrderStatus)
    VALUES
    ('Arun', 'Reserved');

    SET @OrderID2 = SCOPE_IDENTITY();

    INSERT INTO dbo.OrderDetails
    (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        @OrderID2,
        ProductID,
        @Quantity2,
        Price
    FROM dbo.Products
    WHERE ProductID = @ProductID2;

    COMMIT TRANSACTION;

    PRINT 'Order placed successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Order failed: ' + ERROR_MESSAGE();
    PRINT 'Stock and order records remain unchanged.';

END CATCH;
GO

-- Verify stock after rollback

SELECT
    ProductID,
    ProductName,
    StockQuantity
FROM dbo.Products;

SELECT * FROM dbo.Orders;
SELECT * FROM dbo.OrderDetails;
GO

-- Demonstrate stock release when payment fails

DECLARE @ReleaseOrderID INT = 1;

BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE P
    SET P.StockQuantity = P.StockQuantity + OD.Quantity
    FROM dbo.Products P
    INNER JOIN dbo.OrderDetails OD
        ON P.ProductID = OD.ProductID
    WHERE OD.OrderID = @ReleaseOrderID;

    UPDATE dbo.Orders
    SET OrderStatus = 'Payment Failed'
    WHERE OrderID = @ReleaseOrderID
      AND OrderStatus = 'Reserved';

    IF @@ROWCOUNT = 0
        THROW 50003, 'Order could not be updated.', 1;

    COMMIT TRANSACTION;

    PRINT 'Payment failed. Reserved stock released successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

END CATCH;
GO

SELECT * FROM dbo.Products;
SELECT * FROM dbo.Orders;
GO
