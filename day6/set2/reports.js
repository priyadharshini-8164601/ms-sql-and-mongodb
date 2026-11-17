// 1. Select database
use("InsuranceDB");

// 2. Clear existing collection
db.getCollection("claims-notes").deleteMany({});

// 3. Insert sample claim notes
db.getCollection("claims-notes").insertMany([

    {
        claimId: 501,
        customerName: "Asha",
        claimStatus: "Settled",
        damageCategory: "Vehicle Damage",
        claimAmount: 3000,
        filedAt: ISODate("2025-02-10"),
        settledAt: ISODate("2025-02-20")
    },

    {
        claimId: 502,
        customerName: "Ravi",
        claimStatus: "Settled",
        damageCategory: "Medical",
        claimAmount: 8000,
        filedAt: ISODate("2025-03-10"),
        settledAt: ISODate("2025-03-25")
    },

    {
        claimId: 503,
        customerName: "Meena",
        claimStatus: "Approved",
        damageCategory: "Water Damage",
        claimAmount: 4500,
        filedAt: ISODate("2025-04-05"),
        settledAt: null
    },

    {
        claimId: 504,
        customerName: "Karthik",
        claimStatus: "Settled",
        damageCategory: "Medical",
        claimAmount: 20000,
        filedAt: ISODate("2025-05-10"),
        settledAt: ISODate("2025-06-10")
    },

    {
        claimId: 505,
        customerName: "Divya",
        claimStatus: "Settled",
        damageCategory: "Vehicle Damage",
        claimAmount: 6000,
        filedAt: ISODate("2025-05-15"),
        settledAt: ISODate("2025-05-25")
    },

    {
        claimId: 506,
        customerName: "Arun",
        claimStatus: "Pending",
        damageCategory: "Vehicle Damage",
        claimAmount: 2000,
        filedAt: ISODate("2025-06-01"),
        settledAt: null
    },

    {
        claimId: 507,
        customerName: "Nila",
        claimStatus: "Settled",
        damageCategory: "Travel Damage",
        claimAmount: 1500,
        filedAt: ISODate("2025-07-01"),
        settledAt: ISODate("2025-07-06")
    },

    {
        claimId: 508,
        customerName: "Vijay",
        claimStatus: "Settled",
        damageCategory: "Water Damage",
        claimAmount: 7000,
        filedAt: ISODate("2025-08-01"),
        settledAt: ISODate("2025-08-21")
    }

]);

// ==========================================
// PIPELINE 1: CLAIMS PER STATUS
// ==========================================

db.getCollection("claims-notes").aggregate([

    {
        $match: {
            claimStatus: {
                $in: ["Settled", "Pending", "Approved"]
            }
        }
    },

    {
        $group: {
            _id: "$claimStatus",
            totalClaims: {
                $sum: 1
            },
            totalClaimAmount: {
                $sum: "$claimAmount"
            }
        }
    },

    {
        $sort: {
            totalClaims: -1
        }
    },

    {
        $project: {
            _id: 0,
            claimStatus: "$_id",
            totalClaims: 1,
            totalClaimAmount: 1
        }
    }

]);

// ==========================================
// PIPELINE 2: AVERAGE SETTLEMENT TIME
// ==========================================

db.getCollection("claims-notes").aggregate([

    {
        $match: {
            settledAt: {
                $ne: null
            }
        }
    },

    {
        $project: {
            claimId: 1,
            settlementDays: {
                $dateDiff: {
                    startDate: "$filedAt",
                    endDate: "$settledAt",
                    unit: "day"
                }
            }
        }
    },

    {
        $group: {
            _id: null,
            averageSettlementDays: {
                $avg: "$settlementDays"
            },
            totalSettledClaims: {
                $sum: 1
            }
        }
    },

    {
        $sort: {
            averageSettlementDays: -1
        }
    },

    {
        $project: {
            _id: 0,
            averageSettlementDays: {
                $round: ["$averageSettlementDays", 2]
            },
            totalSettledClaims: 1
        }
    }

]);

// ==========================================
// PIPELINE 3: TOP 3 DAMAGE CATEGORIES
// ==========================================

db.getCollection("claims-notes").aggregate([

    {
        $match: {
            damageCategory: {
                $exists: true,
                $ne: null
            }
        }
    },

    {
        $group: {
            _id: "$damageCategory",
            totalClaims: {
                $sum: 1
            },
            totalClaimAmount: {
                $sum: "$claimAmount"
            }
        }
    },

    {
        $sort: {
            totalClaims: -1,
            _id: 1
        }
    },

    {
        $limit: 3
    },

    {
        $project: {
            _id: 0,
            damageCategory: "$_id",
            totalClaims: 1,
            totalClaimAmount: 1
        }
    }

]);