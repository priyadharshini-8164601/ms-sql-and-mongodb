
CREATE DATABASE RetailInventoryDB;
GO

USE RetailInventoryDB;
GO

-- 1. Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    SupplierPhone VARCHAR(15) NOT NULL
);

-- 2. Category Table
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Warehouse Table
CREATE TABLE Warehouse (
    WarehouseID INT PRIMARY KEY,
    WarehouseName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL
);

-- 4. Product Table
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL UNIQUE,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL DEFAULT 0,
    Discontinued BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_Product_Category
    FOREIGN KEY (CategoryID)
    REFERENCES Category(CategoryID),

    CONSTRAINT FK_Product_Supplier
    FOREIGN KEY (SupplierID)
    REFERENCES Supplier(SupplierID),

    CONSTRAINT CK_Product_Price
    CHECK (UnitPrice >= 0)
);

-- 5. Inventory Table
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    ProductID INT NOT NULL,
    WarehouseID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    ReorderLevel INT NOT NULL DEFAULT 5,

    CONSTRAINT FK_Inventory_Product
    FOREIGN KEY (ProductID)
    REFERENCES Product(ProductID)
    ON DELETE CASCADE,

    CONSTRAINT FK_Inventory_Warehouse
    FOREIGN KEY (WarehouseID)
    REFERENCES Warehouse(WarehouseID),

    CONSTRAINT CK_Inventory_Quantity
    CHECK (Quantity >= 0),

    CONSTRAINT CK_Inventory_Reorder
    CHECK (ReorderLevel >= 0),

    CONSTRAINT UQ_Product_Warehouse
    UNIQUE (ProductID, WarehouseID)
);
GO
