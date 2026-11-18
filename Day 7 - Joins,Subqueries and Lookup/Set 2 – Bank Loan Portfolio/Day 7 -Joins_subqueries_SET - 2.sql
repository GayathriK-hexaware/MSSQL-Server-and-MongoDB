
   --------------------------------------------SET 2 - BANK LOAN PORTFOLIO---------------------------------------------------------
  


-- ============================================================
-- TASK 0 : CREATE DATABASE AND TABLES
-- ============================================================

IF DB_ID('LoanPortfolioDB') IS NULL
    CREATE DATABASE LoanPortfolioDB;
GO

USE LoanPortfolioDB;
GO

-- Drop tables in child-to-parent order so the script can be rerun.
DROP TABLE IF EXISTS Loan_Participants;
DROP TABLE IF EXISTS Repayments;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Customers;
GO

-- 1. Customers
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    city VARCHAR(50)
);

-- 2. Branches
CREATE TABLE Branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- 3. Loans
CREATE TABLE Loans (
    loan_id INT PRIMARY KEY,
    branch_id INT NOT NULL,
    loan_amount DECIMAL(12,2) NOT NULL,
    outstanding_balance DECIMAL(12,2) NOT NULL,
    instalments_due INT NOT NULL DEFAULT 0,
    instalments_paid INT NOT NULL DEFAULT 0,
    loan_date DATE NOT NULL,
    loan_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT FK_Loans_Branches
        FOREIGN KEY (branch_id) REFERENCES Branches(branch_id),
    CONSTRAINT CK_Loans_Amount CHECK (loan_amount > 0),
    CONSTRAINT CK_Loans_Balance CHECK (outstanding_balance >= 0),
    CONSTRAINT CK_Loans_Instalments CHECK
        (instalments_due >= 0 AND instalments_paid >= 0)
);

-- 4. Repayments
CREATE TABLE Repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    repayment_date DATE NOT NULL,
    repayment_amount DECIMAL(12,2) NOT NULL,
    repayment_status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    CONSTRAINT FK_Repayments_Loans
        FOREIGN KEY (loan_id) REFERENCES Loans(loan_id),
    CONSTRAINT CK_Repayments_Amount CHECK (repayment_amount > 0)
);

-- 5. Loan_Participants
-- A customer can be a BORROWER on one loan and a GUARANTOR on another.
-- This table lets us demonstrate a genuine SELF JOIN.
CREATE TABLE Loan_Participants (
    participant_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    customer_id INT NOT NULL,
    participant_role VARCHAR(20) NOT NULL,
    CONSTRAINT FK_LoanParticipants_Loans
        FOREIGN KEY (loan_id) REFERENCES Loans(loan_id),
    CONSTRAINT FK_LoanParticipants_Customers
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT CK_LoanParticipants_Role
        CHECK (participant_role IN ('BORROWER', 'GUARANTOR')),
    CONSTRAINT UQ_LoanParticipants
        UNIQUE (loan_id, customer_id, participant_role)
);
GO

-- ============================================================
-- TASK 0 : INSERT SAMPLE DATA
-- ============================================================

-- Customers
INSERT INTO Customers (customer_id, customer_name, phone, city)
VALUES
(1, 'Arun',   '9000000001', 'Chennai'),
(2, 'Bala',   '9000000002', 'Chennai'),
(3, 'Charan', '9000000003', 'Bengaluru'),
(4, 'Divya',  '9000000004', 'Hyderabad'),
(5, 'Esha',   '9000000005', 'Mumbai'),
(6, 'Farhan', '9000000006', 'Chennai');

-- Branches (branch 5 intentionally has no loans)
INSERT INTO Branches (branch_id, branch_name, city)
VALUES
(1, 'Chennai Main Branch', 'Chennai'),
(2, 'T Nagar Branch',      'Chennai'),
(3, 'Bengaluru Branch',    'Bengaluru'),
(4, 'Hyderabad Branch',    'Hyderabad'),
(5, 'Mumbai Branch',       'Mumbai');

