

-------------------------------------------- Set 1 – Logistics Shipment Analysis ---------------------------------------------

--create database LogisticsDB;

USE LogisticsDB;
GO

-- Create database if it does not exist

-- 1. Customers table
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

-- 2. Hubs table
CREATE TABLE Hubs (
    hub_id INT IDENTITY(1,1) PRIMARY KEY,
    hub_name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

-- 3. Carriers table
CREATE TABLE Carriers (
    carrier_id INT IDENTITY(1,1) PRIMARY KEY,
    carrier_name VARCHAR(100) NOT NULL
);

-- 4. Shipments table
CREATE TABLE Shipments (
    shipment_id INT IDENTITY(1001,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    carrier_id INT NULL,
    origin_hub_id INT NOT NULL,
    destination_hub_id INT NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    expected_delivery_date DATETIME2 NOT NULL,
    delivered_at DATETIME2 NULL,

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (carrier_id)
        REFERENCES Carriers(carrier_id),

    FOREIGN KEY (origin_hub_id)
        REFERENCES Hubs(hub_id),

    FOREIGN KEY (destination_hub_id)
        REFERENCES Hubs(hub_id),

    CHECK (shipping_cost >= 0)
);

-- 5. Delivery Events table
CREATE TABLE Delivery_Events (
    event_id INT IDENTITY(1,1) PRIMARY KEY,
    shipment_id INT NOT NULL,
    event_type VARCHAR(100),
    event_time DATETIME2,

    FOREIGN KEY (shipment_id)
        REFERENCES Shipments(shipment_id)
);

-- 6. Employees table
CREATE TABLE Employees (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    supervisor_id INT NULL,

    FOREIGN KEY (supervisor_id)
        REFERENCES Employees(employee_id)
);
GO

-- Customers
INSERT INTO Customers (customer_name, city)
VALUES
('Arun', 'Chennai'),
('Bala', 'Bangalore'),
('Charan', 'Hyderabad'),
('Divya', 'Mumbai');

-- Hubs
INSERT INTO Hubs (hub_name, location)
VALUES
('Chennai Central', 'Chennai'),
('Bangalore Hub', 'Bangalore'),
('Hyderabad Hub', 'Hyderabad'),
('Mumbai Hub', 'Mumbai'),
('Coimbatore Hub', 'Coimbatore');

-- Carriers
INSERT INTO Carriers (carrier_name)
VALUES
('FastTrack'),
('BlueDart'),
('SafeShip'),
('QuickExpress');

-- Shipments
INSERT INTO Shipments
(customer_id, carrier_id, origin_hub_id, destination_hub_id,
 shipping_cost, expected_delivery_date, delivered_at)
VALUES
(1, 1, 1, 2, 500, '2026-11-02', '2026-11-05'),
(1, 2, 2, 3, 800, '2026-11-03', '2026-11-03'),
(1, 1, 1, 4, 1200, '2026-11-04', '2026-11-08'),
(1, 2, 3, 5, 700, '2026-11-05', '2026-11-07'),
(2, 3, 2, 1, 600, '2026-11-06', '2026-11-10'),
(2, 1, 1, 3, 900, '2026-11-07', '2026-11-08'),
(3, 2, 4, 2, 1500, '2026-11-08', '2026-11-12'),
(4, NULL, 2, 4, 400, '2026-11-09', NULL),
(1, 3, 4, 1, 1100, '2026-11-10', '2026-11-11');

-- Delivery Events
INSERT INTO Delivery_Events
(shipment_id, event_type, event_time)
VALUES
(1001, 'Picked Up', '2026-11-02 09:00'),
(1001, 'In Transit', '2026-11-03 10:00'),
(1001, 'Delivered', '2026-11-05 15:00'),
(1002, 'Picked Up', '2026-11-03 08:00'),
(1002, 'Delivered', '2026-11-03 18:00'),
(1003, 'Picked Up', '2026-11-04 09:00'),
(1003, 'Delayed', '2026-11-07 12:00'),
(1003, 'Delivered', '2026-11-08 16:00'),
(1005, 'Picked Up', '2026-11-06 10:00'),
(1005, 'Delivered', '2026-11-10 14:00');

-- Employees
INSERT INTO Employees (employee_name, supervisor_id)
VALUES
('Priya', NULL),
('Arun Kumar', 1),
('Meena', 1),
('Karthik', 2);
GO
--------------------------------------------Task 1 : Ten Business Queries ----------------------------------------------------------------------

--Q1. Find shipments delayed by more than two days with carrier names
SELECT
    s.shipment_id,
    c.carrier_name,
    s.expected_delivery_date,
    s.delivered_at
FROM Shipments s
INNER JOIN Carriers c
    ON s.carrier_id = c.carrier_id
WHERE s.delivered_at > DATEADD(DAY, 2, s.expected_delivery_date);

--Q2. Display shipment details with customer and carrier names
SELECT
    s.shipment_id,
    cu.customer_name,
    ca.carrier_name,
    s.shipping_cost
FROM Shipments s
INNER JOIN Customers cu
    ON s.customer_id = cu.customer_id
INNER JOIN Carriers ca
    ON s.carrier_id = ca.carrier_id;

--Q3. Find hubs that have no outbound shipments
SELECT
    h.hub_id,
    h.hub_name
FROM Hubs h
LEFT JOIN Shipments s
    ON h.hub_id = s.origin_hub_id
WHERE s.shipment_id IS NULL;

--Q4. Display all hubs with their total outbound shipment count
SELECT
    h.hub_name,
    COUNT(s.shipment_id) AS total_shipments
FROM Hubs h
LEFT JOIN Shipments s
    ON h.hub_id = s.origin_hub_id
GROUP BY h.hub_name;

--Q5. Display all carriers and their shipment counts, including carriers without shipments
SELECT
    c.carrier_name,
    COUNT(s.shipment_id) AS total_shipments
FROM Carriers c
FULL OUTER JOIN Shipments s
    ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_name;

--Q6. Display employees along with their supervisor names
SELECT
    e.employee_name AS Employee,
    sup.employee_name AS Supervisor
FROM Employees e
LEFT JOIN Employees sup
    ON e.supervisor_id = sup.employee_id;

--Q7. Find customers who have not placed any shipments
SELECT
    c.customer_id,
    c.customer_name
FROM Customers c
LEFT JOIN Shipments s
    ON c.customer_id = s.customer_id
WHERE s.shipment_id IS NULL;

--Q8. Find shipments that do not have any delivery events
SELECT
    s.shipment_id,
    s.shipping_cost
FROM Shipments s
LEFT JOIN Delivery_Events d
    ON s.shipment_id = d.shipment_id
WHERE d.event_id IS NULL;

--Q9. Display shipment details with origin and destination hub names
SELECT
    s.shipment_id,
    origin.hub_name AS Origin_Hub,
    destination.hub_name AS Destination_Hub,
    s.shipping_cost
FROM Shipments s
INNER JOIN Hubs origin
    ON s.origin_hub_id = origin.hub_id
INNER JOIN Hubs destination
    ON s.destination_hub_id = destination.hub_id;

--Q10. Display all hubs with inbound and outbound shipment counts

WITH Outbound AS (
    SELECT
        origin_hub_id AS hub_id,
        COUNT(*) AS outbound_count
    FROM Shipments
    GROUP BY origin_hub_id
),
Inbound AS (
    SELECT
        destination_hub_id AS hub_id,
        COUNT(*) AS inbound_count
    FROM Shipments
    GROUP BY destination_hub_id
)
SELECT
    h.hub_name,
    ISNULL(o.outbound_count, 0) AS outbound_count,
    ISNULL(i.inbound_count, 0) AS inbound_count
FROM Hubs h
LEFT JOIN Outbound o
    ON h.hub_id = o.hub_id
LEFT JOIN Inbound i
    ON h.hub_id = i.hub_id;


--------------------------------------------------- Task 2 :Subqueries using IN, EXISTS, ANY and ALL -------------------------------------------
--in -Find customers who shipped to Chennai Central
SELECT *
FROM Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM Shipments
    WHERE destination_hub_id IN (
        SELECT hub_id
        FROM Hubs
        WHERE hub_name = 'Chennai Central'
    )
);

--exist -Find customers who have at least one shipment delayed by more than two days
SELECT *
FROM Customers c
WHERE EXISTS (
    SELECT 1
    FROM Shipments s
    WHERE s.customer_id = c.customer_id
      AND s.delivered_at > DATEADD(DAY, 2, s.expected_delivery_date)
);

--any - Find shipments whose shipping cost is greater than any shipments from Chennai Central
SELECT *
FROM Shipments
WHERE shipping_cost > ANY (
    SELECT shipping_cost
    FROM Shipments
    WHERE origin_hub_id = 1
);

--all - Find shipments whose shipping cost is greater than ALL shipments from Chennai Central
SELECT *
FROM Shipments
WHERE shipping_cost > ALL (
    SELECT shipping_cost
    FROM Shipments
    WHERE origin_hub_id = 1
);

--Find carriers whose average delivery delay is greater than the overall average delay
WITH CarrierDelay AS (
    SELECT
        carrier_id,
        AVG(
            CAST(
                DATEDIFF(MINUTE, expected_delivery_date, delivered_at)
                AS DECIMAL(10,2)
            ) / 1440.0
        ) AS average_delay
    FROM Shipments
    WHERE delivered_at IS NOT NULL
      AND carrier_id IS NOT NULL
    GROUP BY carrier_id
),
OverallDelay AS (
    SELECT
        AVG(
            CAST(
                DATEDIFF(MINUTE, expected_delivery_date, delivered_at)
                AS DECIMAL(10,2)
            ) / 1440.0
        ) AS overall_average
    FROM Shipments
    WHERE delivered_at IS NOT NULL
)
SELECT
    c.carrier_name,
    cd.average_delay,
    od.overall_average
FROM CarrierDelay cd
INNER JOIN Carriers c
    ON cd.carrier_id = c.carrier_id
CROSS JOIN OverallDelay od
WHERE cd.average_delay > od.overall_average;

------------------------------------------------------- Tas 3 : Rewrite subqueries using joins----------------------------------------------------
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM Customers c
INNER JOIN Shipments s
    ON c.customer_id = s.customer_id
WHERE s.destination_hub_id = 1;
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM Customers c
INNER JOIN Shipments s
    ON c.customer_id = s.customer_id
WHERE s.shipping_cost > 1000;


------------------------------------------ Task 4: Nested subquery – Second-highest shipping cost per hub ----------------------------------------
SELECT
    h.hub_id,
    h.hub_name,

    (
        SELECT MAX(s1.shipping_cost)
        FROM Shipments s1
        WHERE s1.origin_hub_id = h.hub_id
          AND s1.shipping_cost < (
              SELECT MAX(s2.shipping_cost)
              FROM Shipments s2
              WHERE s2.origin_hub_id = h.hub_id
          )
    ) AS second_highest_cost

FROM Hubs h;