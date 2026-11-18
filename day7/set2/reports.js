use("BankLoanDB");

// =========================================================
// 1. INSERT SAMPLE DATA
// =========================================================

db.branches.insertMany([
    { branch_id: 1, branch_name: "Chennai Main Branch", city: "Chennai" },
    { branch_id: 2, branch_name: "Coimbatore Branch", city: "Coimbatore" },
    { branch_id: 3, branch_name: "Bangalore Branch", city: "Bangalore" },
    { branch_id: 4, branch_name: "Madurai Branch", city: "Madurai" },
    { branch_id: 5, branch_name: "Salem Branch", city: "Salem" }
]);

db.customers.insertMany([
    { customer_id: 101, customer_name: "Arun", city: "Chennai" },
    { customer_id: 102, customer_name: "Priya", city: "Coimbatore" },
    { customer_id: 103, customer_name: "Karthik", city: "Bangalore" },
    { customer_id: 104, customer_name: "Divya", city: "Madurai" },
    { customer_id: 105, customer_name: "Rahul", city: "Chennai" },
    { customer_id: 106, customer_name: "Meena", city: "Salem" },
    { customer_id: 107, customer_name: "Suresh", city: "Coimbatore" }
]);

db.loans.insertMany([
    {
        loan_id: 1001, customer_id: 101, branch_id: 1,
        loan_amount: 500000, loan_date: ISODate("2026-01-10")
    },
    {
        loan_id: 1002, customer_id: 102, branch_id: 2,
        loan_amount: 300000, loan_date: ISODate("2026-02-15")
    },
    {
        loan_id: 1003, customer_id: 101, branch_id: 2,
        loan_amount: 700000, loan_date: ISODate("2026-03-01")
    },
    {
        loan_id: 1004, customer_id: 103, branch_id: 3,
        loan_amount: 900000, loan_date: ISODate("2026-01-20")
    },
    {
        loan_id: 1005, customer_id: 104, branch_id: 1,
        loan_amount: 400000, loan_date: ISODate("2026-04-10")
    },
    {
        loan_id: 1006, customer_id: 105, branch_id: 3,
        loan_amount: 600000, loan_date: ISODate("2026-02-20")
    },
    {
        loan_id: 1007, customer_id: 106, branch_id: 2,
        loan_amount: 250000, loan_date: ISODate("2026-05-01")
    },
    {
        loan_id: 1008, customer_id: 107, branch_id: 4,
        loan_amount: 800000, loan_date: ISODate("2026-03-15")
    },
    {
        loan_id: 1009, customer_id: 103, branch_id: 1,
        loan_amount: 350000, loan_date: ISODate("2026-06-10")
    }
]);

db.repayments.insertMany([
    {
        repayment_id: 1, loan_id: 1001,
        repayment_amount: 20000,
        repayment_date: ISODate("2026-09-10")
    },
    {
        repayment_id: 2, loan_id: 1001,
        repayment_amount: 20000,
        repayment_date: ISODate("2026-10-10")
    },
    {
        repayment_id: 3, loan_id: 1002,
        repayment_amount: 15000,
        repayment_date: ISODate("2026-11-01")
    },
    {
        repayment_id: 4, loan_id: 1003,
        repayment_amount: 25000,
        repayment_date: ISODate("2026-08-01")
    },
    {
        repayment_id: 5, loan_id: 1004,
        repayment_amount: 30000,
        repayment_date: ISODate("2026-10-20")
    },
    {
        repayment_id: 6, loan_id: 1005,
        repayment_amount: 18000,
        repayment_date: ISODate("2026-07-10")
    },
    {
        repayment_id: 7, loan_id: 1006,
        repayment_amount: 22000,
        repayment_date: ISODate("2026-11-05")
    },
    {
        repayment_id: 8, loan_id: 1007,
        repayment_amount: 12000,
        repayment_date: ISODate("2026-09-15")
    },
    {
        repayment_id: 9, loan_id: 1008,
        repayment_amount: 28000,
        repayment_date: ISODate("2026-10-25")
    }
]);

db.guarantors.insertMany([
    { guarantor_id: 1, loan_id: 1001, customer_id: 102 },
    { guarantor_id: 2, loan_id: 1002, customer_id: 101 },
    { guarantor_id: 3, loan_id: 1003, customer_id: 103 },
    { guarantor_id: 4, loan_id: 1004, customer_id: 105 },
    { guarantor_id: 5, loan_id: 1005, customer_id: 101 },
    { guarantor_id: 6, loan_id: 1006, customer_id: 104 },
    { guarantor_id: 7, loan_id: 1007, customer_id: 107 }
]);

// =========================================================
// 2. PIPELINE 1
// LOANS WITH CUSTOMER DETAILS
// =========================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "customer_id",
            foreignField: "customer_id",
            as: "customer_details"
        }
    },
    {
        $unwind: "$customer_details"
    },
    {
        $project: {
            _id: 0,
            loan_id: 1,
            loan_amount: 1,
            branch_id: 1,
            customer_name: "$customer_details.customer_name",
            customer_city: "$customer_details.city"
        }
    }
]);

// =========================================================
// 3. PIPELINE 2
// LOANS WITH REPAYMENT DETAILS
// =========================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "repayments",
            localField: "loan_id",
            foreignField: "loan_id",
            as: "repayment_details"
        }
    },
    {
        $project: {
            _id: 0,
            loan_id: 1,
            loan_amount: 1,
            repayment_details: 1,
            total_repaid: {
                $sum: "$repayment_details.repayment_amount"
            }
        }
    }
]);

// =========================================================
// 4. PIPELINE 3
// LOANS WITH CUSTOMER DETAILS AND LAST REPAYMENT
// =========================================================

db.loans.aggregate([
    {
        $lookup: {
            from: "customers",
            localField: "customer_id",
            foreignField: "customer_id",
            as: "customer_details"
        }
    },
    {
        $lookup: {
            from: "repayments",
            let: { currentLoanId: "$loan_id" },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$loan_id", "$$currentLoanId"]
                        }
                    }
                },
                {
                    $sort: {
                        repayment_date: -1
                    }
                },
                {
                    $limit: 1
                }
            ],
            as: "last_repayment"
        }
    },
    {
        $unwind: {
            path: "$customer_details",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            loan_id: 1,
            loan_amount: 1,
            customer_name: "$customer_details.customer_name",
            last_repayment: {
                $arrayElemAt: ["$last_repayment", 0]
            }
        }
    }
]);

// =========================================================
// END OF BANK LOAN PORTFOLIO
// =========================================================
