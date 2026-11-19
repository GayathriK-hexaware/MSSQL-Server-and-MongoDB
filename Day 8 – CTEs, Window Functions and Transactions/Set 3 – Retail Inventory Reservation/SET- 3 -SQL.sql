use tasks

--table creation
CREATE TABLE Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50)
);
GO

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    StockQuantity INT,
    UnitPrice DECIMAL(10,2),

    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CHECK (StockQuantity >= 0),
    CHECK (UnitPrice > 0)
);
GO

CREATE TABLE Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(50),
    OrderDate DATE DEFAULT GETDATE()
);
GO

CREATE TABLE OrderItems
(
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),

    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CHECK (Quantity > 0),
    CHECK (UnitPrice > 0)
);
GO


--insert value
INSERT INTO Categories VALUES
(1, 'Electronics'),
(2, 'Groceries'),
(3, 'Clothing');
GO

INSERT INTO Products VALUES
(101, 'Wireless Mouse', 1, 20, 800),
(102, 'Keyboard', 1, 15, 1500),
(103, 'Headphones', 1, 5, 2500),
(201, 'Rice Bag', 2, 50, 900),
(202, 'Coffee Powder', 2, 8, 400),
(203, 'Tea Powder', 2, 30, 250),
(301, 'T-Shirt', 3, 25, 600),
(302, 'Jeans', 3, 12, 1200);
GO

INSERT INTO Orders (CustomerName, OrderDate)
VALUES
('Arun', '2026-01-10'),
('Priya', '2026-01-20'),
('Kavin', '2026-02-05'),
('Meena', '2026-02-15'),
('Divya', '2026-03-10'),
('Rahul', '2026-03-20');
GO

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(1, 101, 2, 800),
(1, 102, 1, 1500),
(2, 103, 1, 2500),
(2, 201, 3, 900),
(3, 101, 3, 800),
(3, 202, 2, 400),
(4, 102, 2, 1500),
(4, 301, 3, 600),
(5, 103, 2, 2500),
(5, 302, 2, 1200),
(6, 201, 4, 900),
(6, 301, 2, 600);
GO
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

---------------------------------------------- Task 1 : Seat reservation --------------------------------------------------------------------

DECLARE @CustomerName VARCHAR(50) = 'Gayathri';

DECLARE @OrderLines TABLE
(
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

INSERT INTO @OrderLines VALUES
(101, 2, 800),
(102, 1, 1500);

SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRAN;

    IF EXISTS
    (
        SELECT 1
        FROM @OrderLines l
        LEFT JOIN Products p WITH (UPDLOCK, HOLDLOCK)
            ON l.ProductID = p.ProductID
        WHERE p.ProductID IS NULL
           OR p.StockQuantity < l.Quantity
    )
        THROW 50001, 'Product not found or insufficient stock.', 1;

    UPDATE p
    SET p.StockQuantity = p.StockQuantity - l.Quantity
    FROM Products p
    JOIN @OrderLines l
        ON p.ProductID = l.ProductID;

    INSERT INTO Orders (CustomerName, OrderDate)
    VALUES (@CustomerName, GETDATE());

    DECLARE @OrderID INT = SCOPE_IDENTITY();

    INSERT INTO OrderItems
    (OrderID, ProductID, Quantity, UnitPrice)
    SELECT
        @OrderID,
        ProductID,
        Quantity,
        UnitPrice
    FROM @OrderLines;

    COMMIT TRAN;

    PRINT 'Order placed successfully.';
    PRINT 'Order ID: ' + CAST(@OrderID AS VARCHAR(10));

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Order failed: ' + ERROR_MESSAGE();

    THROW;

END CATCH;
GO
SELECT * FROM Products
WHERE ProductID IN (101, 102);

SELECT * FROM Orders
WHERE CustomerName = 'Gayathri';

SELECT *
FROM OrderItems
WHERE OrderID =
(
    SELECT MAX(OrderID)
    FROM Orders
);

---------------------------------------------- Task 2 : Correlated subquery ---------------------------------------------------------------------

SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.StockQuantity,
    (
        SELECT AVG(CAST(p2.StockQuantity AS DECIMAL(10,2)))
        FROM Products p2
        WHERE p2.CategoryID = p.CategoryID
    ) AS CategoryAverageStock
FROM Products p
JOIN Categories c
    ON p.CategoryID = c.CategoryID
WHERE p.StockQuantity <
(
    SELECT AVG(CAST(p2.StockQuantity AS DECIMAL(10,2)))
    FROM Products p2
    WHERE p2.CategoryID = p.CategoryID
);
GO

--------------------------------------------- Task 3 : CTE and Row_number() ---------------------------------------------------------------------
WITH ProductSales AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        c.CategoryID,
        c.CategoryName,
        SUM(oi.Quantity) AS TotalSales
    FROM Products p
    JOIN Categories c
        ON p.CategoryID = c.CategoryID
    JOIN OrderItems oi
        ON p.ProductID = oi.ProductID
    GROUP BY
        p.ProductID,
        p.ProductName,
        c.CategoryID,
        c.CategoryName
),
RankedProducts AS
(
    SELECT
        ProductID,
        ProductName,
        CategoryID,
        CategoryName,
        TotalSales,

        ROW_NUMBER() OVER
        (
            PARTITION BY CategoryID
            ORDER BY TotalSales DESC, ProductID
        ) AS SalesRank

    FROM ProductSales
)
SELECT
    ProductID,
    ProductName,
    CategoryName,
    TotalSales,
    SalesRank
