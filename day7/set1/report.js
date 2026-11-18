use("LogisticsDB");

// =========================================================
// 1. INSERT SAMPLE DATA
// =========================================================

db.hubs.insertMany([
    { hub_id: 1, hub_name: "Central Hub", city: "Chennai" },
    { hub_id: 2, hub_name: "North Hub", city: "Bangalore" },
    { hub_id: 3, hub_name: "South Hub", city: "Coimbatore" },
    { hub_id: 4, hub_name: "East Hub", city: "Hyderabad" },
    { hub_id: 5, hub_name: "West Hub", city: "Mumbai" }
]);

db.carriers.insertMany([
    { carrier_id: 1, carrier_name: "FastTrack Logistics" },
    { carrier_id: 2, carrier_name: "BlueDart Express" },
    { carrier_id: 3, carrier_name: "SpeedShip" }
]);

db.customers.insertMany([
    { customer_id: 1, customer_name: "Arun", city: "Chennai" },
    { customer_id: 2, customer_name: "Priya", city: "Coimbatore" },
    { customer_id: 3, customer_name: "Karthik", city: "Bangalore" },
    { customer_id: 4, customer_name: "Divya", city: "Hyderabad" },
    { customer_id: 5, customer_name: "Rahul", city: "Mumbai" }
]);

db.shipments.insertMany([
    {
        shipment_id: 1001,
        customer_id: 1,
        carrier_id: 1,
        origin_hub_id: 1,
        destination_hub_id: 2,
        shipping_cost: 500,
        expected_delivery_date: ISODate("2026-10-03"),
        actual_delivery_date: ISODate("2026-10-06")
    },
    {
        shipment_id: 1002,
        customer_id: 1,
        carrier_id: 2,
        origin_hub_id: 1,
        destination_hub_id: 3,
        shipping_cost: 700,
        expected_delivery_date: ISODate("2026-10-05"),
        actual_delivery_date: ISODate("2026-10-05")
    },
    {
        shipment_id: 1003,
        customer_id: 1,
        carrier_id: 1,
        origin_hub_id: 2,
        destination_hub_id: 4,
        shipping_cost: 900,
        expected_delivery_date: ISODate("2026-10-06"),
        actual_delivery_date: ISODate("2026-10-10")
    },
    {
        shipment_id: 1004,
        customer_id: 1,
        carrier_id: 3,
        origin_hub_id: 3,
        destination_hub_id: 5,
        shipping_cost: 600,
        expected_delivery_date: ISODate("2026-10-07"),
        actual_delivery_date: ISODate("2026-10-07")
    },
    {
        shipment_id: 1005,
        customer_id: 1,
        carrier_id: 2,
        origin_hub_id: 4,
        destination_hub_id: 1,
        shipping_cost: 800,
        expected_delivery_date: ISODate("2026-10-08"),
        actual_delivery_date: ISODate("2026-10-12")
    },
    {
        shipment_id: 1006,
        customer_id: 2,
        carrier_id: 1,
        origin_hub_id: 1,
        destination_hub_id: 2,
        shipping_cost: 450,
        expected_delivery_date: ISODate("2026-10-08"),
        actual_delivery_date: ISODate("2026-10-08")
    },
    {
        shipment_id: 1007,
        customer_id: 2,
        carrier_id: 2,
        origin_hub_id: 2,
        destination_hub_id: 3,
        shipping_cost: 550,
        expected_delivery_date: ISODate("2026-10-10"),
        actual_delivery_date: ISODate("2026-10-14")
    },
    {
        shipment_id: 1008,
        customer_id: 3,
        carrier_id: 3,
        origin_hub_id: 3,
        destination_hub_id: 4,
        shipping_cost: 750,
        expected_delivery_date: ISODate("2026-10-11"),
        actual_delivery_date: ISODate("2026-10-11")
    },
    {
        shipment_id: 1009,
        customer_id: 3,
        carrier_id: 1,
        origin_hub_id: 1,
        destination_hub_id: 5,
        shipping_cost: 650,
        expected_delivery_date: ISODate("2026-10-12"),
        actual_delivery_date: null
    },
    {
        shipment_id: 1010,
        customer_id: 4,
        carrier_id: 2,
        origin_hub_id: 4,
        destination_hub_id: 2,
        shipping_cost: 950,
        expected_delivery_date: ISODate("2026-10-13"),
        actual_delivery_date: ISODate("2026-10-18")
    },
    {
        shipment_id: 1011,
        customer_id: 5,
        carrier_id: 3,
        origin_hub_id: 5,
        destination_hub_id: 1,
        shipping_cost: 400,
        expected_delivery_date: ISODate("2026-10-14"),
        actual_delivery_date: ISODate("2026-10-14")
    }
]);

