// 1. Select database
use("TelecomDB");

// 2. Clear existing collection
db.getCollection("usage-events").deleteMany({});

// 3. Insert usage events
db.getCollection("usage-events").insertMany([

    {
        eventId: 1,
        subscriberId: 1,
        cellTower: "Tower A",
        eventTime: ISODate("2025-01-15T08:15:00Z"),
        sessionDurationMinutes: 10,
        dataUsedMB: 100
    },

    {
        eventId: 2,
        subscriberId: 1,
        cellTower: "Tower A",
        eventTime: ISODate("2025-01-15T08:45:00Z"),
        sessionDurationMinutes: 20,
        dataUsedMB: 200
    },

    {
        eventId: 3,
        subscriberId: 2,
        cellTower: "Tower B",
        eventTime: ISODate("2025-01-15T09:10:00Z"),
        sessionDurationMinutes: 15,
        dataUsedMB: 150
    },

    {
        eventId: 4,
        subscriberId: 3,
        cellTower: "Tower A",
        eventTime: ISODate("2025-01-15T09:30:00Z"),
        sessionDurationMinutes: 30,
        dataUsedMB: 500
    },

    {
        eventId: 5,
        subscriberId: 4,
        cellTower: "Tower C",
        eventTime: ISODate("2025-01-15T10:05:00Z"),
        sessionDurationMinutes: 5,
        dataUsedMB: 50
    },

    {
        eventId: 6,
        subscriberId: 5,
        cellTower: "Tower B",
        eventTime: ISODate("2025-01-15T10:45:00Z"),
        sessionDurationMinutes: 25,
        dataUsedMB: 300
    },

    {
        eventId: 7,
        subscriberId: 5,
        cellTower: "Tower B",
        eventTime: ISODate("2025-01-15T11:15:00Z"),
        sessionDurationMinutes: 35,
        dataUsedMB: 400
    },

    {
        eventId: 8,
        subscriberId: 3,
        cellTower: "Tower C",
        eventTime: ISODate("2025-01-15T11:50:00Z"),
        sessionDurationMinutes: 10,
        dataUsedMB: 100
    }

]);

// ==========================================
// PIPELINE 1: HOURLY USAGE
// ==========================================

db.getCollection("usage-events").aggregate([

    {
        $match: {
            eventTime: {
                $gte: ISODate("2025-01-15T00:00:00Z"),
                $lt: ISODate("2025-01-16T00:00:00Z")
            }
        }
    },

    {
        $group: {
            _id: {
                $dateToString: {
                    format: "%Y-%m-%d %H:00",
                    date: "$eventTime",
                    timezone: "UTC"
                }
            },

            totalEvents: {
                $sum: 1
            },

            totalDataUsedMB: {
                $sum: "$dataUsedMB"
            }
        }
    },

    {
        $sort: {
            _id: 1
        }
    },

    {
        $project: {
            _id: 0,
            hour: "$_id",
            totalEvents: 1,
            totalDataUsedMB: 1
        }
    }

]);

// ==========================================
// PIPELINE 2: AVERAGE SESSION LENGTH
// ==========================================

db.getCollection("usage-events").aggregate([

    {
        $match: {
            sessionDurationMinutes: {
                $ne: null
            }
        }
    },

    {
        $group: {
            _id: null,

            averageSessionLength: {
                $avg: "$sessionDurationMinutes"
            },

            totalSessions: {
                $sum: 1
            },

            totalSessionMinutes: {
                $sum: "$sessionDurationMinutes"
            }
        }
    },

    {
        $project: {
            _id: 0,

            averageSessionLength: {
                $round: ["$averageSessionLength", 2]
            },

            totalSessions: 1,
            totalSessionMinutes: 1
        }
    }

]);

// ==========================================
// PIPELINE 3: BUSIEST CELL TOWER
// ==========================================

db.getCollection("usage-events").aggregate([

    {
        $match: {
            cellTower: {
                $exists: true,
                $ne: null
            }
        }
    },

    {
        $group: {
            _id: "$cellTower",

            totalEvents: {
                $sum: 1
            },

            totalDataUsedMB: {
                $sum: "$dataUsedMB"
            }
        }
    },

    {
        $sort: {
            totalEvents: -1,
            _id: 1
        }
    },

    {
        $limit: 1
    },

    {
        $project: {
            _id: 0,
            cellTower: "$_id",
            totalEvents: 1,
            totalDataUsedMB: 1
        }
    }

]);