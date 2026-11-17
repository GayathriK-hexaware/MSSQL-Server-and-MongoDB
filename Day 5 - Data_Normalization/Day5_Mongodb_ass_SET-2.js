
use("BankDB");

// Create capped collection
db.createCollection("activity_logs", {
    capped: true,
    size: 1048576,  // 1 MB
    max: 1000
});

// Create 20 activity documents
let activities = [];

for (let i = 1; i <= 20; i++) {
    activities.push({
        customerId: "C001",
        eventType: i % 2 === 0 ? "login" : "balance_check",
        description: i % 2 === 0
            ? "Customer logged in"
            : "Customer checked balance",
        timestamp: new Date(
            `2026-11-${String(i).padStart(2, "0")}T10:00:00Z`
        )
    });
}

// Insert 20 documents
db.activity_logs.insertMany(activities);

// View all activity logs
db.activity_logs.find();

// Find the last 5 login events of customer C001
db.activity_logs.find({
    customerId: "C001",
    eventType: "login"
})
.sort({ timestamp: -1 })
.limit(5);