db.deliveryEvents.insertMany([
    {
        event_id: 1,
        shipment_id: 1001,
        event_type: "Picked Up",
        event_date: ISODate("2026-10-01"),
        remarks: "Shipment collected"
    },
    {
        event_id: 2,
        shipment_id: 1001,
        event_type: "In Transit",
        event_date: ISODate("2026-10-02"),
        remarks: "Shipment moving"
    },
    {
        event_id: 3,
        shipment_id: 1001,
        event_type: "Delivered",
        event_date: ISODate("2026-10-06"),
        remarks: "Delivered late"
    },
    {
        event_id: 4,
        shipment_id: 1002,
        event_type: "Picked Up",
        event_date: ISODate("2026-10-02"),
        remarks: "Shipment collected"
    },
    {
        event_id: 5,
        shipment_id: 1002,
        event_type: "Delivered",
        event_date: ISODate("2026-10-05"),
        remarks: "Delivered on time"
    },
    {
        event_id: 6,
        shipment_id: 1003,
        event_type: "In Transit",
        event_date: ISODate("2026-10-05"),
        remarks: "Delayed in transit"
    },
    {
        event_id: 7,
        shipment_id: 1003,
        event_type: "Delivered",
        event_date: ISODate("2026-10-10"),
        remarks: "Delivered late"
    },
    {
        event_id: 8,
        shipment_id: 1006,
        event_type: "Delivered",
        event_date: ISODate("2026-10-08"),
        remarks: "Delivered on time"
    }
]);

// =========================================================
// 2. PIPELINE 1
// SHIPMENTS WITH DELIVERY EVENTS
// =========================================================

db.shipments.aggregate([
    {
        $lookup: {
            from: "deliveryEvents",
            localField: "shipment_id",
            foreignField: "shipment_id",
            as: "delivery_events"
        }
    },
    {
        $project: {
            _id: 0,
            shipment_id: 1,
            customer_id: 1,
            carrier_id: 1,
            shipping_cost: 1,
            delivery_events: 1
        }
    }
]);

// =========================================================
// 3. PIPELINE 2
// CUSTOMERS WITH THEIR SHIPMENTS
// =========================================================

db.customers.aggregate([
    {
        $lookup: {
            from: "shipments",
            localField: "customer_id",
            foreignField: "customer_id",
            as: "customer_shipments"
        }
    },
    {
        $project: {
            _id: 0,
            customer_id: 1,
            customer_name: 1,
            city: 1,
            customer_shipments: 1
        }
    }
]);

// =========================================================
// 4. PIPELINE 3
// CARRIERS WITH DELAY STATISTICS
// =========================================================

db.carriers.aggregate([
    {
        $lookup: {
            from: "shipments",
            let: { carrierId: "$carrier_id" },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$carrier_id", "$$carrierId"]
                        },
                        actual_delivery_date: { $ne: null }
                    }
                },
                {
                    $project: {
                        delay_days: {
                            $dateDiff: {
                                startDate: "$expected_delivery_date",
                                endDate: "$actual_delivery_date",
                                unit: "day"
                            }
                        }
                    }
                },
                {
                    $group: {
                        _id: null,
                        total_shipments: { $sum: 1 },
                        average_delay: { $avg: "$delay_days" },
                        maximum_delay: { $max: "$delay_days" },
                        minimum_delay: { $min: "$delay_days" }
                    }
                }
            ],
            as: "delay_statistics"
        }
    },
    {
        $project: {
            _id: 0,
            carrier_id: 1,
            carrier_name: 1,
            delay_statistics: 1
        }
    }
]);

// =========================================================
// END OF MONGODB REPORTS
// =========================================================
