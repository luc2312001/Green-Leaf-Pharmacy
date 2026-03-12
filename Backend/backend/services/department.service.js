// backend/services/department.service.js
// Department management

const db = require("../config/db");

const DepartmentService = {

    // Advance Search for departments
    async getDepartments(filters = {}) {
        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = ``;
                const param = ``;
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching departments:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
            /* TODO: Write Sample Data */ 
        }
    },

    // Get Department by ID
    async getDepartmentById(deptId) {
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

module.exports = DepartmentService;
