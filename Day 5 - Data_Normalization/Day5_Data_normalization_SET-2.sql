
---set 2 :Bank Branch Accounts and Customer Activity


CREATE DATABASE BankDB;
GO

USE BankDB;
GO

---------------------------------------------------------------create Tables-----------------------------------------------------------------
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name VARCHAR(50) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE Branches (
    branch_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE AccountTypes (
    type_id INT IDENTITY(1,1) PRIMARY KEY,
    type_name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Managers (
    manager_id INT IDENTITY(1,1) PRIMARY KEY,
    manager_name VARCHAR(50) NOT NULL
);

CREATE TABLE Accounts (
    account_id INT IDENTITY(1,1) PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    type_id INT NOT NULL,
    branch_id INT NOT NULL,
    manager_id INT NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    opening_date DATE NOT NULL DEFAULT GETDATE(),

    CHECK (balance >= 0),

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (type_id)
        REFERENCES AccountTypes(type_id),

    FOREIGN KEY (branch_id)
        REFERENCES Branches(branch_id),

    FOREIGN KEY (manager_id)
        REFERENCES Managers(manager_id)
);


------------------------------------------------------------------ insert data ---------------------------------------------------------------

-- Customers
INSERT INTO Customers (customer_name, address) VALUES
('Arun', 'Chennai'),
('Priya', 'Madurai'),
('Kumar', 'Salem'),
('Divya', 'Trichy'),
('Ravi', 'Coimbatore');

-- Branches
INSERT INTO Branches (branch_name) VALUES
('Chennai Main'),
('Madurai Branch'),
('Salem Branch');

-- Account types
INSERT INTO AccountTypes (type_name) VALUES
('Savings'),
('Current');

-- Managers
INSERT INTO Managers (manager_name) VALUES
('Meena'),
('Ravi'),
('Karthik');

-- Accounts
INSERT INTO Accounts
(account_number, customer_id, type_id, branch_id,
 manager_id, balance, opening_date)
VALUES
('ACC101', 1, 1, 1, 1, 25000, '2026-07-10'),
('ACC102', 2, 1, 2, 2, 40000, '2026-08-15'),
('ACC103', 3, 2, 3, 3, 60000, '2026-09-20'),
('ACC104', 4, 1, 1, 1, 15000, '2026-10-10'),
('ACC105', 5, 2, 2, 2, 30000, '2026-06-01');


-----------------------------------------------------insert ,update and delete --------------------------------------------------------------------

-- Insert a new customer
INSERT INTO Customers (customer_name, address)
VALUES ('Anu', 'Erode');

-- Insert an account for the new customer
INSERT INTO Accounts
(account_number, customer_id, type_id, branch_id,
 manager_id, balance, opening_date)
VALUES
('ACC106', 6, 1, 3, 3, 10000, '2026-08-01');

-- Update account balance
UPDATE Accounts
SET balance = 12000
WHERE account_number = 'ACC106';

-- Delete the sample account
DELETE FROM Accounts
WHERE account_number = 'ACC106';

-- View accounts
SELECT * FROM Accounts;


--------------------------------------------------------------- WHERE conditions: AND, OR, IN and BETWEEN---------------------------------------

SELECT *
FROM Accounts
WHERE opening_date BETWEEN '2026-07-01' AND '2026-09-30'
AND balance > 20000
AND type_id IN (1, 2)
AND (branch_id = 1 OR branch_id = 2);

---------------------------------------------------------delete ,drop and truncate-----------------------------------------------------------

-- DELETE rollback
BEGIN TRANSACTION;
DELETE FROM TestAccounts;
ROLLBACK TRANSACTION;

-- TRUNCATE rollback
BEGIN TRANSACTION;
TRUNCATE TABLE TestAccounts;
ROLLBACK TRANSACTION;

-- DROP rollback
BEGIN TRANSACTION;
DROP TABLE TestAccounts;
ROLLBACK TRANSACTION;
