// backend/controllers/cart.controller.js
// Shopping cart endpoint handlers

const CartService = require("../services/cart.service");

const CartController = {
  async getCart(req, res, next) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const items = await CartService.getCart(userId);
      res.json(items);
    } catch (err) {
      next(err);
    }
  },

  async addToCart(req, res, next) {
    try {
      const userId = req.user?.id;
      const { productId, quantity = 1 } = req.body;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      if (!productId) {
        const err = new Error("Product ID is required");
        err.status = 400;
        throw err;
      }

      const cart = await CartService.addToCart(userId, productId, quantity);
      res.json({
        message: "Item added to cart",
        cart
      });
    } catch (err) {
      next(err);
    }
  },

  async updateCart(req, res, next) {
    try {
      const userId = req.user?.id;
      const { id, quantity } = req.body;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      if (!id || quantity === undefined) {
        const err = new Error("Cart item ID and quantity are required");
        err.status = 400;
        throw err;
      }

      const cart = await CartService.updateCartItem(userId, id, quantity);
      res.json({
        message: "Cart updated",
        cart
      });
    } catch (err) {
      next(err);
    }
  },

  async removeFromCart(req, res, next) {
    try {
      const userId = req.user?.id;
      const { id } = req.body;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      if (!id) {
        const err = new Error("Cart item ID is required");
        err.status = 400;
        throw err;
      }

      const cart = await CartService.removeFromCart(userId, id);
      res.json({
        message: "Item removed from cart",
        cart
      });
    } catch (err) {
      next(err);
    }
  },

  async clearCart(req, res, next) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      await CartService.clearCart(userId);
      res.json({ message: "Cart cleared" });
    } catch (err) {
      next(err);
    }
  }
};

module.exports = CartController;
