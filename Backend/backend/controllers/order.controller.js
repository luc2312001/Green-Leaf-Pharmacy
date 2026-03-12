// backend/controllers/order.controller.js
// Order endpoint handlers

const OrderService = require("../services/order.service");
const CartService = require("../services/cart.service");

const OrderController = {
  async createOrder(req, res, next) {
    try {
      const userId = req.user?.id;
      const { shippingAddress, paymentMethod } = req.body;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      if (!shippingAddress || !paymentMethod) {
        const err = new Error("Shipping address and payment method are required");
        err.status = 400;
        throw err;
      }

      // Get cart items
      const cartItems = await CartService.getCart(userId);

      if (!cartItems || cartItems.length === 0) {
        const err = new Error("Cart is empty");
        err.status = 400;
        throw err;
      }

      // Calculate total
      const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);

      // Create order
      const order = await OrderService.createOrder(userId, {
        items: cartItems,
        shippingAddress,
        paymentMethod,
        total
      });

      // Clear cart
      await CartService.clearCart(userId);

      res.status(201).json({
        message: "Order created successfully",
        order
      });
    } catch (err) {
      next(err);
    }
  },

  async getOrders(req, res, next) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const orders = await OrderService.getOrders(userId);
      res.json(orders);
    } catch (err) {
      next(err);
    }
  },

  async getOrder(req, res, next) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const order = await OrderService.getOrderById(id);

      if (!order || order.userId !== userId) {
        const err = new Error("Order not found");
        err.status = 404;
        throw err;
      }

      res.json(order);
    } catch (err) {
      next(err);
    }
  }
};

module.exports = OrderController;
