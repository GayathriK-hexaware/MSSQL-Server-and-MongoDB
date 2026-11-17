


--CREATE DATABASE InsuranceDB;
GO

USE InsuranceDB;
GO

-- 1. Customers table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    age INT,
    city VARCHAR(50)
);

-- 2. Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);

-- 3. Agents table
CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(50)
);

-- 4. Policies table
CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    policy_number VARCHAR(30),
    customer_id INT,
    product_id INT,
    agent_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    premium_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

-- 5. Premiums table
CREATE TABLE premiums (
    premium_id INT PRIMARY KEY,
    policy_id INT,
    amount DECIMAL(10,2),
    payment_date DATE,
    payment_status VARCHAR(20),
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

-- 6. Claims table
CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_amount DECIMAL(10,2),
    settlement_amount DECIMAL(10,2),
    claim_status VARCHAR(20),
    damage_category VARCHAR(50),
    claim_date DATE,
    settled_date DATE,
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

-----insert data---
INSERT INTO customers VALUES
(1, 'Arun', 25, 'Chennai'),
(2, 'Priya', 35, 'Madurai'),
(3, 'Kumar', 45, 'Chennai'),
(4, 'Divya', 62, 'Salem');
INSERT INTO products VALUES
(101, 'Health Insurance'),
(102, 'Life Insurance'),
(103, 'Vehicle Insurance'),
(104, 'Home Insurance');
INSERT INTO agents VALUES
(201, 'Ravi'),
(202, 'Meena'),
(203, 'Karthik'),
(204, 'Sneha');
INSERT INTO policies VALUES
(1001, 'POL-2026-0001', 1, 101, 201, '2026-01-01', '2026-11-25', 'Active', 12000),
(1002, 'POL-2026-0002', 1, 102, 202, '2026-03-01', '2027-03-01', 'Active', 15000),
(1003, 'POL-2026-0003', 2, 103, 201, '2026-05-01', '2026-12-05', 'Active', 8000),
(1004, 'POL-2026-0004', 3, 104, 203, '2026-06-01', '2027-06-01', 'Active', 20000),
(1005, 'POL-2026-0005', 4, 101, 204, '2026-07-01', '2027-07-01', 'Expired', 10000);
INSERT INTO premiums VALUES
(1, 1001, 12000, '2026-01-01', 'Paid'),
(2, 1002, 15000, '2026-03-01', 'Paid'),
(3, 1003, 8000, '2026-05-01', 'Paid'),
(4, 1004, 20000, '2026-06-01', 'Paid'),
(5, 1005, 10000, '2026-07-01', 'Pending');
INSERT INTO claims VALUES
(501, 1001, 5000, 4000, 'Settled', 'Accident', '2026-02-01', '2026-02-10'),
(502, 1002, 8000, 7000, 'Settled', 'Medical', '2026-04-01', '2026-04-15'),
(503, 1003, 6000, 0, 'Pending', 'Accident', '2026-08-01', NULL),
(504, 1005, 3000, 2500, 'Settled', 'Fire', '2026-09-01', '2026-09-08');

----verify data-----
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM agents;
SELECT * FROM policies;
SELECT * FROM premiums;
SELECT * FROM claims;


------------------------------------------Task1: Eight SQL queries------------------------------------------------------------------
--Query 1: Policies expiring in the next 30 days
SELECT
    policy_id,
    policy_number,
    end_date,
    status
FROM policies
WHERE status = 'Active'
AND end_date BETWEEN CAST(GETDATE() AS DATE)
                 AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE));

--Query 2: Premium collected per product
SELECT
    pr.product_name,
    SUM(pm.amount) AS total_premium_collected
FROM products pr
JOIN policies p
    ON pr.product_id = p.product_id
JOIN premiums pm
    ON p.policy_id = pm.policy_id
WHERE pm.payment_status = 'Paid'
GROUP BY pr.product_name
ORDER BY total_premium_collected DESC;

--Query 3: Customers with more than one active policy
SELECT
    c.customer_name,
    COUNT(p.policy_id) AS active_policy_count
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
WHERE p.status = 'Active'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.policy_id) > 1;

