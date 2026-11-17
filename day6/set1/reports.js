// 1. Select database
use("RetailSalesDB");

// 2. Clear existing collections
db.customers.deleteMany({});
db.products.deleteMany({});
db.orders.deleteMany({});
db.payments.deleteMany({});

// 3. Insert customers
db.customers.insertMany([
    { _id: 1, customerName: "Asha", city: "Chennai" },
    { _id: 2, customerName: "Ravi", city: "Coimbatore" },
    { _id: 3, customerName: "Meena", city: "Chennai" },
    { _id: 4, customerName: "Karthik", city: "Madurai" },
    { _id: 5, customerName: "Divya", city: "Coimbatore" },
    { _id: 6, customerName: "Arun", city: "Salem" }
]);

// 4. Insert products
db.products.insertMany([
    { _id: 1, productName: "Laptop", category: "Electronics", price: 50000 },
    { _id: 2, productName: "Phone", category: "Electronics", price: 20000 },
    { _id: 3, productName: "Chair", category: "Furniture", price: 5000 },
    { _id: 4, productName: "Desk", category: "Furniture", price: 10000 },
    { _id: 5, productName: "Headphones", category: "Electronics", price: 2000 }
]);

// 5. Insert orders
db.orders.insertMany([
    {
        _id: 101,
        customerId: 1,
        customerName: "Asha",
        city: "Chennai",
        orderDate: ISODate("2025-01-05T10:00:00Z"),
        items: [
            { productId: 1, productName: "Laptop", category: "Electronics", quantity: 1, unitPrice: 50000 },
            { productId: 5, productName: "Headphones", category: "Electronics", quantity: 2, unitPrice: 2000 }
        ]
    },
    {
        _id: 102,
        customerId: 1,
        customerName: "Asha",
        city: "Chennai",
        orderDate: ISODate("2025-01-20T10:00:00Z"),
        items: [
            { productId: 2, productName: "Phone", category: "Electronics", quantity: 1, unitPrice: 20000 }
        ]
    },
    {
        _id: 103,
        customerId: 2,
        customerName: "Ravi",
        city: "Coimbatore",
        orderDate: ISODate("2025-01-21T10:00:00Z"),
        items: [
            { productId: 3, productName: "Chair", category: "Furniture", quantity: 2, unitPrice: 5000 }
        ]
    },
    {
        _id: 104,
        customerId: 2,
        customerName: "Ravi",
        city: "Coimbatore",
        orderDate: ISODate("2025-02-02T10:00:00Z"),
        items: [
            { productId: 2, productName: "Phone", category: "Electronics", quantity: 1, unitPrice: 20000 }
        ]
    },
    {
        _id: 105,
        customerId: 2,
        customerName: "Ravi",
        city: "Coimbatore",
        orderDate: ISODate("2025-02-15T10:00:00Z"),
        items: [
            { productId: 4, productName: "Desk", category: "Furniture", quantity: 1, unitPrice: 10000 }
        ]
    },
    {
        _id: 106,
        customerId: 2,
        customerName: "Ravi",
        city: "Coimbatore",
        orderDate: ISODate("2025-03-01T10:00:00Z"),
        items: [
            { productId: 5, productName: "Headphones", category: "Electronics", quantity: 3, unitPrice: 2000 }
        ]
    },
    {
        _id: 107,
        customerId: 3,
        customerName: "Meena",
        city: "Chennai",
        orderDate: ISODate("2025-02-10T10:00:00Z"),
        items: [
            { productId: 1, productName: "Laptop", category: "Electronics", quantity: 1, unitPrice: 50000 }
        ]
    },
    {
        _id: 108,
        customerId: 4,
        customerName: "Karthik",
        city: "Madurai",
        orderDate: ISODate("2025-03-05T10:00:00Z"),
        items: [
            { productId: 3, productName: "Chair", category: "Furniture", quantity: 1, unitPrice: 5000 }
        ]
    },
    {
        _id: 109,
        customerId: 5,
        customerName: "Divya",
        city: "Coimbatore",
        orderDate: ISODate("2025-03-06T10:00:00Z"),
        items: [
            { productId: 4, productName: "Desk", category: "Furniture", quantity: 2, unitPrice: 10000 }
        ]
    },
    {
        _id: 110,
        customerId: 5,
        customerName: "Divya",
        city: "Coimbatore",
        orderDate: ISODate("2025-03-07T10:00:00Z"),
        items: [
            { productId: 2, productName: "Phone", category: "Electronics", quantity: 1, unitPrice: 20000 }
        ]
    }
]);