FROM RankedProducts
WHERE SalesRank <= 3
ORDER BY CategoryID, SalesRank;
GO


----------------------------------------------------------- Task 4 : Lead/Lag --------------------------------------------------------------------

WITH MonthRange AS
(
    SELECT
        DATEFROMPARTS(YEAR(MIN(OrderDate)), MONTH(MIN(OrderDate)), 1) AS MonthStart,
        DATEFROMPARTS(YEAR(MAX(OrderDate)), MONTH(MAX(OrderDate)), 1) AS LastMonth
    FROM Orders
),
MonthList AS
(
    SELECT MonthStart
    FROM MonthRange

    UNION ALL

    SELECT DATEADD(MONTH, 1, ml.MonthStart)
    FROM MonthList ml
    CROSS JOIN MonthRange mr
    WHERE ml.MonthStart < mr.LastMonth
),
MonthlySales AS
(
    SELECT
        oi.ProductID,
        DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1) AS SalesMonth,
        SUM(oi.Quantity) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    GROUP BY
        oi.ProductID,
        DATEFROMPARTS(YEAR(o.OrderDate), MONTH(o.OrderDate), 1)
),
ProductMonthlySales AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        ml.MonthStart AS SalesMonth,
        COALESCE(ms.TotalSales, 0) AS TotalSales
    FROM Products p
    CROSS JOIN MonthList ml
    LEFT JOIN MonthlySales ms
        ON p.ProductID = ms.ProductID
        AND ml.MonthStart = ms.SalesMonth
),
SalesComparison AS
(
    SELECT
        ProductID,
        ProductName,
        SalesMonth,
        TotalSales,

        LAG(TotalSales) OVER
        (
            PARTITION BY ProductID
            ORDER BY SalesMonth
        ) AS PreviousMonthSales,

        LEAD(TotalSales) OVER
        (
            PARTITION BY ProductID
            ORDER BY SalesMonth
        ) AS NextMonthSales

    FROM ProductMonthlySales
)
SELECT
    ProductID,
    ProductName,
    SalesMonth,
    PreviousMonthSales,
    TotalSales AS CurrentMonthSales,
    NextMonthSales,

    TotalSales - PreviousMonthSales AS SalesChange

FROM SalesComparison
ORDER BY ProductID, SalesMonth
OPTION (MAXRECURSION 1000);

