// backend/controllers/auth.controller.js
// Authentication endpoint handlers

const AuthService = require("../services/auth.service");

const AuthController = {
  async register(req, res, next) {
    try {
      const { fullName,
        phone,
        gender,
        birthDate,
        email,
        password, } = req.body;

      if (!email || !password) {
        const err = new Error("Email and password are required");
        err.status = 400;
        throw err;
      }

      const user = await AuthService.registerUser({
        fullName,
        phone,
        gender,
        birthDate,
        email,
        password,
      });

      res.status(201).json({
        message: "User registered successfully",
        user
      });
    } catch (err) {
      next(err);
    }
  },

  async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        const err = new Error("Email and password are required");
        err.status = 400;
        throw err;
      }

      const { token, user } = await AuthService.loginUser(email, password);

      // Set cookie
      res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
        maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
      });

      res.json({
        message: "Login successful",
        token,
        user
      });
    } catch (err) {
      next(err);
    }
  },

  async logout(req, res, next) {
    try {
      res.clearCookie("token");
      res.json({ message: "Logged out successfully" });
    } catch (err) {
      next(err);
    }
  },

  async getMe(req, res, next) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const user = await AuthService.getUserById(userId);

      if (!user) {
        const err = new Error("User not found");
        err.status = 404;
        throw err;
      }

      res.json(user);
    } catch (err) {
      next(err);
    }
  },

  async updateProfile(req, res, next) {
    try {
      const userId = req.user?.id;
      const { name, phone, address } = req.body;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const user = await AuthService.updateUser(userId, {
        name,
        phone,
        address
      });

      res.json({
        message: "Profile updated successfully",
        user
      });
    } catch (err) {
      next(err);
    }
  }
};

module.exports = AuthController;
