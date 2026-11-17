
USE RetailInventoryDB;
GO

-- Supplier records
INSERT INTO Supplier VALUES
(1,'ABC Traders','9876543210'),
(2,'Global Supplies','9876543211'),
(3,'Tech World','9876543212'),
(4,'Prime Distributors','9876543213'),
(5,'Smart Products','9876543214'),
(6,'Universal Stores','9876543215'),
(7,'City Suppliers','9876543216'),
(8,'Elite Traders','9876543217'),
(9,'Mega Wholesale','9876543218'),
(10,'Best Suppliers','9876543219');

-- Category records
INSERT INTO Category VALUES
(1,'Electronics'),
(2,'Furniture'),
(3,'Clothing'),
(4,'Books'),
(5,'Groceries'),
(6,'Footwear'),
(7,'Accessories'),
(8,'Stationery'),
(9,'Home Appliances'),
(10,'Sports');

-- Warehouse records
INSERT INTO Warehouse VALUES
(1,'Central Warehouse','Coimbatore'),
(2,'North Warehouse','Chennai'),
(3,'South Warehouse','Madurai'),
(4,'East Warehouse','Salem'),
(5,'West Warehouse','Erode'),
(6,'Main Storage','Tiruppur'),
(7,'City Storage','Trichy'),
(8,'Industrial Storage','Bangalore'),
(9,'Retail Storage','Mysore'),
(10,'Backup Storage','Pondicherry');

-- Product records
INSERT INTO Product
(ProductID,SKU,ProductName,CategoryID,SupplierID,UnitPrice,Discontinued)
VALUES
(1,'SKU101','Laptop',1,1,55000,0),
(2,'SKU102','Office Chair',2,2,4500,0),
(3,'SKU103','T Shirt',3,3,799,0),
(4,'SKU104','Python Book',4,4,650,0),
(5,'SKU105','Rice Bag',5,5,1200,0),
(6,'SKU106','Sports Shoes',6,6,2500,0),
(7,'SKU107','Smart Watch',7,7,3500,0),
(8,'SKU108','Notebook',8,8,100,0),
(9,'SKU109','Mixer Grinder',9,9,2800,1),
(10,'SKU110','Football',10,10,900,1);

-- Inventory records
INSERT INTO Inventory
(InventoryID,ProductID,WarehouseID,Quantity,ReorderLevel)
VALUES
(1,1,1,50,10),
(2,2,2,30,5),
(3,3,3,100,20),
(4,4,4,75,10),
(5,5,5,200,50),
(6,6,6,40,10),
(7,7,7,25,5),
(8,8,8,150,30),
(9,9,9,20,5),
(10,10,10,60,15);
GO

-- Display all inserted records
SELECT * FROM Supplier;
SELECT * FROM Category;
SELECT * FROM Warehouse;
SELECT * FROM Product;
SELECT * FROM Inventory;
GO
