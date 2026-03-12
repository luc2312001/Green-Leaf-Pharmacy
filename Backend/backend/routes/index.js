/* GreenLeaf Index.js route
 * File: backend/routes/index.js
 * Route to the page of the pharmacy to the client 
 *  - Page router - serves frontend HTML pages and manages page routes
 * */

const path = require("path");
const router = require("express").Router();

const frontendPath = path.join(__dirname, "../../frontend");

// Serve static pages

router.get("/", (req, res) => {
    res.sendFile(path.join(frontendPath, "index.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: index.html`);  
});

router.get("/product", (req, res) => {
    res.sendFile(path.join(frontendPath, "product.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: product.html`);  
});

router.get("/shopping-card", (req, res) => {
    res.sendFile(path.join(frontendPath, "shopping-card.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: shopping-card.html`);  
});

router.get("/login", (req, res) => {
    res.sendFile(path.join(frontendPath, "login.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: login.html`);  
});

router.get("/account", (req, res) => {
    res.sendFile(path.join(frontendPath, "account.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: account.html`);  
});

router.get("/specialists", (req, res) => {
    res.sendFile(path.join(frontendPath, "specialists.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: specialists.html`);  
});

router.get("/department", (req, res) => {
    res.sendFile(path.join(frontendPath, "department.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: department.html`);  
});

router.get("/help-with", (req, res) => {
    res.sendFile(path.join(frontendPath, "help-with.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: help-with.html`);  
});

router.get("/about", (req, res) => {
    res.sendFile(path.join(frontendPath, "about.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: about.html`);  
});

//Dynamic page

router.get("/product/:subcategory", (req, res) => {
    res.sendFile(path.join(frontendPath, "product.html"));
});

router.get("/product/:subcategory/product-id=:productId", (req, res) => {
    res.sendFile(path.join(frontendPath, "product-detail.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: product-detail.html`);  
});

router.get("/specialists/spec-id=:specId", (req, res) => {
    // Load specialist detail page (can reuse specialists.html with JS handling)
    res.sendFile(path.join(frontendPath, "specialists.html"));
});

router.get("/departments/dept-id=:deptId", (req, res) => {
    // Load department detail page
    res.sendFile(path.join(frontendPath, "department.html"));
});

// Fallback to index

router.use((req, res) => {
    res.sendFile(path.join(frontendPath, "index.html"));
    console.log(`Serving ${req.ip}:${req.socket.remotePort}: index.html`);  
});

module.exports = router;