-- Loans
INSERT INTO Loans
(loan_id, branch_id, loan_amount, outstanding_balance,
 instalments_due, instalments_paid, loan_date, loan_status)
VALUES
(101, 1, 500000, 350000, 10,  5, DATEADD(DAY,-300,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(102, 1, 300000, 180000,  8,  7, DATEADD(DAY,-240,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(103, 2, 800000, 620000, 12,  6, DATEADD(DAY,-400,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(104, 2, 250000, 100000,  6,  6, DATEADD(DAY,-180,CAST(GETDATE() AS DATE)), 'CLOSED'),
(105, 3, 900000, 700000, 15,  9, DATEADD(DAY,-500,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(106, 3, 400000, 250000,  9,  8, DATEADD(DAY,-220,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(107, 4, 650000, 500000, 11,  4, DATEADD(DAY,-350,CAST(GETDATE() AS DATE)), 'ACTIVE'),
(108, 4, 200000,  80000,  5,  5, DATEADD(DAY,-150,CAST(GETDATE() AS DATE)), 'CLOSED'),
(109, 1, 150000, 120000,  7,  2, DATEADD(DAY,-200,CAST(GETDATE() AS DATE)), 'ACTIVE');

-- Loan participants: each loan has a borrower and a guarantor.
INSERT INTO Loan_Participants
(participant_id, loan_id, customer_id, participant_role)
VALUES
(1,  101, 1, 'BORROWER'),
(2,  101, 2, 'GUARANTOR'),
(3,  102, 2, 'BORROWER'),
(4,  102, 3, 'GUARANTOR'),
(5,  103, 3, 'BORROWER'),
(6,  103, 1, 'GUARANTOR'),
(7,  104, 1, 'BORROWER'),
(8,  104, 4, 'GUARANTOR'),
(9,  105, 4, 'BORROWER'),
(10, 105, 2, 'GUARANTOR'),
(11, 106, 2, 'BORROWER'),
(12, 106, 5, 'GUARANTOR'),
(13, 107, 5, 'BORROWER'),
(14, 107, 3, 'GUARANTOR'),
(15, 108, 3, 'BORROWER'),
(16, 108, 4, 'GUARANTOR'),
(17, 109, 1, 'BORROWER'),
(18, 109, 5, 'GUARANTOR');

-- Repayments: some are recent, some are older than 60 days.
INSERT INTO Repayments
(repayment_id, loan_id, repayment_date, repayment_amount, repayment_status)
VALUES
(1001, 101, DATEADD(DAY,-10,CAST(GETDATE() AS DATE)), 15000, 'SUCCESS'),
(1002, 101, DATEADD(DAY,-40,CAST(GETDATE() AS DATE)), 15000, 'SUCCESS'),
(1003, 102, DATEADD(DAY,-90,CAST(GETDATE() AS DATE)), 12000, 'SUCCESS'),
(1004, 103, DATEADD(DAY,-75,CAST(GETDATE() AS DATE)), 20000, 'SUCCESS'),
(1005, 104, DATEADD(DAY,-15,CAST(GETDATE() AS DATE)), 10000, 'SUCCESS'),
(1006, 105, DATEADD(DAY,-120,CAST(GETDATE() AS DATE)), 25000, 'SUCCESS'),
(1007, 106, DATEADD(DAY,-20,CAST(GETDATE() AS DATE)), 14000, 'SUCCESS'),
(1008, 107, DATEADD(DAY,-100,CAST(GETDATE() AS DATE)), 18000, 'SUCCESS'),
(1009, 108, DATEADD(DAY,-5,CAST(GETDATE() AS DATE)),  8000, 'SUCCESS');
GO

-- ============================================================
-- TASK 1 : TEN QUESTIONS USING JOINS
-- ============================================================

-- - Find loans overdue by more than three instalments
SELECT
    l.loan_id,
    c.customer_name,
    l.instalments_due - l.instalments_paid AS missed_instalments,
    l.outstanding_balance
FROM Loans l
INNER JOIN Loan_Participants p
    ON l.loan_id = p.loan_id
   AND p.participant_role = 'BORROWER'
INNER JOIN Customers c
    ON p.customer_id = c.customer_id
WHERE l.instalments_due - l.instalments_paid > 3;


-- - Find customers who have loans in more than one branch
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT l.branch_id) AS branch_count
FROM Customers c
INNER JOIN Loan_Participants p
    ON c.customer_id = p.customer_id
   AND p.participant_role = 'BORROWER'
INNER JOIN Loans l
    ON p.loan_id = l.loan_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT l.branch_id) > 1;


-- - Find guarantors who are also borrowers (SELF JOIN)
SELECT DISTINCT
    guarantor.customer_id,
    c.customer_name
FROM Loan_Participants guarantor
INNER JOIN Loan_Participants borrower
    ON guarantor.customer_id = borrower.customer_id
INNER JOIN Customers c
    ON guarantor.customer_id = c.customer_id
WHERE guarantor.participant_role = 'GUARANTOR'
  AND borrower.participant_role = 'BORROWER';


-- - Find branches that have no loans
SELECT
    b.branch_id,
    b.branch_name
FROM Branches b
LEFT JOIN Loans l
    ON b.branch_id = l.branch_id
WHERE l.loan_id IS NULL;


-- - Display loan details with borrower and branch names
SELECT
    l.loan_id,
    c.customer_name AS borrower_name,
    b.branch_name,
    l.loan_amount,
    l.outstanding_balance
FROM Loans l
INNER JOIN Loan_Participants p
    ON l.loan_id = p.loan_id
   AND p.participant_role = 'BORROWER'
INNER JOIN Customers c
    ON p.customer_id = c.customer_id
INNER JOIN Branches b
    ON l.branch_id = b.branch_id;


-- - Display all branches with their total number of loans, including zero
SELECT
    b.branch_id,
    b.branch_name,
    COUNT(l.loan_id) AS total_loans
FROM Branches b
LEFT JOIN Loans l
    ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name;


-- - Find loans that do not have any repayment records
SELECT
    l.loan_id,
    l.loan_amount,
    l.outstanding_balance
FROM Loans l
LEFT JOIN Repayments r
    ON l.loan_id = r.loan_id
WHERE r.repayment_id IS NULL;


-- - Find customers who have not borrowed any loan
SELECT
    c.customer_id,
    c.customer_name
FROM Customers c
LEFT JOIN Loan_Participants p
    ON c.customer_id = p.customer_id
   AND p.participant_role = 'BORROWER'
WHERE p.participant_id IS NULL;


-- - Display each loan with its guarantor name
SELECT
    l.loan_id,
    c.customer_name AS guarantor_name
FROM Loans l
INNER JOIN Loan_Participants p
    ON l.loan_id = p.loan_id
   AND p.participant_role = 'GUARANTOR'
INNER JOIN Customers c
    ON p.customer_id = c.customer_id;


-- - Find total repayment amount for each loan
SELECT
    l.loan_id,
    ISNULL(SUM(r.repayment_amount), 0) AS total_repaid
FROM Loans l
LEFT JOIN Repayments r
    ON l.loan_id = r.loan_id
GROUP BY l.loan_id;


-- ============================================================
-- TASK 2 : CORRELATED AND UNCORRELATED SUBQUERIES
-- ============================================================

-- - CORRELATED subquery: customers whose total loan exposure
--is greater than the average customer exposure in the same branch
SELECT
    exposure.branch_id,
    b.branch_name,
    exposure.customer_id,
    c.customer_name,
    exposure.total_exposure
FROM (
    SELECT
        l.branch_id,
        p.customer_id,
        SUM(l.outstanding_balance) AS total_exposure
    FROM Loans l
    INNER JOIN Loan_Participants p
        ON l.loan_id = p.loan_id
       AND p.participant_role = 'BORROWER'
    GROUP BY l.branch_id, p.customer_id
) exposure
INNER JOIN Branches b
    ON exposure.branch_id = b.branch_id
INNER JOIN Customers c
    ON exposure.customer_id = c.customer_id
WHERE exposure.total_exposure > (
    SELECT AVG(branch_customer.total_exposure)
    FROM (
        SELECT
            l2.branch_id,
            p2.customer_id,
            SUM(l2.outstanding_balance) AS total_exposure
        FROM Loans l2
        INNER JOIN Loan_Participants p2
            ON l2.loan_id = p2.loan_id
           AND p2.participant_role = 'BORROWER'
        GROUP BY l2.branch_id, p2.customer_id
    ) branch_customer
    WHERE branch_customer.branch_id = exposure.branch_id
);


-- - UNCORRELATED subquery: calculate branch-wise average exposure
--independently, then compare each customer's exposure with that average
SELECT
    exposure.branch_id,
    b.branch_name,
    exposure.customer_id,
    c.customer_name,
    exposure.total_exposure,
    branch_average.average_exposure
FROM (
    SELECT
        l.branch_id,
        p.customer_id,
        SUM(l.outstanding_balance) AS total_exposure
    FROM Loans l
    INNER JOIN Loan_Participants p
        ON l.loan_id = p.loan_id
       AND p.participant_role = 'BORROWER'
    GROUP BY l.branch_id, p.customer_id
) exposure
INNER JOIN (
    SELECT
        branch_customer.branch_id,
        AVG(branch_customer.total_exposure) AS average_exposure
    FROM (
        SELECT
            l.branch_id,
            p.customer_id,
            SUM(l.outstanding_balance) AS total_exposure
        FROM Loans l
        INNER JOIN Loan_Participants p
            ON l.loan_id = p.loan_id
           AND p.participant_role = 'BORROWER'
        GROUP BY l.branch_id, p.customer_id
    ) branch_customer
    GROUP BY branch_customer.branch_id
) branch_average
    ON exposure.branch_id = branch_average.branch_id
INNER JOIN Branches b
    ON exposure.branch_id = b.branch_id
INNER JOIN Customers c
    ON exposure.customer_id = c.customer_id
WHERE exposure.total_exposure > branch_average.average_exposure;


-- ============================================================
-- TASK 3 : EXISTS AND NOT EXISTS
-- ============================================================

-- - Find customers who have at least one loan but have made
--no successful repayment in the last 60 days
SELECT
    c.customer_id,
    c.customer_name
FROM Customers c
WHERE EXISTS (
    SELECT 1
    FROM Loan_Participants p
    WHERE p.customer_id = c.customer_id
      AND p.participant_role = 'BORROWER'
)
AND NOT EXISTS (
    SELECT 1
    FROM Loan_Participants p
    INNER JOIN Repayments r
        ON p.loan_id = r.loan_id
    WHERE p.customer_id = c.customer_id
      AND p.participant_role = 'BORROWER'
      AND r.repayment_status = 'SUCCESS'
      AND r.repayment_date >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
);


-- ============================================================
-- TASK 4 : NESTED SUBQUERY
-- ============================================================

-- Find branches whose highest loan amount is greater than
--the bank-wide average of each branch's maximum loan amount
SELECT
    b.branch_id,
    b.branch_name,
    (
        SELECT MAX(l.loan_amount)
        FROM Loans l
        WHERE l.branch_id = b.branch_id
    ) AS branch_highest_loan
FROM Branches b
WHERE (
    SELECT MAX(l.loan_amount)
    FROM Loans l
    WHERE l.branch_id = b.branch_id
) > (
    SELECT AVG(CAST(branch_max.maximum_loan AS DECIMAL(12,2)))
    FROM (
        SELECT
            branch_id,
            MAX(loan_amount) AS maximum_loan
        FROM Loans
        GROUP BY branch_id
    ) branch_max
);

