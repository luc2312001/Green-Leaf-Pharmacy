// backend/middlewares/error.middleware.js
// Centralized error handling middleware

const errorHandler = (err, req, res, next) => {
  // Log error (but not sensitive data)
  console.error("Error:", {
    message: err.message,
    path: req.path,
    method: req.method,
    status: err.status || 500
  });

  // Default error response
  const status = err.status || 500;
  const message = err.message || "Internal Server Error";

  res.status(status).json({
    error: {
      status,
      message,
      ...(process.env.NODE_ENV === "development" && { details: err })
    }
  });
};

module.exports = errorHandler;
