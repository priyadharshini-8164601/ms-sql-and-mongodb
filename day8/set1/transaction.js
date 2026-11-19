use BankTransferDB

// 2. Insert Sample Account Documents
db.accounts.insertMany([
    {
        accountId: 101,
        accountHolder: "Arun",
        balance: 10000,
        status: "Active"
    },
    {
        accountId: 102,
        accountHolder: "Priya",
        balance: 5000,
        status: "Active"
    },
    {
        accountId: 103,
        accountHolder: "Kumar",
        balance: 2000,
        status: "Inactive"
    }
]);

// 3. Start a Session and Transaction
const session = db.getMongo().startSession();

const bankDB = session.getDatabase("BankTransferDB");

session.startTransaction();

// 4. Validate Source and Destination Accounts
const source = bankDB.accounts.findOne({
    accountId: 101,
    status: "Active"
});

const destination = bankDB.accounts.findOne({
    accountId: 102,
    status: "Active"
});

// 5. Perform Funds Transfer
if (
    source &&
    destination &&
    source.balance >= 2000 &&
    source.accountId !== destination.accountId
) {

    // Debit Source Account
    bankDB.accounts.updateOne(
        {
            accountId: 101,
            status: "Active",
            balance: { $gte: 2000 }
        },
        {
            $inc: { balance: -2000 }
        }
    );

    // Credit Destination Account
    bankDB.accounts.updateOne(
        {
            accountId: 102,
            status: "Active"
        },
        {
            $inc: { balance: 2000 }
        }
    );

    // Record Debit Transaction
    bankDB.transactions.insertOne({
        accountId: 101,
        type: "Debit",
        amount: 2000,
        description: "Transferred to Account 102",
        transactionDate: new Date()
    });

    // Record Credit Transaction
    bankDB.transactions.insertOne({
        accountId: 102,
        type: "Credit",
        amount: 2000,
        description: "Received from Account 101",
        transactionDate: new Date()
    });

    // 6. Commit Transaction
    session.commitTransaction();

    print("Funds transferred successfully.");

} else {

    // 7. Rollback Transaction
    session.abortTransaction();

    print("Transfer failed. Transaction rolled back.");
}

// 8. End Session
session.endSession();

// 9. Verify Updated Account Balances
db.accounts.find().pretty();

// 10. Verify Transaction Records
db.transactions.find().pretty();
