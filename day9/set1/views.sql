CREATE DATABASE RetailOrderDB;
GO

USE RetailOrderDB;
GO


CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15),
    City VARCHAR(50)
);
GO

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY IDENTITY(1,1),
    SupplierName VARCHAR(100) NOT NULL,
    SupplierEmail VARCHAR(100)
);
GO

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    SupplierID INT,
    CostPrice DECIMAL(10,2) NOT NULL,
    SellingPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    ReorderLevel INT NOT NULL DEFAULT 10,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Products_Suppliers
    FOREIGN KEY (SupplierID)
    REFERENCES Suppliers(SupplierID),

    CONSTRAINT CK_Product_CostPrice
    CHECK (CostPrice >= 0),

    CONSTRAINT CK_Product_SellingPrice
    CHECK (SellingPrice >= 0),

    CONSTRAINT CK_Product_Stock
    CHECK (StockQuantity >= 0)
);
GO

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1001,1),
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    OrderStatus VARCHAR(30) NOT NULL DEFAULT 'Pending',
    SubTotal DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT FK_Orders_Customers
    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID),

    CONSTRAINT CK_Order_Status
    CHECK (OrderStatus IN
    ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'))
);
GO

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
    FOREIGN KEY (ProductID)
    REFERENCES Products(ProductID),

    CONSTRAINT CK_OrderItems_Quantity
    CHECK (Quantity > 0)
);
GO

CREATE TABLE OrderFollowUps (
    FollowUpID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    FollowUpDate DATETIME NOT NULL DEFAULT GETDATE(),
    FollowUpMessage VARCHAR(255),
    FollowUpStatus VARCHAR(30) DEFAULT 'Open',

    CONSTRAINT FK_FollowUps_Orders
    FOREIGN KEY (OrderID)
    REFERENCES Orders(OrderID),

    CONSTRAINT UQ_FollowUps_Order
    UNIQUE (OrderID)
);
GO


INSERT INTO Customers
(CustomerName, Email, Phone, City)
VALUES
('Arun Kumar', 'arun@gmail.com', '9876543210', 'Chennai'),
('Priya Sharma', 'priya@gmail.com', '9876543211', 'Coimbatore'),
('Rahul Kumar', 'rahul@gmail.com', '9876543212', 'Madurai'),
('Divya Raj', 'divya@gmail.com', '9876543213', 'Chennai'),
('Karthik S', 'karthik@gmail.com', '9876543214', 'Salem');
GO

INSERT INTO Suppliers
(SupplierName, SupplierEmail)
VALUES
('ABC Electronics', 'abc@gmail.com'),
('Global Traders', 'global@gmail.com'),
('Tech Supplies', 'tech@gmail.com');
GO

INSERT INTO Products
(ProductName, SupplierID, CostPrice, SellingPrice,
 StockQuantity, ReorderLevel)
VALUES
('Laptop', 1, 35000, 45000, 20, 5),
('Keyboard', 2, 500, 800, 4, 10),
('Mouse', 2, 200, 350, 8, 15),
('Monitor', 1, 7000, 9500, 30, 5),
('Headphones', 3, 1000, 1500, 3, 10),
('Printer', 3, 5000, 6500, 15, 5);
GO

INSERT INTO Orders
(CustomerID, OrderDate, OrderStatus, SubTotal)
VALUES
(1, DATEADD(DAY,-5,GETDATE()), 'Pending', 800),
(2, DATEADD(DAY,-2,GETDATE()), 'Pending', 1500),
(3, DATEADD(DAY,-7,GETDATE()), 'Processing', 45000),
(4, DATEADD(DAY,-1,GETDATE()), 'Delivered', 9500),
(5, GETDATE(), 'Pending', 35000);
GO

INSERT INTO OrderItems
(OrderID, ProductID, Quantity, UnitPrice)
VALUES
(1001, 2, 1, 800),
(1002, 5, 1, 1500),
(1003, 1, 1, 45000),
(1004, 4, 1, 9500),
(1005, 1, 1, 35000);
GO


CREATE VIEW vw_order_summary
AS
SELECT
    o.OrderID,
    c.CustomerID,
    c.CustomerName,
    o.OrderDate,
    o.OrderStatus,
    p.ProductID,
    p.ProductName,
    oi.Quantity,
    oi.UnitPrice,
    (oi.Quantity * oi.UnitPrice) AS LineTotal
FROM Orders o
INNER JOIN Customers c
    ON o.CustomerID = c.CustomerID
INNER JOIN OrderItems oi
    ON o.OrderID = oi.OrderID
INNER JOIN Products p
    ON oi.ProductID = p.ProductID;
GO

-- Test order summary view
SELECT * FROM vw_order_summary;
GO

CREATE VIEW vw_low_stock
AS
SELECT
    ProductID,
    ProductName,
    StockQuantity,
    ReorderLevel
FROM Products
WHERE StockQuantity <= ReorderLevel;
GO

-- Test low stock view
SELECT * FROM vw_low_stock;
GO


CREATE VIEW vw_available_products
AS
SELECT
    ProductID,
    ProductName,
    SellingPrice,
    StockQuantity,
    ReorderLevel,
    IsActive
FROM Products
WHERE IsActive = 1
WITH CHECK OPTION;
GO

-- View available products
SELECT * FROM vw_available_products;
GO

-- Valid update through view
UPDATE vw_available_products
SET SellingPrice = 47000
WHERE ProductID = 1;
GO

-- Verify update
SELECT * FROM vw_available_products;
GO

-- This update violates the view condition.
-- WITH CHECK OPTION prevents it.
-- Uncomment to test the error.

-- UPDATE vw_available_products
-- SET IsActive = 0
-- WHERE ProductID = 1;
GO

