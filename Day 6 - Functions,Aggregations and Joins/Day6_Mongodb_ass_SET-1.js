
/* =========================================
   SET 1 - RETAIL SALES REPORTING
   MongoDB Assignment
   ========================================= */

// 1. Select Database
use("RetailDB");

// 2. Insert Customers
db.customers.insertMany([
    { customer_id: 1, customer_name: "Arun", city: "Chennai" },
    { customer_id: 2, customer_name: "Priya", city: "Madurai" },
    { customer_id: 3, customer_name: "Kumar", city: "Chennai" },
    { customer_id: 4, customer_name: "Divya", city: "Salem" }
]);

// 3. Insert Products
db.products.insertMany([
    { product_id: 101, product_name: "Laptop", category: "Electronics", price: 50000 },
    { product_id: 102, product_name: "Mouse", category: "Electronics", price: 500 },
    { product_id: 103, product_name: "Chair", category: "Furniture", price: 5000 },
    { product_id: 104, product_name: "Table", category: "Furniture", price: 8000 }
]);

// 4. Insert Orders
db.orders.insertMany([
    { order_id: 1001, customer_id: 1, order_date: ISODate("2026-11-01"), payment_status: "Paid" },
    { order_id: 1002, customer_id: 2, order_date: ISODate("2026-11-02"), payment_status: "Pending" },
    { order_id: 1003, customer_id: 3, order_date: ISODate("2026-12-01"), payment_status: "Paid" },
    { order_id: 1004, customer_id: 4, order_date: ISODate("2026-12-05"), payment_status: "Paid" }
]);

// 5. Insert Order Items
db.order_items.insertMany([
    { item_id: 1, order_id: 1001, product_id: 101, quantity: 1, unit_price: 50000 },
    { item_id: 2, order_id: 1001, product_id: 102, quantity: 2, unit_price: 500 },
    { item_id: 3, order_id: 1002, product_id: 103, quantity: 1, unit_price: 5000 },
    { item_id: 4, order_id: 1003, product_id: 104, quantity: 2, unit_price: 8000 }
]);

// =========================================
// AGGREGATION QUERIES
// =========================================

// QUERY 1: Month-wise Sales Report

db.orders.aggregate([
    {
        $lookup: {
            from: "order_items",
            localField: "order_id",
            foreignField: "order_id",
            as: "items"
        }
    },
    { $unwind: "$items" },
    {
        $group: {
            _id: {
                $dateToString: {
                    format: "%Y-%m",
                    date: "$order_date",
                    timezone: "UTC"
                }
            },
            total_sales: {
                $sum: {
                    $multiply: ["$items.quantity", "$items.unit_price"]
                }
            }
        }
    },
    { $sort: { _id: 1 } }
]);

// QUERY 2: Top 5 Products by Revenue

db.order_items.aggregate([
    {
        $group: {
            _id: "$product_id",
            total_quantity: { $sum: "$quantity" },
            total_revenue: {
                $sum: {
                    $multiply: ["$quantity", "$unit_price"]
                }
            }
        }
    },
    {
        $lookup: {
            from: "products",
            localField: "_id",
            foreignField: "product_id",
            as: "product"
        }
    },
    { $unwind: "$product" },
    {
        $project: {
            _id: 0,
            product_name: "$product.product_name",
            total_quantity: 1,
            total_revenue: 1
        }
    },
    { $sort: { total_revenue: -1 } },
    { $limit: 5 }
]);

// QUERY 3: Average Basket Value by City

db.order_items.aggregate([
    {
        $group: {
            _id: "$order_id",
            order_total: {
                $sum: {
                    $multiply: ["$quantity", "$unit_price"]
                }
            }
        }
    },
    {
        $lookup: {
            from: "orders",
            localField: "_id",
            foreignField: "order_id",
            as: "order"
        }
    },
    { $unwind: "$order" },
    {
        $lookup: {
            from: "customers",
            localField: "order.customer_id",
            foreignField: "customer_id",
            as: "customer"
        }
    },
    { $unwind: "$customer" },
    {
        $group: {
            _id: "$customer.city",
            average_basket_value: {
                $avg: "$order_total"
            }
        }
    },
    {
        $project: {
            _id: 0,
            city: "$_id",
            average_basket_value: {
                $round: ["$average_basket_value", 2]
            }
        }
    },
    { $sort: { average_basket_value: -1 } }
]);
