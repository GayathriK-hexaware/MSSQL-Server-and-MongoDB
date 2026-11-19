
use tasks

--table creation
CREATE TABLE Flights
(
    FlightID INT PRIMARY KEY,
    FlightName VARCHAR(100)
);
GO

CREATE TABLE Passengers
(
    PassengerID INT PRIMARY KEY,
    PassengerName VARCHAR(50)
);
GO

CREATE TABLE Seats
(
    FlightID INT,
    SeatNo VARCHAR(10),
    SeatStatus VARCHAR(20),
    PRIMARY KEY (FlightID, SeatNo),
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    CHECK (SeatStatus IN ('Available', 'Booked'))
);
GO

CREATE TABLE Bookings
(
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    FlightID INT,
    SeatNo VARCHAR(10),
    PassengerID INT,
    Fare DECIMAL(10,2),
    BookingDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (FlightID, SeatNo)
        REFERENCES Seats(FlightID, SeatNo),

    FOREIGN KEY (PassengerID)
        REFERENCES Passengers(PassengerID),

    UNIQUE (FlightID, SeatNo),
    CHECK (Fare > 0)
);
GO
--insert values
INSERT INTO Flights VALUES
(201, 'Chennai to Delhi'),
(202, 'Chennai to Mumbai');

INSERT INTO Passengers VALUES
(1, 'Arjun'),
(2, 'Priya'),
(3, 'Kavin'),
(4, 'Meena'),
(5, 'Divya');

INSERT INTO Seats VALUES
(201, '1A', 'Available'),
(201, '1B', 'Booked'),
(201, '1C', 'Booked'),
(201, '1D', 'Booked'),
(201, '1E', 'Available'),
(202, '2A', 'Available'),
(202, '2B', 'Booked'),
(202, '2C', 'Booked');

INSERT INTO Bookings
(FlightID, SeatNo, PassengerID, Fare)
VALUES
(201, '1B', 1, 6000),
(201, '1C', 2, 6000),
(201, '1D', 3, 5000),
(202, '2B', 1, 7500),
(202, '2C', 4, 7000);
GO

SELECT * FROM Flights;
SELECT * FROM Passengers;
SELECT * FROM Seats;
SELECT * FROM Bookings;


----------------------------------------- Task 1 : Booking transaction ------------------------------------------------------------------------

DECLARE @FlightID INT = 201;
DECLARE @SeatNo VARCHAR(10) = '1A';
DECLARE @PassengerID INT = 5;
DECLARE @Fare DECIMAL(10,2) = 7000;
DECLARE @SeatStatus VARCHAR(20);

SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRAN;

    SELECT @SeatStatus = SeatStatus
    FROM Seats WITH (UPDLOCK, HOLDLOCK)
    WHERE FlightID = @FlightID
      AND SeatNo = @SeatNo;

    IF @SeatStatus IS NULL
        THROW 50001, 'Seat does not exist.', 1;

    IF @SeatStatus <> 'Available'
        THROW 50002, 'Seat is already booked.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Passengers
        WHERE PassengerID = @PassengerID
    )
        THROW 50003, 'Passenger does not exist.', 1;

    UPDATE Seats
    SET SeatStatus = 'Booked'
    WHERE FlightID = @FlightID
      AND SeatNo = @SeatNo
      AND SeatStatus = 'Available';

    IF @@ROWCOUNT = 0
        THROW 50004, 'Seat booking failed.', 1;

    INSERT INTO Bookings
    (FlightID, SeatNo, PassengerID, Fare)
    VALUES
    (@FlightID, @SeatNo, @PassengerID, @Fare);

    COMMIT TRAN;

    PRINT 'Booking successful.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRAN;

    PRINT 'Booking failed: ' + ERROR_MESSAGE();

    THROW;

END CATCH;
go
SELECT * FROM Seats
WHERE FlightID = 201 AND SeatNo = '1A';

SELECT * FROM Bookings
WHERE FlightID = 201 AND SeatNo = '1A';

-------------------------------- Task 3 : Rank() and Dense_rank() -----------------------------------------------------------------------------
SELECT
    f.FlightID,
    f.FlightName,
    p.PassengerName,
    b.Fare,

    RANK() OVER
    (
        PARTITION BY b.FlightID
        ORDER BY b.Fare DESC
    ) AS FareRank,

    DENSE_RANK() OVER
    (
        PARTITION BY b.FlightID
        ORDER BY b.Fare DESC
    ) AS DenseFareRank

FROM Bookings b
JOIN Passengers p
    ON b.PassengerID = p.PassengerID
JOIN Flights f
    ON b.FlightID = f.FlightID

ORDER BY
    b.FlightID,
    b.Fare DESC;
GO


---------------------------------------------------- Task 4 : Running total using CTE  ----------------------------------------------------------
WITH BookingDetails AS
(
    SELECT
        f.FlightID,
        f.FlightName,
        p.PassengerName,
        b.BookingID,
        b.Fare
    FROM Bookings b
    JOIN Passengers p
        ON b.PassengerID = p.PassengerID
    JOIN Flights f
        ON b.FlightID = f.FlightID
),
RankedBookings AS
(
    SELECT
        FlightID,
        FlightName,
        PassengerName,
        BookingID,
        Fare,

        RANK() OVER
        (
            PARTITION BY FlightID
            ORDER BY Fare DESC
        ) AS FareRank,

        DENSE_RANK() OVER
        (
            PARTITION BY FlightID
            ORDER BY Fare DESC
        ) AS DenseFareRank,

        SUM(Fare) OVER
        (
            PARTITION BY FlightID
            ORDER BY BookingID
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RunningRevenue

    FROM BookingDetails
)
SELECT
    FlightID,
    FlightName,
    PassengerName,
    Fare,
    FareRank,
    DenseFareRank,
    RunningRevenue
FROM RankedBookings
ORDER BY FlightID, BookingID;
GO