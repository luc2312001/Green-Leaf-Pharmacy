// backend/routes/api/auth.js
// Authentication API routes

const router = require("express").Router();
const AuthController = require("../../controllers/auth.controller");
const authMiddleware = require("../../middlewares/auth.middleware");
const { verifyToken } = require("../../middlewares/authMiddleware");

// POST /api/auth/register - Register user
router.post("/register", AuthController.register);

// POST /api/auth/login - Login user
router.post("/login", AuthController.login);

// POST /api/auth/logout - Logout user
router.post("/logout", authMiddleware, AuthController.logout);

// GET /api/auth/me - Get current user
router.get("/me", authMiddleware, AuthController.getMe);

// PUT /api/auth/profile - Update user profile
router.put("/profile", authMiddleware, AuthController.updateProfile);

router.get("/verifySession", verifyToken, async (req, res) => {
    try {
        // req.user được lấy từ token decode
        return res.json({
            valid: true,
            user: req.user, // FE sẽ set user từ đây
        });
    } catch (err) {
        return res.status(500).json({ message: "Server error" });
    }
});

module.exports = router;
