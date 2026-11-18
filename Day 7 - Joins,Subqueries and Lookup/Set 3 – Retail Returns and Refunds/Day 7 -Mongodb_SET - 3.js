 SET 3 - RETAIL RETURNS AND REFUNDS


db = db.getSiblingDB("RetailReturnsDB");

// Clear old sample data before rerunning.
// WARNING: This deletes existing documents in these collections.
db.customers.deleteMany({});
db.stores.deleteMany({});
db.products.deleteMany({});
db.sales.deleteMany({});
db.sale_items.deleteMany({});
db.returns.deleteMany({});
db.refunds.deleteMany({});
db.returns_feedback.deleteMany({});


// ============================================================
// TASK 0 : INSERT SAMPLE DATA
// ============================================================

// CUSTOMERS
db.customers.insertMany([
    { customerId: 1, customerName: "Anu", city: "Chennai" },
    { customerId: 2, customerName: "Bala", city: "Chennai" },
    { customerId: 3, customerName: "Charan", city: "Bengaluru" },
    { customerId: 4, customerName: "Divya", city: "Bengaluru" },
    { customerId: 5, customerName: "Esha", city: "Hyderabad" },
    { customerId: 6, customerName: "Farhan", city: "Hyderabad" }
]);

// STORES
db.stores.insertMany([
    { storeId: 1, storeName: "Chennai Central", region: "South" },
    { storeId: 2, storeName: "Coimbatore Mall", region: "South" },
    { storeId: 3, storeName: "Bengaluru City", region: "West" },
    { storeId: 4, storeName: "Mysuru Plaza", region: "West" },
    { storeId: 5, storeName: "Hyderabad Hub", region: "South" }
]);

// PRODUCTS
db.products.insertMany([
    { productId: 1, productName: "Wireless Mouse", category: "Electronics", unitPrice: 800 },
    { productId: 2, productName: "Keyboard", category: "Electronics", unitPrice: 1500 },
    { productId: 3, productName: "Water Bottle", category: "Home", unitPrice: 400 },
    { productId: 4, productName: "Backpack", category: "Accessories", unitPrice: 1200 },
    { productId: 5, productName: "Headphones", category: "Electronics", unitPrice: 2500 },
    { productId: 6, productName: "Desk Lamp", category: "Home", unitPrice: 900 }
]);

// SALES
db.sales.insertMany([
    { saleId: 101, customerId: 1, storeId: 1, employeeId: 1, saleDate: ISODate("2026-10-01") },
    { saleId: 102, customerId: 2, storeId: 1, employeeId: 2, saleDate: ISODate("2026-10-03") },
    { saleId: 103, customerId: 3, storeId: 2, employeeId: 3, saleDate: ISODate("2026-10-05") },
    { saleId: 104, customerId: 4, storeId: 3, employeeId: 4, saleDate: ISODate("2026-10-07") },
    { saleId: 105, customerId: 5, storeId: 3, employeeId: 5, saleDate: ISODate("2026-10-09") },
    { saleId: 106, customerId: 1, storeId: 2, employeeId: 3, saleDate: ISODate("2026-10-11") },
    { saleId: 107, customerId: 2, storeId: 4, employeeId: 6, saleDate: ISODate("2026-10-13") },
    { saleId: 108, customerId: 3, storeId: 1, employeeId: 2, saleDate: ISODate("2026-10-15") },
    { saleId: 109, customerId: 4, storeId: 5, employeeId: 1, saleDate: ISODate("2026-10-17") },
    { saleId: 110, customerId: 6, storeId: 3, employeeId: 5, saleDate: ISODate("2026-10-19") }
]);

// SALE ITEMS
db.sale_items.insertMany([
    { saleItemId: 1001, saleId: 101, productId: 1, quantity: 10, unitPrice: 800 },
    { saleItemId: 1002, saleId: 101, productId: 2, quantity: 5, unitPrice: 1500 },
    { saleItemId: 1003, saleId: 102, productId: 1, quantity: 8, unitPrice: 800 },
    { saleItemId: 1004, saleId: 102, productId: 3, quantity: 10, unitPrice: 400 },
    { saleItemId: 1005, saleId: 103, productId: 2, quantity: 10, unitPrice: 1500 },
    { saleItemId: 1006, saleId: 103, productId: 4, quantity: 5, unitPrice: 1200 },
    { saleItemId: 1007, saleId: 104, productId: 5, quantity: 10, unitPrice: 2500 },
    { saleItemId: 1008, saleId: 105, productId: 1, quantity: 12, unitPrice: 800 },
    { saleItemId: 1009, saleId: 106, productId: 3, quantity: 8, unitPrice: 400 },
    { saleItemId: 1010, saleId: 107, productId: 4, quantity: 10, unitPrice: 1200 },
    { saleItemId: 1011, saleId: 108, productId: 5, quantity: 5, unitPrice: 2500 },
    { saleItemId: 1012, saleId: 109, productId: 6, quantity: 10, unitPrice: 900 },
    { saleItemId: 1013, saleId: 110, productId: 2, quantity: 8, unitPrice: 1500 }
]);

