
use BankManagementDB

db.createCollection("customerActivityLogs", {
    capped: true,
    size: 1048576,
    max: 1000
})



db.customerActivityLogs.insertMany(
    Array.from({ length: 20 }, (_, i) => ({
        customerId: i < 8 ? 1001 : 1002 + (i % 3),

        eventType: i < 8
            ? "login"
            : ["search", "transaction", "logout"][(i - 8) % 3],

        description: i < 8
            ? "Customer login activity"
            : "Customer activity event",

        timestamp: new Date(
            Date.now() - i * 60 * 60 * 1000
        )
    }))
)



db.customerActivityLogs.find().pretty()



db.customerActivityLogs.find({
    customerId: 1001,
    eventType: "login"
})
.sort({
    timestamp: -1
})
.limit(5)



db.customerActivityLogs.isCapped()

db.customerActivityLogs.stats()

