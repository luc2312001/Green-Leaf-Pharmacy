// backend/services/specialist.service.js
// Specialist management

const db = require("../config/db");

const SpecialistService = {

    async getSpecialists(filters = {}) {
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

    async getSpecialistById(specialistId) {
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
};

module.exports = SpecialistService;
