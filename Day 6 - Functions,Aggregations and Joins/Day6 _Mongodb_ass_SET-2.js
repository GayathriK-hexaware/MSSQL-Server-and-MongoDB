
/* ==========================================
   SET 2 - INSURANCE POLICY REPORTING
   MongoDB Assignment
   ========================================== */

// 1. Select Database
use("InsuranceDB");

// 2. Insert Claims Notes

db.claims_notes.insertMany([
    {
        claim_id: 501,
        policy_id: 1001,
        claim_status: "Settled",
        claim_date: ISODate("2026-02-01"),
        settled_date: ISODate("2026-02-10"),
        damage_category: "Accident",
        claim_amount: 5000,
        settlement_amount: 4000,
        notes: "Vehicle accident claim settled"
    },
    {
        claim_id: 502,
        policy_id: 1002,
        claim_status: "Settled",
        claim_date: ISODate("2026-04-01"),
        settled_date: ISODate("2026-04-15"),
        damage_category: "Medical",
        claim_amount: 8000,
        settlement_amount: 7000,
        notes: "Medical treatment claim settled"
    },
    {
        claim_id: 503,
        policy_id: 1003,
        claim_status: "Pending",
        claim_date: ISODate("2026-08-01"),
        settled_date: null,
        damage_category: "Accident",
        claim_amount: 6000,
        settlement_amount: 0,
        notes: "Accident claim under review"
    },
    {
        claim_id: 504,
        policy_id: 1005,
        claim_status: "Settled",
        claim_date: ISODate("2026-09-01"),
        settled_date: ISODate("2026-09-08"),
        damage_category: "Fire",
        claim_amount: 3000,
        settlement_amount: 2500,
        notes: "Fire damage claim settled"
    }
]);

// ==========================================
// AGGREGATION QUERIES
// ==========================================

// QUERY 1: Claims per Status

db.claims_notes.aggregate([
    {
        $match: {
            claim_status: { $exists: true }
        }
    },
    {
        $group: {
            _id: "$claim_status",
            total_claims: { $sum: 1 }
        }
    },
    {
        $sort: {
            total_claims: -1
        }
    }
]);

// QUERY 2: Average Settlement Time in Days

db.claims_notes.aggregate([
    {
        $match: {
            settled_date: { $ne: null }
        }
    },
    {
        $project: {
            settlement_days: {
                $divide: [
                    {
                        $subtract: [
                            "$settled_date",
                            "$claim_date"
                        ]
                    },
                    1000 * 60 * 60 * 24
                ]
            }
        }
    },
    {
        $group: {
            _id: null,
            average_settlement_days: {
                $avg: "$settlement_days"
            }
        }
    },
    {
        $project: {
            _id: 0,
            average_settlement_days: {
                $round: ["$average_settlement_days", 2]
            }
        }
    }
]);

// QUERY 3: Top 3 Damage Categories

db.claims_notes.aggregate([
    {
        $match: {
            damage_category: { $exists: true }
        }
    },
    {
        $group: {
            _id: "$damage_category",
            total_claims: { $sum: 1 },
            total_claim_amount: { $sum: "$claim_amount" }
        }
    },
    {
        $sort: {
            total_claims: -1,
            total_claim_amount: -1
        }
    },
    {
        $limit: 3
    }
]);
