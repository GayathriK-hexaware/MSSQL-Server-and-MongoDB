
-- SET 3: TELECOM USAGE AND BILLING REPORTING


CREATE DATABASE TelecomDB;
GO
USE TelecomDB;
GO

-- 1. Plans
CREATE TABLE plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    data_limit_gb DECIMAL(10,2),
    monthly_price DECIMAL(10,2)
);

-- 2. Subscribers
CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY,
    subscriber_name VARCHAR(50),
    circle VARCHAR(50),
    plan_id INT,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- 3. Call Records
CREATE TABLE call_records (
    record_id INT PRIMARY KEY,
    subscriber_id INT,
    call_date DATETIME,
    duration_minutes INT,
    data_used_gb DECIMAL(10,2),
    cell_tower VARCHAR(30),
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);

-- 4. Invoices
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    subscriber_id INT,
    invoice_number VARCHAR(30),
    invoice_date DATE,
    due_date DATE,
    amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);

-- INSERT SAMPLE DATA


INSERT INTO plans VALUES
(101, 'Basic', 2.00, 300),
(102, 'Standard', 5.00, 500),
(103, 'Premium', 10.00, 800),
(104, 'Family', 8.00, 700);

INSERT INTO subscribers VALUES
(1, 'Arun', 'Chennai', 102),
(2, 'Priya', 'Madurai', 101),
(3, 'Kumar', 'Chennai', 103),
(4, 'Divya', 'Salem', 104);

INSERT INTO call_records VALUES
(1, 1, '2026-11-01 10:15:00', 12, 2.50, 'Tower-A'),
(2, 1, '2026-11-01 11:45:00', 8, 1.00, 'Tower-A'),
(3, 2, '2026-11-01 10:30:00', 20, 2.50, 'Tower-B'),
(4, 2, '2026-11-02 10:30:00', 15, 1.20, 'Tower-B'),
(5, 3, '2026-11-01 10:50:00', 15, 4.00, 'Tower-A'),
(6, 3, '2026-11-01 12:10:00', 10, 3.00, 'Tower-C');

INSERT INTO invoices VALUES
(1, 1, 'INV-2026-001', '2026-10-01', '2026-10-15', 500, 'Unpaid'),
(2, 2, 'INV-2026-002', '2026-10-05', '2026-10-20', 300, 'Unpaid'),
(3, 3, 'INV-2026-003', '2026-11-01', '2026-11-15', 800, 'Paid'),
(4, 1, 'INV-2026-004', '2026-11-01', '2026-11-15', 500, 'Paid');



---------------------------------------------------------Task 1 : Eight SQL queries ---------------------------------------------------
-- QUERY 1: TOTAL CALL MINUTES PER PLAN


SELECT
    p.plan_name,
    COALESCE(SUM(cr.duration_minutes), 0) AS total_call_minutes
FROM plans p
LEFT JOIN subscribers s ON p.plan_id = s.plan_id
LEFT JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY p.plan_name;


-- QUERY 2: SUBSCRIBERS EXCEEDING DATA LIMIT


SELECT
    s.subscriber_name,
    p.plan_name,
    p.data_limit_gb,
    SUM(cr.data_used_gb) AS total_data_used
FROM subscribers s
JOIN plans p ON s.plan_id = p.plan_id
JOIN call_records cr ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name,
         p.plan_name, p.data_limit_gb
HAVING SUM(cr.data_used_gb) > p.data_limit_gb;

-- QUERY 3: MONTH-WISE REVENUE

SELECT
    FORMAT(invoice_date, 'yyyy-MM') AS revenue_month,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY FORMAT(invoice_date, 'yyyy-MM')
ORDER BY revenue_month;


-- QUERY 4: INVOICES OVERDUE BY MORE THAN 15 DAYS

SELECT
    invoice_number,
    subscriber_id,
    due_date,
    amount,
    DATEDIFF(DAY, due_date, CAST(GETDATE() AS DATE))
        AS overdue_days
FROM invoices
WHERE payment_status = 'Unpaid'
AND due_date < DATEADD(DAY, -15, CAST(GETDATE() AS DATE));


-- QUERY 5: SUBSCRIBERS WITH NO USAGE

SELECT
    s.subscriber_id,
    s.subscriber_name
FROM subscribers s
LEFT JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
WHERE cr.record_id IS NULL;


-- QUERY 6: ARPU BY CIRCLE
-- ARPU = Total Revenue / Number of Subscribers

SELECT
    s.circle,
    ROUND(
        COALESCE(SUM(i.amount), 0) * 1.0 /
        COUNT(DISTINCT s.subscriber_id), 2
    ) AS ARPU
FROM subscribers s
LEFT JOIN invoices i
    ON s.subscriber_id = i.subscriber_id
GROUP BY s.circle;

-- QUERY 7: PLAN POPULARITY


SELECT
    p.plan_name,
    COUNT(s.subscriber_id) AS subscriber_count
FROM plans p
LEFT JOIN subscribers s
    ON p.plan_id = s.plan_id
GROUP BY p.plan_name
ORDER BY subscriber_count DESC;

-- ============================================
-- QUERY 8: TOP 10 DATA CONSUMERS
-- ============================================

SELECT TOP 10
    s.subscriber_name,
    SUM(cr.data_used_gb) AS total_data_used_gb
FROM subscribers s
JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY total_data_used_gb DESC;


------------------------------------------------TASK 2 : String and Date functions ------------------------------------------------

SELECT
    CONCAT('TEL-', RIGHT(invoice_number, 3))
        AS formatted_invoice_number,
    UPPER(payment_status) AS payment_status,
    due_date,
    CASE
        WHEN payment_status = 'Paid' THEN 'Paid'
        WHEN due_date < CAST(GETDATE() AS DATE) THEN 'Overdue'
        ELSE 'Not Due'
    END AS due_date_status,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), due_date)
        AS days_until_due
FROM invoices;
------------------------------------------------ Task 3 : NULL EFFECT ON SUM AND AVG ------------------------------------------------------

SELECT
    COUNT(*) AS total_subscribers,
    COUNT(cr.data_used_gb) AS subscribers_with_usage_rows,
    SUM(cr.data_used_gb) AS total_data_used,
    AVG(cr.data_used_gb) AS average_usage_per_record
FROM subscribers s
LEFT JOIN call_records cr
    ON s.subscriber_id = cr.subscriber_id;

----------------------------------------------- Task 4 : Expected SQL results ------------------------------------------------------------
--           Query	                                Expected output
--1. Call minutes per plan	            Basic: 35, Standard: 20, Premium: 25, Family: 0
--2. Exceeded data limit	                Priya: 3.7 GB (limit 2 GB)
--3. Monthly revenue	                    October: ₹800, November: ₹1,300
--4. Overdue invoices	                    INV-2026-001: 33 days; INV-2026-002: 28 days
--5. No usage	Divya
--6. ARPU by circle	                    Chennai: ₹900, Madurai: ₹300, Salem: ₹0
--7. Plan popularity	                    Basic: 1, Standard: 1, Premium: 1, Family: 1
--8. Top data consumers	                Kumar: 7 GB, Priya: 3.7 GB, Arun: 3.5 GB
