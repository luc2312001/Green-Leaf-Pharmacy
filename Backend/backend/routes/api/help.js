// backend/routes/api/help.js
// Help/support API routes

const router = require("express").Router();
const HelpController = require("../../controllers/help.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

// POST /api/help - Create help request (unauthenticated)
router.post("/", HelpController.createHelpRequest);

// GET /api/help - Get user's help requests (authenticated)
router.get("/", authMiddleware, HelpController.getHelpRequests);

// GET /api/help/:id - Get specific help request (authenticated)
router.get("/:id", authMiddleware, HelpController.getHelpRequest);

module.exports = router;
