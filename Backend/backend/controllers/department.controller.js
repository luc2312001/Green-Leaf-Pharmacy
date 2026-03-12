// backend/controllers/department.controller.js
// Department endpoint handlers

const DepartmentService = require("../services/department.service");

const DepartmentController = {
  async listDepartments(req, res, next) {
    try {
      const { search } = req.query;

      const filters = {};
      if (search) filters.search = search;

      const departments = await DepartmentService.getDepartments(filters);
      res.json(departments);
    } catch (err) {
      next(err);
    }
  },

  async getDepartment(req, res, next) {
    try {
      const { id } = req.params;
      const department = await DepartmentService.getDepartmentById(id);

      if (!department) {
        const err = new Error("Department not found");
        err.status = 404;
        throw err;
      }

      res.json(department);
    } catch (err) {
      next(err);
    }
  }
};

module.exports = DepartmentController;
