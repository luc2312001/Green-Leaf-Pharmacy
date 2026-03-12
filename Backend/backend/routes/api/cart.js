// backend/routes/api/cart.js
// Shopping cart API routes

const router = require("express").Router();
const CartController = require("../../controllers/cart.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

// All cart routes require authentication
router.use(authMiddleware);

// GET /api/cart - Get user's cart
router.get("/", CartController.getCart);

// POST /api/cart/add - Add item to cart
router.post("/add", CartController.addToCart);

// POST /api/cart/update - Update cart item quantity
router.post("/update", CartController.updateCart);

// POST /api/cart/remove - Remove item from cart
router.post("/remove", CartController.removeFromCart);

// POST /api/cart/clear - Clear entire cart
router.post("/clear", CartController.clearCart);

module.exports = router;
