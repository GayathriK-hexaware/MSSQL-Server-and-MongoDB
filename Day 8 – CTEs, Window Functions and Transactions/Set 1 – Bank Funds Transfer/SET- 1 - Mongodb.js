use BankMongoDB

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
        balance: 15000,
        status: "Active"
    },
    {
        accountId: 103,
        accountHolder: "Kumar",
        balance: 5000,
        status: "Active"
    },
    {
        accountId: 104,
        accountHolder: "Divya",
        balance: 20000,
        status: "Frozen"
    }
])


//transaction script

const session = db.getMongo().startSession();

const bankDB = session.getDatabase("BankMongoDB");

const accounts = bankDB.accounts;
const transactions = bankDB.transactions;

const fromAccountId = 101;
const toAccountId = 102;
const amount = 2000;

try {
    session.startTransaction({
        readConcern: { level: "snapshot" },
        writeConcern: { w: "majority" },
        readPreference: "primary"
    });

    const sender = accounts.findOne(
        { accountId: fromAccountId },
        { session }
    );

    const receiver = accounts.findOne(
        { accountId: toAccountId },
        { session }
    );

    if (!sender || !receiver) {
        throw new Error("Account not found");
    }

    if (sender.status !== "Active" || receiver.status !== "Active") {
        throw new Error("Both accounts must be active");
    }

    if (sender.balance < amount) {
        throw new Error("Insufficient balance");
    }

    const debitResult = accounts.updateOne(
        {
            accountId: fromAccountId,
            status: "Active",
            balance: { $gte: amount }
        },
        {
            $inc: { balance: -amount }
        },
        { session }
    );

    if (debitResult.modifiedCount !== 1) {
        throw new Error("Debit failed");
    }

    const creditResult = accounts.updateOne(
        {
            accountId: toAccountId,
            status: "Active"
        },
        {
            $inc: { balance: amount }
        },
        { session }
    );

    if (creditResult.modifiedCount !== 1) {
        throw new Error("Credit failed");
    }

    transactions.insertOne(
        {
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            amount: amount,
            transactionType: "Funds Transfer",
            transactionDate: new Date()
        },
        { session }
    );

    session.commitTransaction();

    print("Funds transferred successfully");

} catch (error) {

    session.abortTransaction();

    print("Transaction failed: " + error.message);
    print("All changes have been rolled back");

} finally {

    session.endSession();
}