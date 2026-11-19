
USE RetailInventoryDB;
GO

-- 1. Products whose stock is below their category average
-- Using a correlated subquery

SELECT
    P.ProductID,
    P.ProductName,
    P.Category,
    P.StockQuantity
FROM dbo.Products P
WHERE P.StockQuantity <
(
    SELECT AVG(CAST(P2.StockQuantity AS DECIMAL(10,2)))
    FROM dbo.Products P2
    WHERE P2.Category = P.Category
)
ORDER BY P.Category, P.StockQuantity;
GO

-- 2. Create sample sales data

IF OBJECT_ID('dbo.ProductSales', 'U') IS NOT NULL
    DROP TABLE dbo.ProductSales;
GO

CREATE TABLE dbo.ProductSales
(
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    SaleDate DATE,
    QuantitySold INT,
    TotalAmount DECIMAL(12,2),

    FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID)
);
GO

INSERT INTO dbo.ProductSales
(ProductID, SaleDate, QuantitySold, TotalAmount)
VALUES
(1, '2026-01-10', 5, 250000),
(1, '2026-02-12', 8, 400000),
(1, '2026-03-15', 6, 300000),
(1, '2026-04-10', 10, 500000),

(2, '2026-01-15', 10, 200000),
(2, '2026-02-18', 15, 300000),
(2, '2026-03-20', 12, 240000),
(2, '2026-04-12', 18, 360000),

(3, '2026-01-20', 20, 40000),
(3, '2026-02-22', 25, 50000),
(3, '2026-03-25', 30, 60000),

(4, '2026-01-05', 8, 24000),
(4, '2026-02-08', 12, 36000),
(4, '2026-03-11', 15, 45000),

(5, '2026-01-12', 5, 35000),
(5, '2026-02-14', 7, 49000),
(5, '2026-03-16', 10, 70000),

(6, '2026-01-18', 50, 5000),
(6, '2026-02-20', 60, 6000),
(6, '2026-03-22', 80, 8000),

(7, '2026-01-25', 100, 2000),
(7, '2026-02-25', 120, 2400),
(7, '2026-03-25', 150, 3000);
GO

SELECT * FROM dbo.ProductSales;
GO

-- 3. Rank products by total sales within each category

;WITH ProductSalesSummary AS
(
    SELECT
        P.ProductID,
        P.ProductName,
        P.Category,
        SUM(S.QuantitySold) AS TotalUnitsSold,
        SUM(S.TotalAmount) AS TotalSales

    FROM dbo.Products P
    INNER JOIN dbo.ProductSales S
        ON P.ProductID = S.ProductID

    GROUP BY
        P.ProductID,
        P.ProductName,
        P.Category
),

RankedProducts AS
(
    SELECT
        ProductID,
        ProductName,
        Category,
        TotalUnitsSold,
        TotalSales,

        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY TotalUnitsSold DESC, ProductID
        ) AS SalesRank

    FROM ProductSalesSummary
)

SELECT
    ProductID,
    ProductName,
    Category,
    TotalUnitsSold,
    TotalSales,
    SalesRank

FROM RankedProducts

WHERE SalesRank <= 3

ORDER BY Category, SalesRank;
GO

-- 4. Month-on-month sales using LAG and LEAD

;WITH MonthlySales AS
(
    SELECT
        P.ProductID,
        P.ProductName,

        YEAR(S.SaleDate) AS SalesYear,
        MONTH(S.SaleDate) AS SalesMonth,

        SUM(S.TotalAmount) AS MonthlySales

    FROM dbo.ProductSales S
    INNER JOIN dbo.Products P
        ON S.ProductID = P.ProductID

    GROUP BY
        P.ProductID,
        P.ProductName,
        YEAR(S.SaleDate),
        MONTH(S.SaleDate)
),

SalesComparison AS
(
    SELECT
        ProductID,
        ProductName,
        SalesYear,
        SalesMonth,
        MonthlySales,

        LAG(MonthlySales) OVER
        (
            PARTITION BY ProductID
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthSales,

        LEAD(MonthlySales) OVER
        (
            PARTITION BY ProductID
            ORDER BY SalesYear, SalesMonth
        ) AS NextMonthSales

    FROM MonthlySales
)

SELECT
    ProductID,
    ProductName,
    SalesYear,
    SalesMonth,
    MonthlySales,
    PreviousMonthSales,

    MonthlySales - PreviousMonthSales AS MonthOnMonthChange,

    NextMonthSales

FROM SalesComparison

ORDER BY ProductID, SalesYear, SalesMonth;
GO
