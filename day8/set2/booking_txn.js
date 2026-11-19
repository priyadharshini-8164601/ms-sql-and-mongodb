
use AirlineBookingDB

db.seats.insertMany([
    {
        flightId: 101,
        seatNo: "A1",
        seatStatus: "Available"
    },
    {
        flightId: 101,
        seatNo: "A2",
        seatStatus: "Available"
    },
    {
        flightId: 102,
        seatNo: "B1",
        seatStatus: "Available"
    }
])

const session = db.getMongo().startSession()

const airlineDB = session.getDatabase("AirlineBookingDB")

session.startTransaction()

const flightId = 101
const seatNo = "A1"
const passengerName = "Priya"
const fare = 4500

const seat = airlineDB.seats.findOne({
    flightId: flightId,
    seatNo: seatNo,
    seatStatus: "Available"
})

if (seat) {

    const result = airlineDB.seats.updateOne(
        {
            flightId: flightId,
            seatNo: seatNo,
            seatStatus: "Available"
        },
        {
            $set: {
                seatStatus: "Booked"
            }
        }
    )

    if (result.modifiedCount === 1) {

        airlineDB.bookings.insertOne({
            passengerName: passengerName,
            flightId: flightId,
            seatNo: seatNo,
            fare: fare,
            bookingDate: new Date()
        })

        session.commitTransaction()

        print("Seat booked successfully.")

    } else {

        session.abortTransaction()

        print("Seat is already booked.")

    }

} else {

    session.abortTransaction()

    print("Selected seat is not available.")

}

session.endSession()

db.seats.find().pretty()

db.bookings.find().pretty()
