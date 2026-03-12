// backend/config/db.js
// MSSQL database connection configuration

// user: process.env.DB_USER || "pharmacy_user",
//   password: process.env.DB_PASSWORD || "123456",
//   server: process.env.DB_SERVER || "localhost",
//   database: process.env.DB_NAME || "pharmacy",


const sql = require("mssql");
require("dotenv").config();

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  authentication: {
    type: "default"
  },
  options: {
    encrypt: false,
    trustServerCertificate: true
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

let pool;

const DatabaseConnection = {
  async connect() {
    try {
      pool = new sql.ConnectionPool(config);
      await pool.connect();
      console.log("Database connected successfully");
      return pool;
    } catch (err) {
      console.error("Database connection error:", err);
      throw err;
    }
  },

  async getConnection() {
    if (!pool) {
      await this.connect();
    }
    return pool;
  },

  async disconnect() {
    if (pool) {
      await pool.close();
      pool = null;
      console.log("Database disconnected");
    }
  },

  async executeQuery(query, params = {}) {
    try {
      const request = new sql.Request(await this.getConnection());

      // Bind parameters
      for (const [key, value] of Object.entries(params)) {
        request.input(key, value);
      }

      const result = await request.query(query);
      return result;
    } catch (err) {
      console.error("Query execution error:", err);
      throw err;
    }
  },

  async executeProcedure(query, params = {}) {
    try {
      const request = new sql.Request(await this.getConnection());

      // Bind parameters
      for (const [key, value] of Object.entries(params)) {
        request.input(key, value.type , value.value );
      }

      const result = await request.execute(query);
      return result;
    } catch (err) {
      console.error("Query execution error:", err);
      throw err;
    }
  }
};

module.exports = DatabaseConnection;