// RETURNS
// customerId, storeId and productId are included to simplify reporting.
db.returns.insertMany([
    { returnId: 201, saleItemId: 1001, saleId: 101, customerId: 1, storeId: 1, productId: 1, returnDate: ISODate("2026-10-10"), returnQuantity: 2, returnReason: "Damaged item", returnStatus: "APPROVED" },
    { returnId: 202, saleItemId: 1002, saleId: 101, customerId: 1, storeId: 1, productId: 2, returnDate: ISODate("2026-10-12"), returnQuantity: 1, returnReason: "Wrong product", returnStatus: "APPROVED" },
    { returnId: 203, saleItemId: 1003, saleId: 102, customerId: 2, storeId: 1, productId: 1, returnDate: ISODate("2026-10-14"), returnQuantity: 2, returnReason: "Not working", returnStatus: "APPROVED" },
    { returnId: 204, saleItemId: 1005, saleId: 103, customerId: 3, storeId: 2, productId: 2, returnDate: ISODate("2026-10-16"), returnQuantity: 3, returnReason: "Changed mind", returnStatus: "APPROVED" },
    { returnId: 205, saleItemId: 1007, saleId: 104, customerId: 4, storeId: 3, productId: 5, returnDate: ISODate("2026-10-18"), returnQuantity: 2, returnReason: "Sound issue", returnStatus: "APPROVED" },
    { returnId: 206, saleItemId: 1008, saleId: 105, customerId: 5, storeId: 3, productId: 1, returnDate: ISODate("2026-10-20"), returnQuantity: 1, returnReason: "Damaged item", returnStatus: "PENDING" },
    { returnId: 207, saleItemId: 1009, saleId: 106, customerId: 1, storeId: 2, productId: 3, returnDate: ISODate("2026-10-22"), returnQuantity: 2, returnReason: "Quality issue", returnStatus: "APPROVED" },
    { returnId: 208, saleItemId: 1011, saleId: 108, customerId: 3, storeId: 1, productId: 5, returnDate: ISODate("2026-10-24"), returnQuantity: 1, returnReason: "Not satisfied", returnStatus: "APPROVED" },
    { returnId: 209, saleItemId: 1012, saleId: 109, customerId: 4, storeId: 5, productId: 6, returnDate: ISODate("2026-10-25"), returnQuantity: 1, returnReason: "Defective", returnStatus: "PENDING" }
]);

// REFUNDS
// A null returnId is intentionally included for the SQL NOT IN example.
db.refunds.insertMany([
    { refundId: 301, returnId: 201, refundDate: ISODate("2026-10-11"), refundAmount: 1600, refundStatus: "PAID" },
    { refundId: 302, returnId: 202, refundDate: ISODate("2026-10-13"), refundAmount: 1500, refundStatus: "PAID" },
    { refundId: 303, returnId: 203, refundDate: ISODate("2026-10-15"), refundAmount: 1600, refundStatus: "PAID" },
    { refundId: 304, returnId: 204, refundDate: ISODate("2026-10-17"), refundAmount: 3600, refundStatus: "PAID" },
    { refundId: 305, returnId: 205, refundDate: ISODate("2026-10-19"), refundAmount: 5000, refundStatus: "PAID" },
    { refundId: 306, returnId: 207, refundDate: ISODate("2026-10-23"), refundAmount: 800, refundStatus: "PAID" },
    { refundId: 307, returnId: 208, refundDate: ISODate("2026-10-25"), refundAmount: 2500, refundStatus: "PAID" },
    { refundId: 308, returnId: null, refundDate: ISODate("2026-10-26"), refundAmount: 100, refundStatus: "MANUAL_ADJUSTMENT" }
]);

