
LOGISTICS SHIPMENT ANALYSIS


// 1. Select database
db = db.getSiblingDB("LogisticsDB");



// =====================================================
// 3. CREATE COLLECTIONS AND INSERT SAMPLE DATA
// =====================================================

// CUSTOMERS
db.customers.insertMany([
    { customerId: 1, customerName: "Arun", city: "Chennai" },
    { customerId: 2, customerName: "Bala", city: "Bangalore" },
    { customerId: 3, customerName: "Charan", city: "Hyderabad" },
    { customerId: 4, customerName: "Divya", city: "Mumbai" }
]);


// HUBS
db.hubs.insertMany([
    { hubId: 1, hubName: "Chennai Central", location: "Chennai" },
    { hubId: 2, hubName: "Bangalore Hub", location: "Bangalore" },
    { hubId: 3, hubName: "Hyderabad Hub", location: "Hyderabad" },
    { hubId: 4, hubName: "Mumbai Hub", location: "Mumbai" },
    { hubId: 5, hubName: "Coimbatore Hub", location: "Coimbatore" }
]);


// CARRIERS
db.carriers.insertMany([
    { carrierId: 1, carrierName: "FastTrack" },
    { carrierId: 2, carrierName: "BlueDart" },
    { carrierId: 3, carrierName: "SafeShip" },
    { carrierId: 4, carrierName: "QuickExpress" }
]);


// SHIPMENTS
db.shipments.insertMany([
    {
        shipmentId: 1001,
        customerId: 1,
        carrierId: 1,
        originHubId: 1,
        destinationHubId: 2,
        shippingCost: 500,
        expectedDeliveryDate: ISODate("2026-11-02T00:00:00Z"),
        deliveredAt: ISODate("2026-11-05T00:00:00Z")
    },
    {
        shipmentId: 1002,
        customerId: 1,
        carrierId: 2,
        originHubId: 2,
        destinationHubId: 3,
        shippingCost: 800,
        expectedDeliveryDate: ISODate("2026-11-03T00:00:00Z"),
        deliveredAt: ISODate("2026-11-03T00:00:00Z")
    },
    {
        shipmentId: 1003,
        customerId: 1,
        carrierId: 1,
        originHubId: 1,
        destinationHubId: 4,
        shippingCost: 1200,
        expectedDeliveryDate: ISODate("2026-11-04T00:00:00Z"),
        deliveredAt: ISODate("2026-11-08T00:00:00Z")
    },
    {
        shipmentId: 1004,
        customerId: 1,
        carrierId: 2,
        originHubId: 3,
        destinationHubId: 5,
        shippingCost: 700,
        expectedDeliveryDate: ISODate("2026-11-05T00:00:00Z"),
        deliveredAt: ISODate("2026-11-07T00:00:00Z")
    },
    {
        shipmentId: 1005,
        customerId: 2,
        carrierId: 3,
        originHubId: 2,
        destinationHubId: 1,
        shippingCost: 600,
        expectedDeliveryDate: ISODate("2026-11-06T00:00:00Z"),
        deliveredAt: ISODate("2026-11-10T00:00:00Z")
    },
    {
        shipmentId: 1006,
        customerId: 2,
        carrierId: 1,
        originHubId: 1,
        destinationHubId: 3,
        shippingCost: 900,
        expectedDeliveryDate: ISODate("2026-11-07T00:00:00Z"),
        deliveredAt: ISODate("2026-11-08T00:00:00Z")
    },
    {
        shipmentId: 1007,
        customerId: 3,
        carrierId: 2,
        originHubId: 4,
        destinationHubId: 2,
        shippingCost: 1500,
        expectedDeliveryDate: ISODate("2026-11-08T00:00:00Z"),
        deliveredAt: ISODate("2026-11-12T00:00:00Z")
    },
    {
        shipmentId: 1008,
        customerId: 4,
        carrierId: null,
        originHubId: 2,
        destinationHubId: 4,
        shippingCost: 400,
        expectedDeliveryDate: ISODate("2026-11-09T00:00:00Z"),
        deliveredAt: null
    },
    {
        shipmentId: 1009,
        customerId: 1,
        carrierId: 3,
        originHubId: 4,
        destinationHubId: 1,
        shippingCost: 1100,
        expectedDeliveryDate: ISODate("2026-11-10T00:00:00Z"),
        deliveredAt: ISODate("2026-11-11T00:00:00Z")
    }
]);


