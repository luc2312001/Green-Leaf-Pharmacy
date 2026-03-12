// backend/controllers/help.controller.js
// Help/support endpoint handlers

const HelpService = require("../services/help.service");

const HelpController = {
  async createHelpRequest(req, res, next) {
    try {
      const { name, email, subject, message } = req.body;
      const userId = req.user?.id;

      if (!name || !email || !subject || !message) {
        const err = new Error("Name, email, subject, and message are required");
        err.status = 400;
        throw err;
      }

      const request = await HelpService.createHelpRequest({
        name,
        email,
        subject,
        message,
        userId
      });

      res.status(201).json({
        message: "Help request submitted successfully",
        request
      });
    } catch (err) {
      next(err);
    }
  },

  async getHelpRequests(req, res, next) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const requests = await HelpService.getHelpRequests(userId);
      res.json(requests);
    } catch (err) {
      next(err);
    }
  },

  async getHelpRequest(req, res, next) {
    try {
      const userId = req.user?.id;
      const { id } = req.params;

      if (!userId) {
        const err = new Error("User not authenticated");
        err.status = 401;
        throw err;
      }

      const request = await HelpService.getHelpRequestById(id);

      if (!request || request.userId !== userId) {
        const err = new Error("Help request not found");
        err.status = 404;
        throw err;
      }

      res.json(request);
    } catch (err) {
      next(err);
    }
  }
};

module.exports = HelpController;
