
IF DB_ID('AirlineBookingDB') IS NULL
    CREATE DATABASE AirlineBookingDB;
GO

USE AirlineBookingDB;
GO

IF OBJECT_ID('dbo.Bookings', 'U') IS NOT NULL
    DROP TABLE dbo.Bookings;

IF OBJECT_ID('dbo.Seats', 'U') IS NOT NULL
    DROP TABLE dbo.Seats;

IF OBJECT_ID('dbo.Flights', 'U') IS NOT NULL
    DROP TABLE dbo.Flights;
GO

CREATE TABLE dbo.Flights
(
    FlightID INT PRIMARY KEY,
    FlightName VARCHAR(100),
    Source VARCHAR(100),
    Destination VARCHAR(100)
);

CREATE TABLE dbo.Seats
(
    FlightID INT,
    SeatNo VARCHAR(10),
    SeatStatus VARCHAR(20) DEFAULT 'Available',
    PRIMARY KEY (FlightID, SeatNo),
    FOREIGN KEY (FlightID) REFERENCES dbo.Flights(FlightID),
    CHECK (SeatStatus IN ('Available', 'Booked'))
);

CREATE TABLE dbo.Bookings
(
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    PassengerName VARCHAR(100),
    FlightID INT,
    SeatNo VARCHAR(10),
    Fare DECIMAL(10,2),
    BookingDate DATETIME2 DEFAULT SYSDATETIME(),

    FOREIGN KEY (FlightID, SeatNo)
        REFERENCES dbo.Seats(FlightID, SeatNo),

    UNIQUE (FlightID, SeatNo)
);
GO

INSERT INTO dbo.Flights
VALUES
(101, 'Air India AI101', 'Chennai', 'Delhi'),
(102, 'IndiGo 6E202', 'Coimbatore', 'Bangalore');

INSERT INTO dbo.Seats (FlightID, SeatNo)
VALUES
(101, 'A1'), (101, 'A2'), (101, 'A3'),
(101, 'B1'), (101, 'B2'),
(102, 'A1'), (102, 'A2'), (102, 'B1');
GO

SELECT * FROM dbo.Flights;
SELECT * FROM dbo.Seats;
GO

DECLARE @PassengerName VARCHAR(100) = 'Priya';
DECLARE @FlightID INT = 101;
DECLARE @SeatNo VARCHAR(10) = 'A1';
DECLARE @Fare DECIMAL(10,2) = 4500.00;

BEGIN TRY

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    BEGIN TRANSACTION;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Seats WITH (UPDLOCK, HOLDLOCK)
        WHERE FlightID = @FlightID
          AND SeatNo = @SeatNo
          AND SeatStatus = 'Available'
    )
        THROW 50001, 'Seat is not available.', 1;

    UPDATE dbo.Seats
    SET SeatStatus = 'Booked'
    WHERE FlightID = @FlightID
      AND SeatNo = @SeatNo
      AND SeatStatus = 'Available';

    IF @@ROWCOUNT = 0
        THROW 50002, 'Seat booking failed.', 1;

    INSERT INTO dbo.Bookings
    (PassengerName, FlightID, SeatNo, Fare)
    VALUES
    (@PassengerName, @FlightID, @SeatNo, @Fare);

    COMMIT TRANSACTION;

    PRINT 'Seat booked successfully.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;
GO

SELECT * FROM dbo.Seats;

SELECT * FROM dbo.Bookings;
GO

-- SERIALIZABLE ISOLATION TEST
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRY

    BEGIN TRANSACTION;

    DECLARE @PassengerName2 VARCHAR(100) = 'Arun';
    DECLARE @FlightID2 INT = 101;
    DECLARE @SeatNo2 VARCHAR(10) = 'A2';
    DECLARE @Fare2 DECIMAL(10,2) = 4500.00;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Seats
        WHERE FlightID = @FlightID2
          AND SeatNo = @SeatNo2
          AND SeatStatus = 'Available'
    )
        THROW 50003, 'Seat is already booked.', 1;

    UPDATE dbo.Seats
    SET SeatStatus = 'Booked'
    WHERE FlightID = @FlightID2
      AND SeatNo = @SeatNo2
      AND SeatStatus = 'Available';

    IF @@ROWCOUNT = 0
        THROW 50004, 'Seat booking failed.', 1;

    INSERT INTO dbo.Bookings
    (PassengerName, FlightID, SeatNo, Fare)
    VALUES
    (@PassengerName2, @FlightID2, @SeatNo2, @Fare2);

    COMMIT TRANSACTION;

    PRINT 'Seat booked successfully under SERIALIZABLE isolation.';

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();

    THROW;

END CATCH;
GO

SELECT * FROM dbo.Seats;
SELECT * FROM dbo.Bookings;
GO
