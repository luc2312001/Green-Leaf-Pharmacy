// backend/routes/api/orders.js
// Order API routes

const router = require("express").Router();
const OrderController = require("../../controllers/order.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

// All order routes require authentication
router.use(authMiddleware);

// POST /api/orders - Create new order
router.post("/", OrderController.createOrder);

// GET /api/orders - Get user's orders
router.get("/", OrderController.getOrders);

// GET /api/orders/:id - Get order by ID
router.get("/:id", OrderController.getOrder);

module.exports = router;
