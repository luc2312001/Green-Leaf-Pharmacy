// backend/controllers/specialist.controller.js
// Specialist endpoint handlers

const SpecialistService = require("../services/specialist.service");

const SpecialistController = {
  async listSpecialists(req, res, next) {
    try {
      const { department, search } = req.query;

      const filters = {};
      if (department) filters.department = department;
      if (search) filters.search = search;

      const specialists = await SpecialistService.getSpecialists(filters);
      res.json(specialists);
    } catch (err) {
      next(err);
    }
  },

  async getSpecialist(req, res, next) {
    try {
      const { id } = req.params;
      const specialist = await SpecialistService.getSpecialistById(id);

      if (!specialist) {
        const err = new Error("Specialist not found");
        err.status = 404;
        throw err;
      }

      res.json(specialist);
    } catch (err) {
      next(err);
    }
  },

  async getDepartments(req, res, next) {
    try {
      const departments = await SpecialistService.getDepartments();
      res.json(departments);
    } catch (err) {
      next(err);
    }
  }
};

module.exports = SpecialistController;
