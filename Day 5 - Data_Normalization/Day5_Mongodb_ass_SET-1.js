
use("RetailInventoryDB");

// Create collection with validation
db.createCollection("reviews", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["SKU", "customer", "rating", "comment"],
      properties: {
        SKU: {
          bsonType: "string"
        },
        customer: {
          bsonType: "string"
        },
        rating: {
          bsonType: "int",
          minimum: 1,
          maximum: 5
        },
        comment: {
          bsonType: "string"
        }
      }
    }
  }
});

// Insert reviews
db.reviews.insertMany([
  {
    SKU: "SKU001",
    customer: "Arun",
    rating: 5,
    comment: "Good product"
  },
  {
    SKU: "SKU002",
    customer: "Priya",
    rating: 4,
    comment: "Nice quality"
  },
  {
    SKU: "SKU003",
    customer: "Kumar",
    rating: 3,
    comment: "Average product"
  }
]);

// Find reviews
db.reviews.find();

// Update one review
db.reviews.updateOne(
  { SKU: "SKU001" },
  { $set: { comment: "Excellent product" } }
);

// Delete one review
db.reviews.deleteOne(
  { SKU: "SKU003" }
);

// View final records
db.reviews.find();
