// backend/routes/api/index.js
// Main API router - mounts all API routes

const router = require("express").Router();

// Mount API routes
router.use("/products", require("./products"));
router.use("/auth", require("./auth"));
router.use("/cart", require("./cart"));
router.use("/orders", require("./orders"));
router.use("/specialists", require("./specialists"));
router.use("/departments", require("./departments"));
router.use("/help-with", require("./help"));

// Health check endpoint
router.get("/health", (req, res) => {
  res.json({ status: "ok", message: "API is running" });
});

module.exports = router;
