
------------------------------------------ SET 3 - RETAIL RETURNS AND REFUNDS --------------------------------------------------------------


-- ============================================================
-- TASK 0 : CREATE DATABASE AND TABLES
-- ============================================================

IF DB_ID('RetailReturnsDB') IS NULL
    CREATE DATABASE RetailReturnsDB;
GO

USE RetailReturnsDB;
GO

DROP TABLE IF EXISTS Returns_Feedback;
DROP TABLE IF EXISTS Refunds;
DROP TABLE IF EXISTS Returns;
DROP TABLE IF EXISTS Sale_Items;
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Stores;
DROP TABLE IF EXISTS Customers;
GO

-- 1. Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50)
);

-- 2. Stores
CREATE TABLE Stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL
);

-- 3. Products
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2) NOT NULL
);

-- 4. Employees
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    store_id INT NOT NULL,
    manager_id INT NULL,
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- 5. Sales
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    employee_id INT NOT NULL,
    sale_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES Stores(store_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 6. Sale Items
CREATE TABLE Sale_Items (
    sale_item_id INT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 7. Returns
CREATE TABLE Returns (
    return_id INT PRIMARY KEY,
    sale_item_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_quantity INT NOT NULL,
    return_reason VARCHAR(200),
    return_status VARCHAR(20),
    FOREIGN KEY (sale_item_id) REFERENCES Sale_Items(sale_item_id)
);

-- 8. Refunds
-- return_id is nullable to demonstrate the NOT IN NULL problem.
CREATE TABLE Refunds (
    refund_id INT PRIMARY KEY,
    return_id INT NULL,
    refund_date DATE NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_status VARCHAR(20),
    FOREIGN KEY (return_id) REFERENCES Returns(return_id)
);

-- 9. Returns Feedback
CREATE TABLE Returns_Feedback (
    feedback_id INT PRIMARY KEY,
    return_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT,
    comments VARCHAR(300),
    feedback_date DATE NOT NULL,
    FOREIGN KEY (return_id) REFERENCES Returns(return_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
GO


-- ============================================================
-- TASK 0 : INSERT SAMPLE DATA
-- ============================================================

-- CUSTOMERS
INSERT INTO Customers VALUES
(1,'Anu','Chennai'),
(2,'Bala','Chennai'),
(3,'Charan','Bengaluru'),
(4,'Divya','Bengaluru'),
(5,'Esha','Hyderabad'),
(6,'Farhan','Hyderabad');

-- STORES
INSERT INTO Stores VALUES
(1,'Chennai Central','South'),
(2,'Coimbatore Mall','South'),
(3,'Bengaluru City','West'),
(4,'Mysuru Plaza','West'),
(5,'Hyderabad Hub','South');

-- PRODUCTS
INSERT INTO Products VALUES
(1,'Wireless Mouse','Electronics',800),
(2,'Keyboard','Electronics',1500),
(3,'Water Bottle','Home',400),
(4,'Backpack','Accessories',1200),
(5,'Headphones','Electronics',2500),
(6,'Desk Lamp','Home',900);

-- EMPLOYEES
INSERT INTO Employees VALUES
(1,'Meera',1,NULL),
(2,'Kavin',1,1),
(3,'Riya',2,NULL),
(4,'Arun',3,NULL),
(5,'Nila',3,4),
(6,'Sanjay',4,NULL);

-- SALES
INSERT INTO Sales VALUES
(101,1,1,1,'2026-10-01'),
(102,2,1,2,'2026-10-03'),
(103,3,2,3,'2026-10-05'),
(104,4,3,4,'2026-10-07'),
(105,5,3,5,'2026-10-09'),
(106,1,2,3,'2026-10-11'),
(107,2,4,6,'2026-10-13'),
(108,3,1,2,'2026-10-15'),
(109,4,5,1,'2026-10-17'),
(110,6,3,5,'2026-10-19');

-- SALE ITEMS
INSERT INTO Sale_Items VALUES
(1001,101,1,10,800),
(1002,101,2,5,1500),
(1003,102,1,8,800),
(1004,102,3,10,400),
(1005,103,2,10,1500),
(1006,103,4,5,1200),
(1007,104,5,10,2500),
(1008,105,1,12,800),
(1009,106,3,8,400),
(1010,107,4,10,1200),
(1011,108,5,5,2500),
(1012,109,6,10,900),
(1013,110,2,8,1500);

-- RETURNS
INSERT INTO Returns VALUES
(201,1001,'2026-10-10',2,'Damaged item','APPROVED'),
(202,1002,'2026-10-12',1,'Wrong product','APPROVED'),
(203,1003,'2026-10-14',2,'Not working','APPROVED'),
(204,1005,'2026-10-16',3,'Changed mind','APPROVED'),
(205,1007,'2026-10-18',2,'Sound issue','APPROVED'),
(206,1008,'2026-10-20',1,'Damaged item','PENDING'),
(207,1009,'2026-10-22',2,'Quality issue','APPROVED'),
(208,1011,'2026-10-24',1,'Not satisfied','APPROVED'),
(209,1012,'2026-10-25',1,'Defective','PENDING');

-- REFUNDS
INSERT INTO Refunds VALUES
(301,201,'2026-10-11',1600,'PAID'),
(302,202,'2026-10-13',1500,'PAID'),
(303,203,'2026-10-15',1600,'PAID'),
(304,204,'2026-10-17',3600,'PAID'),
(305,205,'2026-10-19',5000,'PAID'),
(306,207,'2026-10-23',800,'PAID'),
(307,208,'2026-10-25',2500,'PAID'),
(308,NULL,'2026-10-26',100,'MANUAL_ADJUSTMENT');

-- RETURNS FEEDBACK
INSERT INTO Returns_Feedback VALUES
(401,201,1,5,'Quick refund process','2026-10-12'),
(402,202,1,3,'Replacement was not available','2026-10-14'),
(403,203,2,4,'Issue resolved','2026-10-16'),
(404,204,3,2,'Refund took time','2026-10-18'),
(405,205,4,5,'Good support','2026-10-20'),
(406,207,1,4,'Satisfied','2026-10-24');
GO


-- ============================================================
-- TASK 1 : TEN QUESTIONS USING JOINS
-- ============================================================

-- - Find products with a return rate above 10 percent
--Return rate = returned quantity / sold quantity * 100
SELECT
    p.product_id,
    p.product_name,
    SUM(si.quantity) AS sold_quantity,
    ISNULL(SUM(r.return_quantity),0) AS returned_quantity,
    CAST(
        ISNULL(SUM(r.return_quantity),0) * 100.0 /
        NULLIF(SUM(si.quantity),0)
        AS DECIMAL(6,2)
    ) AS return_rate_percent
FROM Products p
INNER JOIN Sale_Items si
    ON p.product_id = si.product_id
LEFT JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
GROUP BY p.product_id, p.product_name
HAVING ISNULL(SUM(r.return_quantity),0) * 100.0 /
       NULLIF(SUM(si.quantity),0) > 10;


-- - Find customers who have returns but no refund
SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    r.return_id
FROM Customers c
INNER JOIN Sales s
    ON c.customer_id = s.customer_id
INNER JOIN Sale_Items si
    ON s.sale_id = si.sale_id
INNER JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
LEFT JOIN Refunds f
    ON r.return_id = f.return_id
WHERE f.refund_id IS NULL;


-- - Find the store with the highest total refund value
SELECT TOP 1 WITH TIES
    st.store_id,
    st.store_name,
    SUM(f.refund_amount) AS total_refund_value
FROM Stores st
INNER JOIN Sales s
    ON st.store_id = s.store_id
INNER JOIN Sale_Items si
    ON s.sale_id = si.sale_id
INNER JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
INNER JOIN Refunds f
    ON r.return_id = f.return_id
WHERE f.refund_status = 'PAID'
GROUP BY st.store_id, st.store_name
ORDER BY SUM(f.refund_amount) DESC;


-- - Display employees and their managers (SELF JOIN)
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager,
    st.store_name
FROM Employees e
LEFT JOIN Employees m
    ON e.manager_id = m.employee_id
INNER JOIN Stores st
    ON e.store_id = st.store_id;


-- - Display every return with product and customer details
SELECT
    r.return_id,
    p.product_name,
    c.customer_name,
    r.return_quantity,
    r.return_reason,
    r.return_status
FROM Returns r
INNER JOIN Sale_Items si
    ON r.sale_item_id = si.sale_item_id
INNER JOIN Products p
    ON si.product_id = p.product_id
INNER JOIN Sales s
    ON si.sale_id = s.sale_id
INNER JOIN Customers c
    ON s.customer_id = c.customer_id;


-- - Find stores that have no returns
SELECT
    st.store_id,
    st.store_name
FROM Stores st
LEFT JOIN Sales s
    ON st.store_id = s.store_id
LEFT JOIN Sale_Items si
    ON s.sale_id = si.sale_id
LEFT JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
GROUP BY st.store_id, st.store_name
HAVING COUNT(r.return_id) = 0;


-- - Find total refund value for each customer
SELECT
    c.customer_id,
    c.customer_name,
    ISNULL(SUM(f.refund_amount),0) AS total_refund
FROM Customers c
LEFT JOIN Sales s
    ON c.customer_id = s.customer_id
LEFT JOIN Sale_Items si
    ON s.sale_id = si.sale_id
LEFT JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
LEFT JOIN Refunds f
    ON r.return_id = f.return_id
GROUP BY c.customer_id, c.customer_name;


-- - Find returns that do not have feedback
SELECT
    r.return_id,
    r.return_reason,
    r.return_status
FROM Returns r
LEFT JOIN Returns_Feedback fb
    ON r.return_id = fb.return_id
WHERE fb.feedback_id IS NULL;


-- - Display each store with its total sales and return count
SELECT
    st.store_id,
    st.store_name,
    COUNT(DISTINCT s.sale_id) AS total_sales,
    COUNT(DISTINCT r.return_id) AS total_returns
FROM Stores st
LEFT JOIN Sales s
    ON st.store_id = s.store_id
LEFT JOIN Sale_Items si
    ON s.sale_id = si.sale_id
LEFT JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
GROUP BY st.store_id, st.store_name;


-- - Display return details with refund information
--including returns that have no refund yet
SELECT
    r.return_id,
    r.return_status,
    f.refund_id,
    f.refund_amount,
    f.refund_status
FROM Returns r
LEFT JOIN Refunds f
    ON r.return_id = f.return_id;


-- ============================================================
-- TASK 2 : IN / NOT IN AND THE NULL PITFALL
-- ============================================================

-- - IN: Find customers who have made at least one return
SELECT
    customer_id,
    customer_name
FROM Customers
WHERE customer_id IN (
    SELECT s.customer_id
    FROM Sales s
    INNER JOIN Sale_Items si
        ON s.sale_id = si.sale_id
    INNER JOIN Returns r
        ON si.sale_item_id = r.sale_item_id
);


-- - NOT IN demonstration
--This returns no rows because Refunds contains a NULL return_id.
SELECT
    r.return_id
FROM Returns r
WHERE r.return_id NOT IN (
    SELECT f.return_id
    FROM Refunds f
);


-- - Correct the NULL problem using NOT EXISTS
SELECT
    r.return_id
FROM Returns r
WHERE NOT EXISTS (
    SELECT 1
    FROM Refunds f
    WHERE f.return_id = r.return_id
);


-- - Find customers who have returns but no refund
--using the safe NOT EXISTS approach
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM Customers c
INNER JOIN Sales s
    ON c.customer_id = s.customer_id
INNER JOIN Sale_Items si
    ON s.sale_id = si.sale_id
INNER JOIN Returns r
    ON si.sale_item_id = r.sale_item_id
WHERE NOT EXISTS (
    SELECT 1
    FROM Refunds f
    WHERE f.return_id = r.return_id
);


--- NOT IN is safe if NULL values are excluded explicitly
SELECT
    r.return_id
FROM Returns r
WHERE r.return_id NOT IN (
    SELECT f.return_id
    FROM Refunds f
    WHERE f.return_id IS NOT NULL
);


-- ============================================================
-- TASK 3 : ANY AND ALL
--Compare each store's refunds with other stores in its region
-- ============================================================

-- - Stores whose refund total is greater than ANY other
--store's refund total in the same region
WITH StoreRefunds AS (
    SELECT
        st.store_id,
        st.store_name,
        st.region,
        ISNULL(SUM(
            CASE WHEN f.refund_status = 'PAID'
                 THEN f.refund_amount ELSE 0 END
        ),0) AS total_refunds
    FROM Stores st
    LEFT JOIN Sales s
        ON st.store_id = s.store_id
    LEFT JOIN Sale_Items si
        ON s.sale_id = si.sale_id
    LEFT JOIN Returns r
        ON si.sale_item_id = r.sale_item_id
    LEFT JOIN Refunds f
        ON r.return_id = f.return_id
    GROUP BY st.store_id, st.store_name, st.region
)
SELECT
    current_store.store_name,
    current_store.region,
    current_store.total_refunds
FROM StoreRefunds current_store
WHERE current_store.total_refunds > ANY (
    SELECT other_store.total_refunds
    FROM StoreRefunds other_store
    WHERE other_store.region = current_store.region
      AND other_store.store_id <> current_store.store_id
);


-- - Stores whose refund total is greater than ALL other
--stores' refund totals in the same region
WITH StoreRefunds AS (
    SELECT
        st.store_id,
        st.store_name,
        st.region,
        ISNULL(SUM(
            CASE WHEN f.refund_status = 'PAID'
                 THEN f.refund_amount ELSE 0 END
        ),0) AS total_refunds
    FROM Stores st
    LEFT JOIN Sales s
        ON st.store_id = s.store_id
    LEFT JOIN Sale_Items si
        ON s.sale_id = si.sale_id
    LEFT JOIN Returns r
        ON si.sale_item_id = r.sale_item_id
    LEFT JOIN Refunds f
        ON r.return_id = f.return_id
    GROUP BY st.store_id, st.store_name, st.region
)
SELECT
    current_store.store_name,
    current_store.region,
    current_store.total_refunds
FROM StoreRefunds current_store
WHERE current_store.total_refunds > ALL (
    SELECT other_store.total_refunds
    FROM StoreRefunds other_store
    WHERE other_store.region = current_store.region
      AND other_store.store_id <> current_store.store_id
);


-- ============================================================
-- TASK 4 : TWO NESTED SUBQUERIES
-- ============================================================

-- - Nested subquery 1: Customers whose total refund is greater
--than the average total refund per customer
SELECT
    c.customer_id,
    c.customer_name,
    (
        SELECT SUM(f.refund_amount)
        FROM Sales s
        INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
        INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
        INNER JOIN Refunds f ON r.return_id = f.return_id
        WHERE s.customer_id = c.customer_id
          AND f.refund_status = 'PAID'
    ) AS customer_refund_total
FROM Customers c
WHERE ISNULL((
    SELECT SUM(f.refund_amount)
    FROM Sales s
    INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
    INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
    INNER JOIN Refunds f ON r.return_id = f.return_id
    WHERE s.customer_id = c.customer_id
      AND f.refund_status = 'PAID'
),0) > (
    SELECT AVG(customer_totals.total_refund)
    FROM (
        SELECT
            s.customer_id,
            SUM(f.refund_amount) AS total_refund
        FROM Sales s
        INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
        INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
        INNER JOIN Refunds f ON r.return_id = f.return_id
        WHERE f.refund_status = 'PAID'
        GROUP BY s.customer_id
    ) customer_totals
);


-- - Nested subquery 2: Stores whose highest individual refund
--is greater than the average of the stores' highest refunds
SELECT
    st.store_id,
    st.store_name,
    (
        SELECT MAX(f.refund_amount)
        FROM Sales s
        INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
        INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
        INNER JOIN Refunds f ON r.return_id = f.return_id
        WHERE s.store_id = st.store_id
          AND f.refund_status = 'PAID'
    ) AS highest_refund
FROM Stores st
WHERE ISNULL((
    SELECT MAX(f.refund_amount)
    FROM Sales s
    INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
    INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
    INNER JOIN Refunds f ON r.return_id = f.return_id
    WHERE s.store_id = st.store_id
      AND f.refund_status = 'PAID'
),0) > (
    SELECT AVG(CAST(store_max.maximum_refund AS DECIMAL(10,2)))
    FROM (
        SELECT
            s.store_id,
            MAX(f.refund_amount) AS maximum_refund
        FROM Sales s
        INNER JOIN Sale_Items si ON s.sale_id = si.sale_id
        INNER JOIN Returns r ON si.sale_item_id = r.sale_item_id
        INNER JOIN Refunds f ON r.return_id = f.return_id
        WHERE f.refund_status = 'PAID'
        GROUP BY s.store_id
    ) store_max
);


