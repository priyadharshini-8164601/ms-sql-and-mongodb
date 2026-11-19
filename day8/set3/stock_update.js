
use RetailInventoryDB

db.products.insertMany([
    {
        productId: 1,
        productName: "Laptop",
        category: "Electronics",
        stockQuantity: 10,
        price: 50000
    },
    {
        productId: 2,
        productName: "Mobile",
        category: "Electronics",
        stockQuantity: 20,
        price: 20000
    },
    {
        productId: 3,
        productName: "Headphones",
        category: "Electronics",
        stockQuantity: 5,
        price: 2000
    },
    {
        productId: 4,
        productName: "Chair",
        category: "Furniture",
        stockQuantity: 15,
        price: 3000
    }
])

db.products.find().pretty()

db.products.updateOne(
    {
        productId: 1,
        stockQuantity: { $gte: 2 }
    },
    {
        $inc: { stockQuantity: -2 }
    }
)

db.products.findOne({ productId: 1 })

db.products.updateOne(
    {
        productId: 3,
        stockQuantity: { $gte: 100 }
    },
    {
        $inc: { stockQuantity: -100 }
    }
)

db.products.findOne({ productId: 3 })

db.products.updateOne(
    {
        productId: 1
    },
    {
        $inc: { stockQuantity: 2 }
    }
)

db.products.find().pretty()
