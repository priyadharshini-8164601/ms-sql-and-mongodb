
USE AirlineBookingDB;
GO

INSERT INTO dbo.Bookings
(PassengerName, FlightID, SeatNo, Fare)
VALUES
('Kavin', 101, 'A3', 5000),
('Divya', 101, 'B1', 4500),
('Rahul', 101, 'B2', 4500),
('Meena', 102, 'A1', 6000),
('Sanjay', 102, 'A2', 5500),
('Anu', 102, 'B1', 5500);
GO

-- Passenger ranking using RANK and DENSE_RANK

SELECT
    BookingID,
    PassengerName,
    FlightID,
    SeatNo,
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
    ) AS DenseFareRank

FROM dbo.Bookings
ORDER BY FlightID, Fare DESC;
GO

-- CTE-based passenger ranking and running revenue

;WITH PassengerRanking AS
(
    SELECT
        BookingID,
        PassengerName,
        FlightID,
        SeatNo,
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
            ORDER BY Fare DESC, BookingID
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS RunningRevenue

    FROM dbo.Bookings
)

SELECT
    BookingID,
    PassengerName,
    FlightID,
    SeatNo,
    Fare,
    FareRank,
    DenseFareRank,
    RunningRevenue

FROM PassengerRanking
ORDER BY FlightID, Fare DESC, BookingID;
GO

-- Top three passengers by fare in each flight

;WITH PassengerRanking AS
(
    SELECT
        PassengerName,
        FlightID,
        SeatNo,
        Fare,

        ROW_NUMBER() OVER
        (
            PARTITION BY FlightID
            ORDER BY Fare DESC, BookingID
        ) AS RowNumber

    FROM dbo.Bookings
)

SELECT
    PassengerName,
    FlightID,
    SeatNo,
    Fare,
    RowNumber

FROM PassengerRanking
WHERE RowNumber <= 3
ORDER BY FlightID, RowNumber;
GO
