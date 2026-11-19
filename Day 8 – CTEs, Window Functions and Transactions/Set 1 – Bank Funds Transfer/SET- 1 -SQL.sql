use tasks

--table creation
CREATE TABLE Accounts
(
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    Balance DECIMAL(10,2),
    AccountStatus VARCHAR(20)
);
CREATE TABLE Transactions
(
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    FromAccountID INT,
    ToAccountID INT,
    Amount DECIMAL(10,2),
    TransactionType VARCHAR(30),
    TransactionDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (FromAccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ToAccountID) REFERENCES Accounts(AccountID),

    CHECK (Amount > 0)
);
--insert values
INSERT INTO Accounts
VALUES
(101, 'Arun', 10000, 'Active'),
(102, 'Priya', 15000, 'Active'),
(103, 'Kumar', 5000, 'Active'),
(104, 'Divya', 20000, 'Frozen'),
(105, 'Rahul', 8000, 'Active');

select * from Accounts;

---------------------------------------------- TASK 1 : Fund transfer script ---------------------------------------------------------------------

DECLARE @FromAccountID INT = 101;
DECLARE @ToAccountID INT = 102;
DECLARE @Amount DECIMAL(10,2) = 2000;

DECLARE @FromBalance DECIMAL(10,2);
DECLARE @FromStatus VARCHAR(20);
DECLARE @ToStatus VARCHAR(20);

BEGIN TRY

    BEGIN TRAN;

    -- Validate transfer amount

    IF @Amount <= 0
        THROW 50001, 'Amount must be greater than zero.', 1;

    -- Check different accounts

    IF @FromAccountID = @ToAccountID
        THROW 50002, 'Source and destination cannot be the same.', 1;

    -- Get source account details

    SELECT
        @FromBalance = Balance,
        @FromStatus = AccountStatus
    FROM Accounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID = @FromAccountID;

    IF @FromStatus IS NULL
        THROW 50003, 'Source account does not exist.', 1;

    IF @FromStatus <> 'Active'
        THROW 50004, 'Source account is not active.', 1;

    -- Get destination account details

    SELECT
        @ToStatus = AccountStatus
    FROM Accounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID = @ToAccountID;

    IF @ToStatus IS NULL
        THROW 50005, 'Destination account does not exist.', 1;

    IF @ToStatus <> 'Active'
        THROW 50006, 'Destination account is not active.', 1;

    -- Check sufficient balance

    IF @FromBalance < @Amount
        THROW 50007, 'Insufficient balance.', 1;

    -- Debit amount from source account

    UPDATE Accounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccountID;

    -- Credit amount to destination account

    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccountID;

    -- Insert transaction history

    INSERT INTO Transactions
    (FromAccountID, ToAccountID, Amount, TransactionType)
    VALUES
    (@FromAccountID, @ToAccountID, @Amount, 'Funds Transfer');

    -- Save all changes

    COMMIT TRAN;

    PRINT 'Funds transferred successfully.';

END TRY

BEGIN CATCH

    -- Rollback if an error occurs

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;

-- 7. View Final Account Balances

SELECT * FROM Accounts;

-- 8. View Transaction History

SELECT * FROM Transactions;
Go
------------------------------------------------- Task 2 : Rollback on failure --------------------------------------------------------------------

DECLARE @FromAccountID INT = 101;
DECLARE @ToAccountID INT = 102;
DECLARE @Amount DECIMAL(10,2) = 2000;
BEGIN TRY

    BEGIN TRAN;
    -- Debit amount from Arun

    UPDATE Accounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccountID
      AND AccountStatus = 'Active'
      AND Balance >= @Amount;

    IF @@ROWCOUNT = 0
        THROW 50001, 'Debit failed. Check account status or balance.', 1;

    PRINT 'Debit successful.';

    -- Deliberately generate an error after debit

    THROW 50002, 'Deliberate failure after debit.', 1;

    -- This credit operation will not execute

    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccountID;

    COMMIT TRAN;

END TRY

BEGIN CATCH

    PRINT 'Error occurred: ' + ERROR_MESSAGE();

    PRINT 'Transaction state before rollback:';

    SELECT XACT_STATE() AS TransactionState;

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Transaction rolled back successfully.';

END CATCH;


-- 3. Check balances after rollback

SELECT AccountID, AccountHolder, Balance
FROM Accounts
WHERE AccountID IN (101, 102);

go
---------------------------------------------------- Task 3 : Savepoint --------------------------------------------------------------------------
    CREATE TABLE TransactionFees
    (
        FeeID INT IDENTITY(1,1) PRIMARY KEY,
        AccountID INT,
        FeeAmount DECIMAL(10,2),
        FeeDate DATETIME DEFAULT GETDATE(),

        FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
    );
