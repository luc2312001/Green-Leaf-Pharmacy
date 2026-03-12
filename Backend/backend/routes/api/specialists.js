// backend/routes/api/specialists.js
// Specialist API routes

const router = require("express").Router();
const SpecialistController = require("../../controllers/specialist.controller");

// GET /api/specialists - List specialists
router.get("/", SpecialistController.listSpecialists);

// GET /api/specialists/:id - Get specialist by ID
router.get("/:id", SpecialistController.getSpecialist);

module.exports = router;
