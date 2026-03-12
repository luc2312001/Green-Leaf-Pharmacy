// backend/middlewares/auth.middleware.js
// JWT authentication middleware

const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;

const authMiddleware = (req, res, next) => {
  try {
    // Extract token from cookie
    const token = req.cookies?.token;

    if (!token) {
      const err = new Error("No authentication token provided");
      err.status = 401;
      return next(err);
    }

    if (!JWT_SECRET && (process.env.NODE_ENV || "development") === "production") {
      const err = new Error("Authentication misconfigured: JWT_SECRET not set");
      err.status = 500;
      return next(err);
    }

    // Verify token
    const secret = JWT_SECRET || "your-secret-key";
    const decoded = jwt.verify(token, secret);
    req.user = decoded;
    next();
  } catch (err) {
    err.status = 401;
    err.message = "Invalid or expired token";
    next(err);
  }
};

module.exports = authMiddleware;
