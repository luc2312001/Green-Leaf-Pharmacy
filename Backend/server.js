/*
 * GreenLeaf Pharmacy Entry point server
 * The entry-point server.py only setup neccessary application
 *      - Init app
 *      - Listen request
 * */


// server.js
// Main application entry point

require("dotenv").config();
const express = require("express"); // Express Application
const path = require("path"); // Node native library
const cookieParser = require("cookie-parser");
const helmet = require("helmet"); // Protect Expression Application - Middleware

// Temporary Unused
const cors = require("cors"); // Cross-Origin Resource Sharing  

//Route
const apiRouter = require("./backend/routes/api");
const pageRouter = require("./backend/routes/index");
// error middleware
const errorMiddleware = require("./backend/middlewares/error.middleware");
// database connection
const db = require("./backend/config/db");

// Initiate app express
const app = express();


app.use(cors({
    origin: "http://localhost:5173",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));
// === Set up Middlewares ===
app.use(helmet());

/*
app.use(cors({
  origin: process.env.CORS_ORIGIN || "http://localhost:3000",
  credentials: true
}));
*/

// == Setup Parser ==

app.use(express.json());

app.use(express.urlencoded({ extended: true }));

app.use(cookieParser());

// === Serve static frontend ===
app.use(express.static(path.join(__dirname, "frontend")));

// === Routes ===

// API Route
app.use(process.env.API_PREFIX, apiRouter);

// Page Route
app.use("/", pageRouter);

// === Error Handler ===
app.use(errorMiddleware);

// === Start Server ===
const PORT = process.env.PORT || 3000;
const HOST = process.env.IP_HOST || '127.0.0.1'

// Initialize database and start server
async function startServer() {
    try {
        // Connect to database
        if (process.env.USE_DATABASE === "true") {
            await db.connect();
            console.log("Database connection established");
        }

        // Start HTTP server
        const server = app.listen(PORT, HOST, () => {
            console.log(`✓ Server running on http://${HOST}:${PORT} \n`);
            console.log(`✓ API available at http://${HOST}:${PORT}/api \n`);
            console.log(`✓ Environment: ${process.env.NODE_ENV || ""} \n`);
        });

        // Graceful shutdown
        process.on("SIGINT", async () => {
            console.log("Shutting down gracefully... \n");
            server.close(async () => {
                if (process.env.USE_DATABASE == "true")
                    await db.disconnect();
                process.exit(0);
            });
        });

    }
    catch (err) {
        console.error("Failed to start server:", err);
        process.exit(1);
    }
}

startServer();