// 6. Insert payments
db.payments.insertMany([
    { _id: 1, orderId: 101, amount: 54000, paymentDate: ISODate("2025-01-05T11:00:00Z") },
    { _id: 2, orderId: 102, amount: 20000, paymentDate: ISODate("2025-01-20T11:00:00Z") },
    { _id: 3, orderId: 103, amount: 10000, paymentDate: ISODate("2025-01-21T11:00:00Z") },
    { _id: 4, orderId: 104, amount: 20000, paymentDate: ISODate("2025-02-02T11:00:00Z") },
    { _id: 5, orderId: 105, amount: 10000, paymentDate: ISODate("2025-02-15T11:00:00Z") },
    { _id: 6, orderId: 106, amount: 6000, paymentDate: ISODate("2025-03-01T11:00:00Z") },
    { _id: 7, orderId: 107, amount: 50000, paymentDate: ISODate("2025-02-10T11:00:00Z") },
    { _id: 8, orderId: 109, amount: 20000, paymentDate: ISODate("2025-03-06T11:00:00Z") },
    { _id: 9, orderId: 110, amount: 20000, paymentDate: ISODate("2025-03-07T11:00:00Z") }
]);

// ==========================================
// AGGREGATION PIPELINE 1
// MONTH-WISE SALES
// ==========================================

db.orders.aggregate([
    {
        $match: {
            orderDate: {
                $gte: ISODate("2025-01-01T00:00:00Z"),
                $lt: ISODate("2025-04-01T00:00:00Z")
            }
        }
    },
    {
        $unwind: "$items"
    },
    {
        $group: {
            _id: {
                $dateToString: {
                    format: "%Y-%m",
                    date: "$orderDate"
                }
            },
            monthlySales: {
                $sum: {
                    $multiply: ["$items.quantity", "$items.unitPrice"]
                }
            }
        }
    },
    {
        $sort: { _id: 1 }
    },
    {
        $project: {
            _id: 0,
            month: "$_id",
            monthlySales: 1
        }
    }
]);

// ==========================================
// AGGREGATION PIPELINE 2
// TOP 5 PRODUCTS BY REVENUE
// ==========================================

db.orders.aggregate([
    {
        $unwind: "$items"
    },
    {
        $group: {
            _id: "$items.productName",
            totalQuantity: { $sum: "$items.quantity" },
            totalRevenue: {
                $sum: {
                    $multiply: ["$items.quantity", "$items.unitPrice"]
                }
            }
        }
    },
    {
        $sort: { totalRevenue: -1 }
    },
    {
        $limit: 5
    },
    {
        $project: {
            _id: 0,
            productName: "$_id",
            totalQuantity: 1,
            totalRevenue: 1
        }
    }
]);

// ==========================================
// AGGREGATION PIPELINE 3
// AVERAGE BASKET VALUE PER CITY
// ==========================================

db.orders.aggregate([
    {
        $project: {
            city: 1,
            orderTotal: {
                $sum: {
                    $map: {
                        input: "$items",
                        as: "item",
                        in: {
                            $multiply: [
                                "$$item.quantity",
                                "$$item.unitPrice"
                            ]
                        }
                    }
                }
            }
        }
    },
    {
        $group: {
            _id: "$city",
            averageBasketValue: { $avg: "$orderTotal" },
            totalOrders: { $sum: 1 }
        }
    },
    {
        $sort: { averageBasketValue: -1 }
    },
    {
        $project: {
            _id: 0,
            city: "$_id",
            averageBasketValue: {
                $round: ["$averageBasketValue", 2]
            },
            totalOrders: 1
        }
    }
]);