// backend/services/auth.service.js
// Authentication and user management

const db = require("../config/db");
const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const validators = require("../utils/validators");

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  // In production we require a secret; in development warn but continue
  if ((process.env.NODE_ENV || "development") === "production") {
    throw new Error("JWT_SECRET environment variable is required in production");
  } else {
    console.warn("Warning: JWT_SECRET is not set. Using insecure default for development only.");
  }
}
function generateRandomId() {
  const random = Math.floor(1000000 + Math.random() * 9000000); // 7 số
  return "ND" + random;
}

const AuthService = {
  async generateUniqueUserId() {
    let newId;

    while (true) {
      newId = generateRandomId();

      const result = await db.executeQuery(
        "SELECT COUNT(*) AS total FROM NGUOI_DUNG WHERE Ma_so = @id",
        { id: newId }
      );


      if (result.recordset[0].total === 0) {
        break; // ID chưa tồn tại → dùng được
      }
    }

    return newId;
  },

  async registerUser(userData) {
    try {
      const { fullName,
        phone,
        gender,
        birthDate,
        email,
        password,
      } = userData;

      // Basic validation
      if (!validators.isValidEmail(email)) {
        const err = new Error("Invalid email format");
        err.status = 400;
        throw err;
      }

      if (!validators.isValidPassword(password)) {
        const err = new Error("Password must be at least 6 characters");
        err.status = 400;
        throw err;
      }

      // Check if user exists
      const checkQuery = "SELECT * FROM NGUOI_DUNG WHERE email = @email";
      const checkResult = await db.executeQuery(checkQuery, { email });
      if (checkResult.recordset.length > 0) {
        const err = new Error("User already exists");
        err.status = 409;
        throw err;
      }

      // Hash password
      const hashedPassword = await bcryptjs.hash(password, 10);
      const userId = await AuthService.generateUniqueUserId();
      // Insert user
      const insertQuery = `
        INSERT INTO NGUOI_DUNG (Ma_so, So_dien_thoai,Gioi_tinh,Ngay_sinh, email, Hash_key_password, Ho_va_ten)
        OUTPUT INSERTED.Ma_so
        VALUES (@id, @phone, @gender,@birthDate, @email, @password, @fullName)
      `;
      const result = await db.executeQuery(insertQuery, {
        id: userId,
        phone,
        gender,
        birthDate,
        email,
        password: hashedPassword,
        fullName,
      });

      return {
        id: userId, email, fullName: validators.sanitizeString(fullName), phone,
        gender,
        birthDate,
      };
    } catch (err) {
      console.error("Error registering user:", err);
      throw err;
    }
  },

  async loginUser(email, password) {
    try {
      if (!validators.isValidEmail(email)) {
        const err = new Error("Invalid credentials");
        err.status = 401;
        throw err;
      }

      const query = "SELECT * FROM NGUOI_DUNG WHERE email = @email";
      const result = await db.executeQuery(query, { email });

      if (result.recordset.length === 0) {
        const err = new Error("Invalid credentials");
        err.status = 401;
        throw err;
      }

      const user = result.recordset[0];
      const isValidPassword = await bcryptjs.compare(password, user.Hash_key_password);

      if (!isValidPassword) {
        const err = new Error("Invalid credentials");
        err.status = 401;
        throw err;
      }

      // Generate JWT token
      const secret = JWT_SECRET || "your-secret-key";
      const token = jwt.sign(
        { id: user.Ma_so, email: user.email, name: user.Ho_va_ten },
        secret,
        { expiresIn: "7d" }
      );

      return {
        token,
        user: {
          id: user.Ma_so,
          email: user.email,
          name: user.Ho_va_ten,
        }
      };
    } catch (err) {
      console.error("Error logging in user:", err);
      throw err;
    }
  },

  async getUserById(userId) {
    try {
      const query = `
        SELECT id, email, name, phone, address, createdAt
        FROM NGUOI_DUNG
        WHERE id = @id
      `;
      const result = await db.executeQuery(query, { id: userId });
      return result.recordset[0];
    } catch (err) {
      console.error("Error fetching user:", err);
      throw err;
    }
  },

  async updateUser(userId, userData) {
    try {
      const { name, phone, address } = userData;
      const query = `
        UPDATE NGUOI_DUNG
        SET name = @name, phone = @phone, address = @address
        WHERE id = @id
      `;
      await db.executeQuery(query, {
        id: userId,
        name: name || "",
        phone: phone || "",
        address: address || ""
      });

      return await this.getUserById(userId);
    } catch (err) {
      console.error("Error updating user:", err);
      throw err;
    }
  }
};

module.exports = AuthService;