-- 2. Transfer and Fee Posting
SET XACT_ABORT OFF;
DECLARE @FromAccountID INT = 101;
DECLARE @ToAccountID INT = 102;
DECLARE @Amount DECIMAL(10,2) = 1000;
DECLARE @Fee DECIMAL(10,2) = 50;
DECLARE @Balance DECIMAL(10,2);

BEGIN TRY
    BEGIN TRAN;
    -- Check sender balance and account status
    SELECT @Balance = Balance
    FROM Accounts WITH (UPDLOCK, HOLDLOCK)
    WHERE AccountID = @FromAccountID
      AND AccountStatus = 'Active';

    IF @Balance IS NULL
        THROW 50001, 'Source account is not active or does not exist.', 1;

    IF @Balance < @Amount
        THROW 50002, 'Insufficient balance.', 1;

    -- Check receiver account
    IF NOT EXISTS
    (
        SELECT 1
        FROM Accounts
        WHERE AccountID = @ToAccountID
          AND AccountStatus = 'Active'
    )
        THROW 50003, 'Destination account is not active.', 1;

    -- Perform the transfer
    UPDATE Accounts
    SET Balance = Balance - @Amount
    WHERE AccountID = @FromAccountID;

    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @ToAccountID;

    INSERT INTO Transactions
    (FromAccountID, ToAccountID, Amount, TransactionType)
    VALUES
    (@FromAccountID, @ToAccountID, @Amount, 'Funds Transfer');

    PRINT 'Transfer completed successfully.';

    -- Create savepoint after transfer

    SAVE TRANSACTION FeeSavepoint;

    -- Fee posting section

    BEGIN TRY

        UPDATE Accounts
        SET Balance = Balance - @Fee
        WHERE AccountID = @FromAccountID;

        INSERT INTO TransactionFees (AccountID, FeeAmount)
        VALUES (@FromAccountID, @Fee);

        -- Deliberately generate a fee posting error

        THROW 50004, 'Fee posting failed.', 1;

    END TRY

    BEGIN CATCH
        PRINT 'Fee error: ' + ERROR_MESSAGE();
        IF XACT_STATE() = 1
        BEGIN
            ROLLBACK TRANSACTION FeeSavepoint;
            PRINT 'Fee posting rolled back.';
        END
        ELSE
        BEGIN
            THROW;
        END
   END CATCH;
    -- Retain the successful transfer
COMMIT TRAN;

PRINT 'Transfer committed successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Transfer failed: ' + ERROR_MESSAGE();

    THROW;
END CATCH;
-- 3. Check Account Balances
SELECT *
FROM Accounts
WHERE AccountID IN (101, 102);
-- 4. Check Transfer History
SELECT *
FROM Transactions;
-- 5. Check Fee History
SELECT *
FROM TransactionFees;
GO


----------------------------------------------- Task 4 : cte & window functions(Bank statement) ------------------------------------------------------------------------
DECLARE @AccountID INT = 102;
DECLARE @OpeningBalance DECIMAL(10,2) = 15000;
DECLARE @MonthStart DATE = '2026-11-01';
DECLARE @NextMonthStart DATE = DATEADD(MONTH, 1, @MonthStart);


-- Step 1: Get account transactions

WITH TransactionDetails AS
(
    SELECT
        TransactionID,
        TransactionDate,
        TransactionType,
        Amount,

        CASE
            WHEN FromAccountID = @AccountID THEN 'Debit'
            ELSE 'Credit'
        END AS TransactionDirection,

        CASE
            WHEN FromAccountID = @AccountID THEN -Amount
            ELSE Amount
        END AS SignedAmount

    FROM Transactions

    WHERE
        (FromAccountID = @AccountID
         OR ToAccountID = @AccountID)

        AND TransactionDate >= @MonthStart
        AND TransactionDate < @NextMonthStart
),


-- Step 2: Calculate running balance

RunningBalance AS
(
    SELECT
        TransactionID,
        TransactionDate,
        TransactionType,
        TransactionDirection,
        Amount,

        @OpeningBalance +
        SUM(SignedAmount) OVER
        (
            ORDER BY TransactionDate, TransactionID
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS CurrentBalance

    FROM TransactionDetails
)


-- Step 3: Generate monthly statement

SELECT

    ROW_NUMBER() OVER
    (
        ORDER BY TransactionDate, TransactionID
    ) AS RowNumber,

    TransactionID,
    TransactionDate,
    TransactionType,
    TransactionDirection,
    Amount,

    LAG(CurrentBalance, 1, @OpeningBalance) OVER
    (
        ORDER BY TransactionDate, TransactionID
    ) AS PreviousBalance,

    CurrentBalance

FROM RunningBalance

ORDER BY TransactionDate, TransactionID;
GO

