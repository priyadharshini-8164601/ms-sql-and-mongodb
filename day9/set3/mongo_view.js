
// Select database
use("TelecomDB");

db.notification_log.insertMany([
    {
        notificationId: 1,
        subscriberId: 1001,
        message: "Your balance is below 50. Please recharge.",
        notificationType: "Low Balance",
        isRead: false,
        notificationDate: new Date()
    },
    {
        notificationId: 2,
        subscriberId: 1001,
        message: "Recharge successful.",
        notificationType: "Recharge",
        isRead: true,
        notificationDate: new Date()
    },
    {
        notificationId: 3,
        subscriberId: 1002,
        message: "Your balance is below 50. Please recharge.",
        notificationType: "Low Balance",
        isRead: false,
        notificationDate: new Date()
    },
    {
        notificationId: 4,
        subscriberId: 1003,
        message: "Your balance is below 50. Please recharge.",
        notificationType: "Low Balance",
        isRead: false,
        notificationDate: new Date()
    },
    {
        notificationId: 5,
        subscriberId: 1003,
        message: "Your recharge validity is ending soon.",
        notificationType: "Validity Alert",
        isRead: false,
        notificationDate: new Date()
    },
    {
        notificationId: 6,
        subscriberId: 1004,
        message: "Your recharge was successful.",
        notificationType: "Recharge",
        isRead: true,
        notificationDate: new Date()
    },
    {
        notificationId: 7,
        subscriberId: 1005,
        message: "Your balance is below 50. Please recharge.",
        notificationType: "Low Balance",
        isRead: false,
        notificationDate: new Date()
    }
]);

db.createView(
    "unread_notification_counts",
    "notification_log",
    [
        {
            $match: {
                isRead: false
            }
        },
        {
            $group: {
                _id: "$subscriberId",
                unreadCount: {
                    $sum: 1
                }
            }
        },
        {
            $project: {
                _id: 0,
                subscriberId: "$_id",
                unreadCount: 1
            }
        },
        {
            $sort: {
                subscriberId: 1
            }
        }
    ]
);

db.unread_notification_counts.find();

db.unread_notification_counts.find({
    subscriberId: 1001
});

db.unread_notification_counts.countDocuments({});

db.unread_notification_counts.find().pretty();

// Optional view removal
// db.unread_notification_counts.drop();
