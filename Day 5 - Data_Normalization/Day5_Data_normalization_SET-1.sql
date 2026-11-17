
CREATE DATABASE RetailInventoryDB;
GO

USE RetailInventoryDB;
GO

---------------------------------------------------------------------creating tables-------------------------------------------------
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(50) NOT NULL,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,

    FOREIGN KEY (category_id)
        REFERENCES Categories(category_id),

    FOREIGN KEY (supplier_id)
        REFERENCES Suppliers(supplier_id)
);

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0
        CHECK (quantity >= 0),
    reorder_level INT NOT NULL DEFAULT 5
        CHECK (reorder_level >= 0),

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
        ON DELETE CASCADE,

    FOREIGN KEY (warehouse_id)
        REFERENCES Warehouses(warehouse_id),

    UNIQUE (product_id, warehouse_id)
);

-------------------------------------------------------------------insert values-------------------------------------------------------------
-- 10 Categories
INSERT INTO Categories VALUES
(1,'Electronics'), (2,'Clothing'),
(3,'Furniture'), (4,'Books'),
(5,'Sports'), (6,'Kitchen'),
(7,'Toys'), (8,'Beauty'),
(9,'Stationery'), (10,'Footwear');

-- 10 Suppliers
INSERT INTO Suppliers VALUES
(1,'ABC Traders','9000000001'),
(2,'Best Supplies','9000000002'),
(3,'City Suppliers','9000000003'),
(4,'Delta Stores','9000000004'),
(5,'Easy Traders','9000000005'),
(6,'Fresh Supplies','9000000006'),
(7,'Global Traders','9000000007'),
(8,'Happy Stores','9000000008'),
(9,'Ideal Suppliers','9000000009'),
(10,'Jupiter Traders','9000000010');

-- 10 Warehouses
INSERT INTO Warehouses VALUES
(1,'Chennai'), (2,'Madurai'),
(3,'Salem'), (4,'Trichy'),
(5,'Coimbatore'), (6,'Erode'),
(7,'Vellore'), (8,'Tirunelveli'),
(9,'Thanjavur'), (10,'Dindigul');

-- 10 Products
INSERT INTO Products VALUES
(1,'SKU001','Laptop',1,1),
(2,'SKU002','Shirt',2,2),
(3,'SKU003','Chair',3,3),
(4,'SKU004','Novel',4,4),
(5,'SKU005','Football',5,5),
(6,'SKU006','Mixer',6,6),
(7,'SKU007','Doll',7,7),
(8,'SKU008','Face Cream',8,8),
(9,'SKU009','Notebook',9,9),
(10,'SKU010','Shoes',10,10);

-- 10 Inventory records
INSERT INTO Inventory VALUES
(1,1,1,20,5),
(2,2,2,30,10),
(3,3,3,15,5),
(4,4,4,40,10),
(5,5,5,25,5),
(6,6,6,12,5),
(7,7,7,18,5),
(8,8,8,22,5),
(9,9,9,50,10),
(10,10,10,16,5);
--------------------------------------insert with failure cases-------------------------------------------------------------------------

-- 1. Duplicate primary key
BEGIN TRY
    INSERT INTO Categories
    VALUES (1, 'Duplicate Category');
END TRY
BEGIN CATCH
    PRINT 'Error 1: Duplicate primary key';
END CATCH;

-- 2. Missing parent supplier
BEGIN TRY
    INSERT INTO Products
    VALUES (11, 'SKU011', 'Tablet', 1, 99);
END TRY
BEGIN CATCH
    PRINT 'Error 2: Supplier does not exist';
END CATCH;

-- 3. Negative quantity
BEGIN TRY
    INSERT INTO Inventory
    VALUES (11, 1, 1, -5, 5);
END TRY
BEGIN CATCH
    PRINT 'Error 3: Quantity cannot be negative';
END CATCH;

-- 4. NULL in mandatory column
BEGIN TRY
    INSERT INTO Suppliers
    VALUES (11, NULL, '9000000011');
END TRY
BEGIN CATCH
    PRINT 'Error 4: Supplier name cannot be NULL';
END CATCH;


--------------------------------------------------- update ,delelte -------------------------------------------------------------------------

-- Before update
SELECT * FROM Suppliers
WHERE supplier_id = 1;

-- Correct supplier phone number
UPDATE Suppliers
SET phone = '9888888881'
WHERE supplier_id = 1;

-- After update
SELECT * FROM Suppliers
WHERE supplier_id = 1;

-- Before delete
SELECT * FROM Products
WHERE SKU = 'SKU010';

-- Remove discontinued product
DELETE FROM Products
WHERE SKU = 'SKU010';

-- After delete
SELECT * FROM Products
WHERE SKU = 'SKU010';

-- Check inventory: its row is also deleted by CASCADE
SELECT * FROM Inventory
WHERE product_id = 10;
