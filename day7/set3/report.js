use("RetailReturnsDB");

// =========================================================
// 1. INSERT SAMPLE DATA
// =========================================================

db.stores.insertMany([
    { store_id: 1, store_name: "Chennai Central Store", city: "Chennai", region: "South" },
    { store_id: 2, store_name: "Coimbatore Store", city: "Coimbatore", region: "South" },
    { store_id: 3, store_name: "Bangalore Store", city: "Bangalore", region: "South" },
    { store_id: 4, store_name: "Mumbai Store", city: "Mumbai", region: "West" },
    { store_id: 5, store_name: "Delhi Store", city: "Delhi", region: "North" }
]);

db.customers.insertMany([
    { customer_id: 101, customer_name: "Arun", city: "Chennai" },
    { customer_id: 102, customer_name: "Priya", city: "Coimbatore" },
    { customer_id: 103, customer_name: "Karthik", city: "Bangalore" },
    { customer_id: 104, customer_name: "Divya", city: "Mumbai" },
    { customer_id: 105, customer_name: "Rahul", city: "Delhi" },
    { customer_id: 106, customer_name: "Meena", city: "Chennai" }
]);

db.products.insertMany([
    { product_id: 1, product_name: "Laptop", category: "Electronics", price: 50000 },
    { product_id: 2, product_name: "Mobile", category: "Electronics", price: 20000 },
    { product_id: 3, product_name: "Headphones", category: "Accessories", price: 3000 },
    { product_id: 4, product_name: "Keyboard", category: "Accessories", price: 1500 },
    { product_id: 5, product_name: "Monitor", category: "Electronics", price: 12000 },
    { product_id: 6, product_name: "Mouse", category: "Accessories", price: 800 },
    { product_id: 7, product_name: "Printer", category: "Electronics", price: 15000 }
]);

db.sales.insertMany([
    { sale_id: 1001, customer_id: 101, product_id: 1, store_id: 1, quantity: 2 },
    { sale_id: 1002, customer_id: 102, product_id: 2, store_id: 2, quantity: 3 },
    { sale_id: 1003, customer_id: 103, product_id: 3, store_id: 3, quantity: 5 },
    { sale_id: 1004, customer_id: 104, product_id: 1, store_id: 4, quantity: 1 },
    { sale_id: 1005, customer_id: 105, product_id: 4, store_id: 5, quantity: 4 },
    { sale_id: 1006, customer_id: 101, product_id: 2, store_id: 1, quantity: 2 },
    { sale_id: 1007, customer_id: 102, product_id: 5, store_id: 2, quantity: 2 },
    { sale_id: 1008, customer_id: 103, product_id: 6, store_id: 3, quantity: 5 },
    { sale_id: 1009, customer_id: 104, product_id: 3, store_id: 4, quantity: 2 },
    { sale_id: 1010, customer_id: 106, product_id: 4, store_id: 1, quantity: 3 },
    { sale_id: 1011, customer_id: 105, product_id: 7, store_id: 5, quantity: 1 },
    { sale_id: 1012, customer_id: 106, product_id: 5, store_id: 1, quantity: 1 }
]);

db.returns.insertMany([
    { return_id: 501, sale_id: 1001, customer_id: 101, product_id: 1, store_id: 1, return_reason: "Damaged product" },
    { return_id: 502, sale_id: 1002, customer_id: 102, product_id: 2, store_id: 2, return_reason: "Wrong item" },
    { return_id: 503, sale_id: 1003, customer_id: 103, product_id: 3, store_id: 3, return_reason: "Not satisfied" },
    { return_id: 504, sale_id: 1004, customer_id: 104, product_id: 1, store_id: 4, return_reason: "Defective product" },
    { return_id: 505, sale_id: 1005, customer_id: 105, product_id: 4, store_id: 5, return_reason: "Wrong size" },
    { return_id: 506, sale_id: 1006, customer_id: 101, product_id: 2, store_id: 1, return_reason: "Damaged product" },
    { return_id: 507, sale_id: 1008, customer_id: 103, product_id: 6, store_id: 3, return_reason: "Poor quality" },
    { return_id: 508, sale_id: 1010, customer_id: 106, product_id: 4, store_id: 1, return_reason: "Wrong item" }
]);

