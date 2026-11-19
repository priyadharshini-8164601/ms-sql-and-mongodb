
# Day 8 – Set 2: Airline Seat Booking

## Business Scenario

An airline booking system must reserve seats and store passenger booking details safely. If two customers try to book the same seat, only one booking should be successful.

## Files Included

| File Name | Description |
|---|---|
| booking_transaction.sql | Performs seat booking using SQL transactions and handles errors. |
| ranking_report.sql | Generates passenger fare rankings and running revenue reports using window functions and CTEs. |
| booking_txn.js | Implements seat booking using MongoDB multi-document transactions. |

## Tasks Performed

### 1. Seat Booking Using SQL Transactions

Created Flights, Seats and Bookings tables and inserted sample flight and seat details.

Implemented the booking process using:
- BEGIN TRANSACTION
- COMMIT TRANSACTION
- ROLLBACK TRANSACTION
- TRY...CATCH
- THROW

Checked seat availability before booking.

Updated the seat status and inserted passenger booking details within the same transaction.

Used a unique constraint on FlightID and SeatNo to prevent duplicate bookings.

### 2. Simultaneous Booking Using Two Sessions

Tested two customers attempting to book the same seat using two SQL Server sessions.

**READ COMMITTED:**

Session 1 and Session 2 initially check the availability of the same seat.

Session 1 updates the seat status and inserts the booking record. After Session 1 commits, Session 2 attempts to update the same seat.

Since the seat is already booked, Session 2 cannot update it and the booking is rolled back.

**SERIALIZABLE:**

Session 1 starts a transaction and checks seat availability using SERIALIZABLE isolation.

Session 2 attempts to access the same seat while Session 1 holds its transaction.

Session 2 waits until Session 1 completes. After Session 1 commits, Session 2 finds that the seat is already booked.

Therefore, only one customer successfully books the seat.

#### Two-Session Testing

For READ COMMITTED, use an available seat such as A3.

**Session 1:**

```sql
USE AirlineBookingDB;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT *
FROM dbo.Seats
WHERE FlightID = 101 AND SeatNo = 'A3';

-- Execute the Session 2 SELECT before continuing.

UPDATE dbo.Seats
SET SeatStatus = 'Booked'
WHERE FlightID = 101
AND SeatNo = 'A3'
AND SeatStatus = 'Available';

INSERT INTO dbo.Bookings
(PassengerName, FlightID, SeatNo, Fare)
VALUES ('Arun', 101, 'A3', 4500);

COMMIT TRANSACTION;
```

**Session 2:**

```sql
USE AirlineBookingDB;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRANSACTION;

SELECT *
FROM dbo.Seats
WHERE FlightID = 101 AND SeatNo = 'A3';

UPDATE dbo.Seats
SET SeatStatus = 'Booked'
WHERE FlightID = 101
AND SeatNo = 'A3'
AND SeatStatus = 'Available';

IF @@ROWCOUNT = 0
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Seat already booked.';
END
ELSE
BEGIN
    INSERT INTO dbo.Bookings
    (PassengerName, FlightID, SeatNo, Fare)
    VALUES ('Priya', 101, 'A3', 4500);

    COMMIT TRANSACTION;
END;
```

Run the initial SELECT statements in both sessions before allowing Session 1 to update and commit.

For SERIALIZABLE, repeat the test using another available seat, such as B2. Use the following transaction in Session 1 and Session 2, changing the passenger name.

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

SELECT *
FROM dbo.Seats
WHERE FlightID = 101 AND SeatNo = 'B2';

UPDATE dbo.Seats
SET SeatStatus = 'Booked'
WHERE FlightID = 101
AND SeatNo = 'B2'
AND SeatStatus = 'Available';

IF @@ROWCOUNT = 1
BEGIN
    INSERT INTO dbo.Bookings
    (PassengerName, FlightID, SeatNo, Fare)
    VALUES ('Kavin', 101, 'B2', 4500);

    COMMIT TRANSACTION;
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
END;
```

Run Session 1 first and keep its transaction open after the SELECT. Start Session 2 and execute its SELECT. Session 2 waits until Session 1 completes.

### 3. Passenger Ranking Using Window Functions

Generated a passenger fare ranking report for each flight.

Used:

- RANK(): Assigns ranks based on passenger fares.
- DENSE_RANK(): Assigns ranks without skipping positions after ties.
- PARTITION BY: Separates passenger rankings flight-wise.

Compared RANK() and DENSE_RANK() using passengers with equal fares.

### 4. CTE and Running Revenue

Created a CTE-based passenger ranking report.

Used SUM() OVER() to calculate the running total of revenue for each flight.

Also used ROW_NUMBER() with PARTITION BY to identify the top three passengers based on fare for each flight.

### 5. MongoDB Multi-Document Transactions

Implemented the airline booking scenario using MongoDB 8.0.

Created seats and bookings collections.

Used:
- startSession()
- startTransaction()
- updateOne()
- insertOne()
- commitTransaction()
- abortTransaction()
- endSession()

Updated the seat status and inserted the passenger booking document within a single transaction.

If the seat is unavailable or the update fails, the transaction is aborted.

## Technologies Used

- Microsoft SQL Server 2025
- SQL Server Management Studio
- MongoDB 8.0
- MongoDB Shell (mongosh)

## Conclusion

Completed the airline seat booking scenario using SQL Server transactions and MongoDB multi-document transactions.

Demonstrated concurrent seat booking, transaction isolation, passenger fare ranking, CTEs and running revenue calculations.
