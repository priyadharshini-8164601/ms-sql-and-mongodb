
use RetailInventoryDB

db.createCollection("reviews", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: [
                "productSKU",
                "customerName",
                "rating",
                "reviewText",
                "reviewDate"
            ],
            properties: {
                productSKU: {
                    bsonType: "string"
                },
                customerName: {
                    bsonType: "string"
                },
                rating: {
                    bsonType: "int",
                    minimum: 1,
                    maximum: 5
                },
                reviewText: {
                    bsonType: "string"
                },
                reviewDate: {
                    bsonType: "date"
                }
            }
        }
    },
    validationLevel: "strict",
    validationAction: "error"
})


db.reviews.insertMany([
    {
        productSKU: "SKU101",
        customerName: "Arun",
        rating: 5,
        reviewText: "Excellent laptop performance",
        reviewDate: new Date("2026-11-10")
    },
    {
        productSKU: "SKU102",
        customerName: "Priya",
        rating: 4,
        reviewText: "Comfortable office chair",
        reviewDate: new Date("2026-11-11")
    },
    {
        productSKU: "SKU103",
        customerName: "Karthik",
        rating: 3,
        reviewText: "Good quality T shirt",
        reviewDate: new Date("2026-11-12")
    },
    {
        productSKU: "SKU104",
        customerName: "Divya",
        rating: 5,
        reviewText: "Very useful Python book",
        reviewDate: new Date("2026-11-13")
    },
    {
        productSKU: "SKU105",
        customerName: "Ravi",
        rating: 2,
        reviewText: "Packaging needs improvement",
        reviewDate: new Date("2026-11-14")
    }
])



// Display all reviews
db.reviews.find()

// Find reviews for one product
db.reviews.find({
    productSKU: "SKU101"
})

// Find reviews with rating 5
db.reviews.find({
    rating: 5
})

// Display reviews in readable format
db.reviews.find().pretty()



db.reviews.updateOne(
    { customerName: "Arun" },
    {
        $set: {
            rating: 4,
            reviewText: "Good laptop with excellent features"
        }
    }
)

// Verify update
db.reviews.find({
    customerName: "Arun"
})



db.reviews.deleteOne({
    customerName: "Ravi"
})

// Verify deletion
db.reviews.find()

