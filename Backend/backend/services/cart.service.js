// backend/services/cart.service.js
// Shopping cart management

const db = require("../config/db");

const CartService = {

    async getCart(userId) {
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

    async addToCart(userId, productId, quantity = 1) {
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

    async updateCartItem(userId, cartItemId, quantity) {
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

    async removeFromCart(userId, cartItemId) {
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

    async clearCart(userId) {
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

module.exports = CartService;
