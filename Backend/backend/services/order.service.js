// backend/services/order.service.js
// Order management

const db = require("../config/db");

const OrderService = {
    
    // Create the order of the users when paid 
    async createOrder(userId, orderData) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    },

    // get the orders by which User
    async getOrdersByUserID(userId) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    },

    // get the orders by which User
    async getOrdersByUserName(userName) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    },

    async getOrderById(orderId) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    },

    async updateOrderStatus(orderId, status) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    }
};

module.exports = OrderService;