// RETURNS FEEDBACK
db.returns_feedback.insertMany([
    { feedbackId: 401, returnId: 201, customerId: 1, rating: 5, comments: "Quick refund process", feedbackDate: ISODate("2026-10-12") },
    { feedbackId: 402, returnId: 202, customerId: 1, rating: 3, comments: "Replacement was not available", feedbackDate: ISODate("2026-10-14") },
    { feedbackId: 403, returnId: 203, customerId: 2, rating: 4, comments: "Issue resolved", feedbackDate: ISODate("2026-10-16") },
    { feedbackId: 404, returnId: 204, customerId: 3, rating: 2, comments: "Refund took time", feedbackDate: ISODate("2026-10-18") },
    { feedbackId: 405, returnId: 205, customerId: 4, rating: 5, comments: "Good support", feedbackDate: ISODate("2026-10-20") },
    { feedbackId: 406, returnId: 207, customerId: 1, rating: 4, comments: "Satisfied", feedbackDate: ISODate("2026-10-24") }
]);


// ============================================================
// VERIFY SAMPLE DATA
// ============================================================

print("\n--- RETURNS ---");
db.returns.find().forEach(printjson);

print("\n--- REFUNDS ---");
db.refunds.find().forEach(printjson);

print("\n--- RETURNS FEEDBACK ---");
db.returns_feedback.find().forEach(printjson);


// ============================================================
// TASK 5 : THREE MONGODB PIPELINES USING $lookup
// ============================================================

//in - PIPELINE 1: Return details with product, customer and feedback
print("\n--- PIPELINE 1: RETURNS WITH PRODUCT, CUSTOMER AND FEEDBACK ---");

db.returns.aggregate([
    {
        $lookup: {
            from: "products",
            localField: "productId",
            foreignField: "productId",
            as: "product"
        }
    },
    {
        $lookup: {
            from: "customers",
            localField: "customerId",
            foreignField: "customerId",
            as: "customer"
        }
    },
    {
        $lookup: {
            from: "returns_feedback",
            localField: "returnId",
            foreignField: "returnId",
            as: "feedback"
        }
    },
    {
        $unwind: {
            path: "$product",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $unwind: {
            path: "$customer",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $project: {
            _id: 0,
            returnId: 1,
            returnQuantity: 1,
            returnReason: 1,
            returnStatus: 1,
            productName: "$product.productName",
            customerName: "$customer.customerName",
            feedback: 1
        }
    },
    { $sort: { returnId: 1 } }
]);


//in - PIPELINE 2: Each customer with their returns and feedback
print("\n--- PIPELINE 2: CUSTOMERS WITH RETURNS AND FEEDBACK ---");

db.customers.aggregate([
    {
        $lookup: {
            from: "returns",
            let: {
                currentCustomerId: "$customerId"
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$customerId", "$$currentCustomerId"]
                        }
                    }
                },
                {
                    $lookup: {
                        from: "returns_feedback",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "feedback"
                    }
                },
                {
                    $project: {
                        _id: 0,
                        returnId: 1,
                        productId: 1,
                        returnQuantity: 1,
                        returnReason: 1,
                        returnStatus: 1,
                        feedback: 1
                    }
                }
            ],
            as: "customerReturns"
        }
    },
    {
        $project: {
            _id: 0,
            customerId: 1,
            customerName: 1,
            city: 1,
            customerReturns: 1
        }
    },
    { $sort: { customerId: 1 } }
]);


//in - PIPELINE 3: Each store with returns, feedback and refunds
print("\n--- PIPELINE 3: STORES WITH RETURNS, FEEDBACK AND REFUNDS ---");

db.stores.aggregate([
    {
        $lookup: {
            from: "returns",
            let: {
                currentStoreId: "$storeId"
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: ["$storeId", "$$currentStoreId"]
                        }
                    }
                },
                {
                    $lookup: {
                        from: "returns_feedback",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "feedback"
                    }
                },
                {
                    $lookup: {
                        from: "refunds",
                        localField: "returnId",
                        foreignField: "returnId",
                        as: "refund"
                    }
                },
                {
                    $project: {
                        _id: 0,
                        returnId: 1,
                        customerId: 1,
                        productId: 1,
                        returnStatus: 1,
                        feedback: 1,
                        refund: 1
                    }
                }
            ],
            as: "storeReturns"
        }
    },
    {
        $project: {
            _id: 0,
            storeId: 1,
            storeName: 1,
            region: 1,
            storeReturns: 1,
            totalReturns: {
                $size: "$storeReturns"
            }
        }
    },
    { $sort: { storeId: 1 } }
]);


