
/* ============================================
   SET 3 - TELECOM USAGE AND BILLING REPORTING
   MongoDB Assignment
   ============================================ */

// 1. Select Database
use("TelecomDB");

// 2. Insert Usage Events

db.usage_events.insertMany([
    {
        event_id: 1,
        subscriber_id: 1,
        event_time: ISODate("2026-11-01T10:15:00Z"),
        duration_minutes: 12,
        data_used_gb: 2.50,
        cell_tower: "Tower-A"
    },
    {
        event_id: 2,
        subscriber_id: 1,
        event_time: ISODate("2026-11-01T11:45:00Z"),
        duration_minutes: 8,
        data_used_gb: 1.00,
        cell_tower: "Tower-A"
    },
    {
        event_id: 3,
        subscriber_id: 2,
        event_time: ISODate("2026-11-01T10:30:00Z"),
        duration_minutes: 20,
        data_used_gb: 2.50,
        cell_tower: "Tower-B"
    },
    {
        event_id: 4,
        subscriber_id: 2,
        event_time: ISODate("2026-11-02T10:30:00Z"),
        duration_minutes: 15,
        data_used_gb: 1.20,
        cell_tower: "Tower-B"
    },
    {
        event_id: 5,
        subscriber_id: 3,
        event_time: ISODate("2026-11-01T10:50:00Z"),
        duration_minutes: 15,
        data_used_gb: 4.00,
        cell_tower: "Tower-A"
    },
    {
        event_id: 6,
        subscriber_id: 3,
        event_time: ISODate("2026-11-01T12:10:00Z"),
        duration_minutes: 10,
        data_used_gb: 3.00,
        cell_tower: "Tower-C"
    }
]);

// ============================================
// QUERY 1: HOURLY USAGE
// ============================================

db.usage_events.aggregate([
    {
        $group: {
            _id: {
                $dateToString: {
                    format: "%Y-%m-%d %H:00",
                    date: "$event_time",
                    timezone: "UTC"
                }
            },
            total_data_used: {
                $sum: "$data_used_gb"
            },
            total_events: {
                $sum: 1
            }
        }
    },
    {
        $sort: {
            _id: 1
        }
    }
]);

// ============================================
// QUERY 2: AVERAGE SESSION LENGTH
// ============================================

db.usage_events.aggregate([
    {
        $group: {
            _id: null,
            average_session_length: {
                $avg: "$duration_minutes"
            }
        }
    },
    {
        $project: {
            _id: 0,
            average_session_length: {
                $round: ["$average_session_length", 2]
            }
        }
    }
]);

// ============================================
// QUERY 3: BUSIEST CELL TOWER
// ============================================

db.usage_events.aggregate([
    {
        $group: {
            _id: "$cell_tower",
            total_events: {
                $sum: 1
            },
            total_data_used: {
                $sum: "$data_used_gb"
            }
        }
    },
    {
        $sort: {
            total_events: -1,
            total_data_used: -1
        }
    },
    {
        $limit: 1
    }
]);
