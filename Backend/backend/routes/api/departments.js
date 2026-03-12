// backend/routes/api/departments.js
// Department API routes

const router = require("express").Router();
const DepartmentController = require("../../controllers/department.controller");

// GET /api/departments - List departments
router.get("/", DepartmentController.listDepartments);

// GET /api/departments/:id - Get department by ID
router.get("/:id", DepartmentController.getDepartment);

module.exports = router;