--Query 4: Claim ratio per product
WITH PremiumTotals AS (
    SELECT
        p.product_id,
        SUM(pm.amount) AS total_premium
    FROM policies p
    JOIN premiums pm
        ON p.policy_id = pm.policy_id
    WHERE pm.payment_status = 'Paid'
    GROUP BY p.product_id
),
ClaimTotals AS (
    SELECT
        p.product_id,
        SUM(c.claim_amount) AS total_claims
    FROM policies p
    JOIN claims c
        ON p.policy_id = c.policy_id
    GROUP BY p.product_id
)
SELECT
    pr.product_name,
    COALESCE(ct.total_claims, 0) AS total_claims,
    pt.total_premium,
    ROUND(
        COALESCE(ct.total_claims, 0) * 100.0 /
        NULLIF(pt.total_premium, 0), 2
    ) AS claim_ratio_percentage
FROM products pr
JOIN PremiumTotals pt
    ON pr.product_id = pt.product_id
LEFT JOIN ClaimTotals ct
    ON pr.product_id = ct.product_id
ORDER BY claim_ratio_percentage DESC;


--Query 5: Policies without claims
SELECT
    p.policy_id,
    p.policy_number,
    c.customer_name
FROM policies p
JOIN customers c
    ON p.customer_id = c.customer_id
LEFT JOIN claims cl
    ON p.policy_id = cl.policy_id
WHERE cl.claim_id IS NULL;

--Query 6: Average premium by age band
SELECT
    CASE
        WHEN c.age < 30 THEN 'Below 30'
        WHEN c.age BETWEEN 30 AND 49 THEN '30-49'
        WHEN c.age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and above'
    END AS age_band,
    ROUND(AVG(p.premium_amount), 2) AS average_premium
FROM customers c
JOIN policies p
    ON c.customer_id = p.customer_id
GROUP BY
    CASE
        WHEN c.age < 30 THEN 'Below 30'
        WHEN c.age BETWEEN 30 AND 49 THEN '30-49'
        WHEN c.age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and above'
    END
ORDER BY age_band;

--Query 7: Monthly new policies
SELECT
    FORMAT(start_date, 'yyyy-MM') AS policy_month,
    COUNT(policy_id) AS new_policies
FROM policies
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY policy_month;

--Query 8: Top 5 agents by premium collected
SELECT TOP 5
    a.agent_name,
    COALESCE(SUM(pm.amount), 0) AS total_premium_collected
FROM agents a
LEFT JOIN policies p
    ON a.agent_id = p.agent_id
LEFT JOIN premiums pm
    ON p.policy_id = pm.policy_id
    AND pm.payment_status = 'Paid'
GROUP BY a.agent_id, a.agent_name
ORDER BY total_premium_collected DESC;

------------------------------------------------Task 2: SQL functions------------------------------------------------------------------
SELECT
    policy_id,
    CONCAT('****', RIGHT(policy_number, 4)) AS masked_policy_number,
    DATEDIFF(DAY, start_date, GETDATE()) AS policy_age_days,
    CASE
        WHEN DATEDIFF(DAY, start_date, GETDATE()) < 180
            THEN 'New Policy'
        WHEN DATEDIFF(DAY, start_date, GETDATE()) BETWEEN 180 AND 365
            THEN 'Medium Age Policy'
        ELSE 'Old Policy'
    END AS policy_age_band
FROM policies;


-------------------------------------Task 3: Difference between WHERE and HAVING-----------------------------------------------------------
--where filters records before grouping.
SELECT *
FROM policies
WHERE status = 'Active';

--Having filters groups after GROUP BY.
SELECT
    customer_id,
    COUNT(policy_id) AS total_policies
FROM policies
GROUP BY customer_id
HAVING COUNT(policy_id) > 1;


---------------------------------------------Task 4: Expected result document -------------------------------------------------------------------
--          Query	                                             Expected result
--1. Policies expiring	                        Policy 1001 and 1003
--2. Premium per product	                        Home ₹20,000; Life ₹15,000; Health ₹12,000; Vehicle ₹8,000
--3. Multiple active policies	                    Arun – 2
--4. Claim ratio	                                Vehicle 75%; Life 53.33%; Health 41.67%; Home 0%
--5. Policies without claims	                    Policy 1004 – Kumar
--6. Average premium by age	                    Below 30: ₹13,500; 30–49: ₹14,000; 60+: ₹10,000
--7. Monthly new policies	                        Jan, Mar, May, Jun, Jul – 1 each
--8. Top agents	                                Ravi ₹20,000; Karthik ₹20,000; Meena ₹15,000; Sneha ₹0