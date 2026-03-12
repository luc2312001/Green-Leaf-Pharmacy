// backend/routes/api/products.js
// Product API routes

const router = require("express").Router();
const ProductController = require("../../controllers/product.controller");

// GET /api/products/list - List products with page
router.get("/list", ProductController.listProducts);

// GET /api/products/search? - Search products
router.get("/search", ProductController.searchProducts);

// GET /api/products/:id - Get product by ID
router.get("/:id", ProductController.getProduct);

// GET /api/products/:id/questions - Get product questions
router.get("/:id/questions", ProductController.getProductQuestions);

// GET /api/products/:id/answer/:stt - Get product answers 
router.get("/:id/answer/:stt", ProductController.getProductAnswers);

module.exports = router;