db.refunds.insertMany([
    { refund_id: 701, return_id: 501, refund_amount: 100000 },
    { refund_id: 702, return_id: 502, refund_amount: 60000 },
    { refund_id: 703, return_id: 503, refund_amount: 15000 },
    { refund_id: 704, return_id: 504, refund_amount: 50000 },
    { refund_id: 705, return_id: 505, refund_amount: 6000 },
    { refund_id: 706, return_id: 507, refund_amount: 4000 }
]);

db.returnFeedback.insertMany([
    { feedback_id: 801, return_id: 501, feedback_text: "Product arrived damaged", rating: 2 },
    { feedback_id: 802, return_id: 502, feedback_text: "Received incorrect product", rating: 3 },
    { feedback_id: 803, return_id: 503, feedback_text: "Product quality was poor", rating: 2 },
    { feedback_id: 804, return_id: 504, feedback_text: "Refund processed successfully", rating: 4 },
    { feedback_id: 805, return_id: 505, feedback_text: "Return process was easy", rating: 5 },
    { feedback_id: 806, return_id: 506, feedback_text: "Waiting for refund", rating: 2 },
    { feedback_id: 807, return_id: 507, feedback_text: "Good customer support", rating: 4 }
]);

// =========================================================
// 2. PIPELINE 1
// RETURNS WITH CUSTOMER AND PRODUCT DETAILS
// =========================================================

db.returns.aggregate([
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
            from: "products",
            localField: "product_id",
            foreignField: "product_id",
            as: "product_details"
        }
    },
    {
        $lookup: {
            from: "returnFeedback",
            localField: "return_id",
            foreignField: "return_id",
            as: "feedback_details"
        }
    },
    {
        $project: {
            _id: 0,
            return_id: 1,
            return_reason: 1,
            customer_details: 1,
            product_details: 1,
            feedback_details: 1
        }
    }
]);

// =========================================================
// 3. PIPELINE 2
// RETURNS WITH REFUND DETAILS
// =========================================================

db.returns.aggregate([
    {
        $lookup: {
            from: "refunds",
            localField: "return_id",
            foreignField: "return_id",
            as: "refund_details"
        }
    },
    {
        $project: {
            _id: 0,
            return_id: 1,
            customer_id: 1,
            product_id: 1,
            return_reason: 1,
            refund_details: 1,
            total_refund: {
                $sum: "$refund_details.refund_amount"
            }
        }
    }
]);

// =========================================================
// 4. PIPELINE 3
// STORES WITH RETURNS, REFUNDS AND FEEDBACK
// =========================================================

db.stores.aggregate([
    {
        $lookup: {
            from: "returns",
            localField: "store_id",
            foreignField: "store_id",
            as: "return_details"
        }
    },
    {
        $unwind: {
            path: "$return_details",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $lookup: {
            from: "refunds",
            localField: "return_details.return_id",
            foreignField: "return_id",
            as: "refund_details"
        }
    },
    {
        $lookup: {
            from: "returnFeedback",
            localField: "return_details.return_id",
            foreignField: "return_id",
            as: "feedback_details"
        }
    },
    {
        $group: {
            _id: {
                store_id: "$store_id",
                store_name: "$store_name",
                region: "$region"
            },
            total_returns: {
                $sum: {
                    $cond: [
                        { $ne: ["$return_details.return_id", null] },
                        1,
                        0
                    ]
                }
            },
            total_refunds: {
                $sum: {
                    $sum: "$refund_details.refund_amount"
                }
            },
            average_rating: {
                $avg: {
                    $arrayElemAt: ["$feedback_details.rating", 0]
                }
            },
            feedback_records: {
                $push: "$feedback_details"
            }
        }
    },
    {
        $project: {
            _id: 0,
            store_id: "$_id.store_id",
            store_name: "$_id.store_name",
            region: "$_id.region",
            total_returns: 1,
            total_refunds: 1,
            average_rating: 1,
            feedback_records: 1
        }
    }
]);

// =========================================================
// END OF RETAIL RETURNS AND REFUNDS
// =========================================================
