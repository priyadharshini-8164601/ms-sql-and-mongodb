
use("RetailOrderDB");


db.orders.insertMany([
    {
        orderId: 1001,
        customerId: 1,
        orderDate: new Date(),
        status: "Pending",
        totalAmount: 800
    },
    {
        orderId: 1002,
        customerId: 2,
        orderDate: new Date(),
        status: "Pending",
        totalAmount: 1500
    },
    {
        orderId: 1003,
        customerId: 3,
        orderDate: new Date(),
        status: "Processing",
        totalAmount: 45000
    },
    {
        orderId: 1004,
        customerId: 4,
        orderDate: new Date(),
        status: "Delivered",
        totalAmount: 9500
    },
    {
        orderId: 1005,
        customerId: 5,
        orderDate: new Date(),
        status: "Delivered",
        totalAmount: 35000
    },
    {
        orderId: 1006,
        customerId: 1,
        orderDate: new Date(),
        status: "Cancelled",
        totalAmount: 2000
    }
]);


db.createView(
    "order_status_counts",
    "orders",
    [
        {
            $group: {
                _id: "$status",
                totalOrders: { $sum: 1 },
                totalOrderValue: { $sum: "$totalAmount" }
            }
        },
        {
            $project: {
                _id: 0,
                orderStatus: "$_id",
                totalOrders: 1,
                totalOrderValue: 1
            }
        },
        {
            $sort: {
                orderStatus: 1
            }
        }
    ]
);

db.order_status_counts.find();

db.order_status_counts.find({
    orderStatus: "Pending"
});

db.order_status_counts.find().pretty();

