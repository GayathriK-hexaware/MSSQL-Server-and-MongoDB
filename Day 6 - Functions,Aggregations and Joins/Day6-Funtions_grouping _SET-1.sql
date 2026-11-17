CREATE DATABASE RetailDB;
GO

USE RetailDB;
GO

--create 4 tables

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(50),
    price DECIMAL(10,2)
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

--insert values to each tables

INSERT INTO customers VALUES
(1, 'Arun', 'Chennai', 'arun@gmail.com'),
(2, 'Priya', 'Madurai', 'priya@gmail.com'),
(3, 'Kumar', 'Chennai', 'kumar@gmail.com'),
(4, 'Divya', 'Salem', 'divya@gmail.com'),
(5, 'Ravi', 'Madurai', 'ravi@gmail.com');
INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 50000),
(102, 'Mouse', 'Electronics', 500),
(103, 'Keyboard', 'Electronics', 1500),
(104, 'Chair', 'Furniture', 5000),
(105, 'Table', 'Furniture', 8000);
INSERT INTO orders VALUES
(1001, 1, '2026-11-01', 'Paid'),
(1002, 2, '2026-11-02', 'Paid'),
(1003, 1, '2026-11-05', 'Pending'),
(1004, 3, '2026-11-10', 'Paid'),
(1005, 2, '2026-11-15', 'Pending'),
(1006, 1, '2026-11-20', 'Paid'),
(1007, 4, '2026-12-01', 'Paid'),
(1008, 3, '2026-12-05', 'Paid');
INSERT INTO order_items VALUES
(1, 1001, 101, 1, 50000),
(2, 1001, 102, 2, 500),
(3, 1002, 104, 1, 5000),
(4, 1003, 103, 2, 1500),
(5, 1004, 101, 1, 50000),
(6, 1005, 105, 1, 8000),
(7, 1006, 102, 3, 500),
(8, 1007, 104, 2, 5000),
(9, 1008, 103, 1, 1500);

--verify data
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-------------------------------------------------Task 1 – Eight SQL reports------------------------------------------------------------
--1.Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

--2. Month-wise sales
SELECT
    FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY sales_month;

--3. Customers with more than 3 orders
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 3;

--4.Average basket value by city
SELECT
    c.city,
    ROUND(AVG(order_total), 2) AS average_basket_value
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_values
    ON o.order_id = order_values.order_id
GROUP BY c.city;

--5. Orders without payment
SELECT
    o.order_id,
    c.customer_name,
    o.payment_status
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.payment_status = 'Pending';

--6. Customers with no orders
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

--7.Product-category revenue share
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        (SELECT SUM(quantity * unit_price) FROM order_items),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category;

--8. Day with the highest sales
SELECT TOP 1
    o.order_date,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY total_sales DESC;


---------------------------------Task 2. Use string, date and mathematical functions-------------------------------------------
SELECT
    UPPER(c.customer_name) AS customer_name,
    CONCAT('City: ', c.city) AS customer_city,
    FORMAT(o.order_date, 'dd-MMM-yyyy') AS order_date,
    DATEDIFF(DAY, o.order_date, GETDATE()) AS days_since_order,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_amount
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_name,
    c.city,
    o.order_id,
    o.order_date;


-------------------------------------------Task 3. Explain COUNT(*) , COUNT(column) and AVG()----------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT(payment_status) AS available_payments,
    AVG(Fees) AS average_fees
FROM (
    SELECT
        CAST(5000 AS DECIMAL(10,2)) AS Fees,
        CAST('Paid' AS VARCHAR(20)) AS payment_status
    UNION ALL
    SELECT 6000, 'Pending'
    UNION ALL
    SELECT NULL, NULL
) AS sample;


---------------------------------------Task 5:Expected results document------------------------------------------------------------------
--        Task	                                                                       Expected result
--1. Top 5 products	                                Laptop ₹1,00,000; Chair ₹15,000; Table ₹8,000; Keyboard ₹4,500; Mouse ₹2,500
--2. Month-wise sales	                            November ₹1,18,500; December ₹11,500
--3. Customers with more than 3 orders	            No records
--4. Average basket value by city	                Chennai ₹26,375; Madurai ₹6,500; Salem ₹10,000
--5. Unpaid orders	                                1003 Arun; 1005 Priya
--6. Customers with no orders                 	    Ravi
--7. Category revenue share	                        Electronics ₹1,07,000 (82.31%); Furniture ₹23,000 (17.69%)
--8. Highest sales day	                            2026-11-01, ₹51,000

