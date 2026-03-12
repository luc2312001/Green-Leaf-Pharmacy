// backend/services/help.service.js
// Help/support request management

const db = require("../config/db");

const HelpService = {
    async createHelpRequest(data) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                /* const {...} = data; */
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

    async getHelpRequests(userId) {
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

    async getHelpRequestById(requestId) {
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

module.exports = HelpService;