// DELIVERY EVENTS
db.delivery_events.insertMany([
    {
        eventId: 1,
        shipmentId: 1001,
        eventType: "Picked Up",
        eventTime: ISODate("2026-11-02T09:00:00Z")
    },
    {
        eventId: 2,
        shipmentId: 1001,
        eventType: "In Transit",
        eventTime: ISODate("2026-11-03T10:00:00Z")
    },
    {
        eventId: 3,
        shipmentId: 1001,
        eventType: "Delivered",
        eventTime: ISODate("2026-11-05T15:00:00Z")
    },
    {
        eventId: 4,
        shipmentId: 1002,
        eventType: "Picked Up",
        eventTime: ISODate("2026-11-03T08:00:00Z")
    },
    {
        eventId: 5,
        shipmentId: 1002,
        eventType: "Delivered",
        eventTime: ISODate("2026-11-03T18:00:00Z")
    },
    {
        eventId: 6,
        shipmentId: 1003,
        eventType: "Picked Up",
        eventTime: ISODate("2026-11-04T09:00:00Z")
    },
    {
        eventId: 7,
        shipmentId: 1003,
        eventType: "Delayed",
        eventTime: ISODate("2026-11-07T12:00:00Z")
    },
    {
        eventId: 8,
        shipmentId: 1003,
        eventType: "Delivered",
        eventTime: ISODate("2026-11-08T16:00:00Z")
    },
    {
        eventId: 9,
        shipmentId: 1005,
        eventType: "Picked Up",
        eventTime: ISODate("2026-11-06T10:00:00Z")
    },
    {
        eventId: 10,
        shipmentId: 1005,
        eventType: "Delivered",
        eventTime: ISODate("2026-11-10T14:00:00Z")
    }
]);


// =====================================================
// 4. VERIFY INSERTED DATA
// =====================================================

print("\n--- CUSTOMERS ---");
db.customers.find();

print("\n--- HUBS ---");
db.hubs.find();

print("\n--- CARRIERS ---");
db.carriers.find();

print("\n--- SHIPMENTS ---");
db.shipments.find();

print("\n--- DELIVERY EVENTS ---");
db.delivery_events.find();


// =====================================================
// 5. AGGREGATION 1
// SHIPMENTS + DELIVERY EVENTS
// =====================================================

// Business Question:
// Display every shipment along with its delivery events.

print("\n--- SHIPMENTS WITH DELIVERY EVENTS ---");

db.shipments.aggregate([
    {
        $lookup: {
            from: "delivery_events",
            localField: "shipmentId",
            foreignField: "shipmentId",
            as: "deliveryEvents"
        }
    },
    {
        $project: {
            _id: 0,
            shipmentId: 1,
            customerId: 1,
            carrierId: 1,
            shippingCost: 1,
            deliveryEvents: 1
        }
    }
]);


// =====================================================
// 6. AGGREGATION 2
// CUSTOMERS + SHIPMENTS
// =====================================================

// Business Question:
// Display each customer with all their shipments.

print("\n--- CUSTOMERS WITH SHIPMENTS ---");

db.customers.aggregate([
    {
        $lookup: {
            from: "shipments",
            localField: "customerId",
            foreignField: "customerId",
            as: "customerShipments"
        }
    },
    {
        $project: {
            _id: 0,
            customerId: 1,
            customerName: 1,
            city: 1,
            customerShipments: 1
        }
    }
]);


// =====================================================
// 7. AGGREGATION 3
// CARRIERS + DELIVERY DELAY STATISTICS
// =====================================================

// Business Question:
// Calculate each carrier's total delivered shipments,
// average delay and number of shipments delayed
// by more than two days.

print("\n--- CARRIER DELIVERY DELAY STATISTICS ---");

db.carriers.aggregate([
    {
        $lookup: {
            from: "shipments",
            let: {
                currentCarrierId: "$carrierId"
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $and: [
                                {
                                    $eq: [
                                        "$carrierId",
                                        "$$currentCarrierId"
                                    ]
                                },
                                {
                                    $ne: [
                                        "$deliveredAt",
                                        null
                                    ]
                                }
                            ]
                        }
                    }
                },
                {
                    $addFields: {
                        delayDays: {
                            $divide: [
                                {
                                    $subtract: [
                                        "$deliveredAt",
                                        "$expectedDeliveryDate"
                                    ]
                                },
                                86400000
                            ]
                        }
                    }
                },
                {
                    $group: {
                        _id: null,
                        totalDeliveredShipments: {
                            $sum: 1
                        },
                        averageDelayDays: {
                            $avg: "$delayDays"
                        },
                        delayedShipments: {
                            $sum: {
                                $cond: [
                                    {
                                        $gt: [
                                            "$delayDays",
                                            2
                                        ]
                                    },
                                    1,
                                    0
                                ]
                            }
                        }
                    }
                }
            ],
            as: "delayStatistics"
        }
    },
    {
        $unwind: {
            path: "$delayStatistics",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            carrierId: 1,
            carrierName: 1,
            totalDeliveredShipments: {
                $ifNull: [
                    "$delayStatistics.totalDeliveredShipments",
                    0
                ]
            },
            averageDelayDays: {
                $ifNull: [
                    "$delayStatistics.averageDelayDays",
                    0
                ]
            },
            delayedShipments: {
                $ifNull: [
                    "$delayStatistics.delayedShipments",
                    0
                ]
            }
        }
    }
]);




