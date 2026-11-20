
// MongoDB database
use("InsuranceDB");

db.customer_communications.insertMany([
    {
        communicationId: 1,
        customerId: 101,
        customerName: "Arun Kumar",
        communicationType: "Complaint",
        subject: "Premium payment issue",
        message: "Premium payment was deducted twice.",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 2,
        customerId: 102,
        customerName: "Priya Sharma",
        communicationType: "Complaint",
        subject: "Claim delay",
        message: "Claim processing is delayed.",
        status: "Resolved",
        communicationDate: new Date()
    },
    {
        communicationId: 3,
        customerId: 103,
        customerName: "Rahul Raj",
        communicationType: "Complaint",
        subject: "Policy renewal issue",
        message: "Unable to renew the insurance policy.",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 4,
        customerId: 104,
        customerName: "Divya Kumar",
        communicationType: "Enquiry",
        subject: "Policy details",
        message: "Requesting policy information.",
        status: "Open",
        communicationDate: new Date()
    },
    {
        communicationId: 5,
        customerId: 105,
        customerName: "Karthik S",
        communicationType: "Complaint",
        subject: "Incorrect premium amount",
        message: "The premium amount is incorrect.",
        status: "Unresolved",
        communicationDate: new Date()
    },
    {
        communicationId: 6,
        customerId: 101,
        customerName: "Arun Kumar",
        communicationType: "Complaint",
        subject: "Document verification",
        message: "Document verification is pending.",
        status: "Resolved",
        communicationDate: new Date()
    }
]);

db.createView(
    "unresolved_complaints",
    "customer_communications",
    [
        {
            $match: {
                communicationType: "Complaint",
                status: "Unresolved"
            }
        },
        {
            $project: {
                _id: 0,
                communicationId: 1,
                customerId: 1,
                customerName: 1,
                subject: 1,
                message: 1,
                status: 1,
                communicationDate: 1
            }
        }
    ]
);

db.unresolved_complaints.find();

db.unresolved_complaints.find({
    customerId: 101
});

db.unresolved_complaints.countDocuments({});

db.unresolved_complaints.find().pretty();

// Optional view removal
// db.unresolved_complaints.drop();
