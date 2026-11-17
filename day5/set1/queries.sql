
-- 1. Duplicate primary key
BEGIN TRY
    INSERT INTO Supplier
    VALUES (1,'Duplicate Supplier','9999999999');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS DuplicateKeyError;
END CATCH;
GO

-- 2. Missing parent record
BEGIN TRY
    INSERT INTO Inventory
    VALUES (11,999,1,20,5);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS MissingParentError;
END CATCH;
GO

-- 3. Negative quantity
BEGIN TRY
    INSERT INTO Inventory
    VALUES (12,1,2,-10,5);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS NegativeQuantityError;
END CATCH;
GO

-- 4. NULL in mandatory column
BEGIN TRY
    INSERT INTO Supplier
    VALUES (11,NULL,'9999999999');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS NullColumnError;
END CATCH;
GO


-- task 4 : 

-- Before update
SELECT * FROM Supplier
WHERE SupplierID = 1;

-- Update phone number
UPDATE Supplier
SET SupplierPhone = '9123456780'
WHERE SupplierID = 1;

-- After update
SELECT * FROM Supplier
WHERE SupplierID = 1;



-- Before deletion
SELECT * FROM Product
WHERE Discontinued = 1;

-- Delete discontinued products
DELETE FROM Product
WHERE Discontinued = 1;

-- After deletion
SELECT * FROM Product
WHERE Discontinued = 1;

-- Check inventory after deletion
SELECT * FROM Inventory;



-- task 5:

-- Display product and supplier details
SELECT
    P.SKU,
    P.ProductName,
    C.CategoryName,
    S.SupplierName,
    S.SupplierPhone
FROM Product P
JOIN Category C
ON P.CategoryID = C.CategoryID
JOIN Supplier S
ON P.SupplierID = S.SupplierID;

-- Display warehouse stock details
SELECT
    P.ProductName,
    W.WarehouseName,
    I.Quantity,
    I.ReorderLevel
FROM Inventory I
JOIN Product P
ON I.ProductID = P.ProductID
JOIN Warehouse W
ON I.WarehouseID = W.WarehouseID;

-- Products requiring reorder
SELECT *
FROM Inventory
WHERE Quantity <= ReorderLevel;
GO

