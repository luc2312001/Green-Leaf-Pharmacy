// backend/services/product.service.js
// Product-related business logic

const sql = require("mssql");

const db = require("../config/db");

const ProductService = {

    // Get all products with optional filters -- Advance search
    async searchProducts(filters = {}) {
        if (process.env.USE_DATABASE === "true")
        {
            try {
                
                /* TODO: write SQL Querry in query, params 
                 * */

             const {
                    key_word,
                    ten_danh_muc,
                    gia_toi_thieu,
                    gia_toi_da,
                    doi_tuong_su_dung,
                    chi_dinh,
                    loai_thuoc,
                    loai_da,
                    mui_huong,
                    nuoc_san_xuat,
                    ten_thuong_hieu,
                    xuat_xu_thuong_hieu,
                    sort_by,
                    pagenum,
                    pagesize
                } = filters;

                const trimCheck = (p) => {
                    if ( typeof(p) === "string" && p.trim() === "" )
                        return null;
                    return p;
                }

                const proc = `sp_SearchSanPham`;        
                const params = {
        'Key_word': { type: sql.NVarChar(200), value: trimCheck(key_word) },
        'Ten_danh_muc': { type: sql.NVarChar(100), value: trimCheck(ten_danh_muc) },
        'Gia_toi_thieu' : { type: sql.Decimal(18,2) , value: trimCheck(gia_toi_thieu) }, // adjust TIEN_TYPE mapping
        'Gia_toi_da' : { type: sql.Decimal(10,2) , value: trimCheck(gia_toi_da)},
        'Doi_tuong_su_dung' : { type: sql.NVarChar(100) , value: trimCheck(doi_tuong_su_dung) },
        'Chi_dinh' : { type: sql.NVarChar(100) , value: trimCheck(chi_dinh) },
        'Loai_thuoc' : { type: sql.Int , value: trimCheck(loai_thuoc) },
        'Loai_da' : { type: sql.NVarChar(100) , value: trimCheck(loai_da) },
        'Mui_huong' : { type: sql.NVarChar(100) , value: trimCheck(mui_huong) },
        'Nuoc_san_xuat' : { type: sql.NVarChar(100) , value: trimCheck(nuoc_san_xuat) } ,
        'Ten_thuong_hieu' : { type: sql.NVarChar(100) , value: trimCheck(ten_thuong_hieu) } ,
        'Xuat_xu_thuong_hieu' : { type: sql.NVarChar(100) , value: trimCheck(xuat_xu_thuong_hieu) },
        'SortBy' : { type: sql.NVarChar(20) , value: trimCheck(sort_by) },
        'PageNumber' : { type: sql.Int , value: trimCheck(pagenum) },
        'PageSize' : { type: sql.Int , value: trimCheck(pagesize) }, 
                };

                const result = await db.executeProcedure(proc, params);
                return result.recordset.map(
  ({ Ma_so_san_pham, Ten_san_pham, Gia_tien, Loai_san_pham, Don_vi_tinh, Trang_thai }) => ({
    Ma_so_san_pham,
    Ten_san_pham,
    Gia_tien,
    Loai_san_pham,
    Don_vi_tinh,
    Trang_thai
  })
);
            } catch (err) {
                console.error("Error fetching products:", err);
                throw err;
            }
        }
        else if (process.env.USE_SAMPLE === "true")
        {
            /*TODO: Write Sample Data*/

            const sampleData = [
                {
                    Ma_so_san_pham: "SP001",
                    Ten_san_pham: "Bánh mì",
                    Gia_tien: 15000,
                    Loai_san_pham: "Thực phẩm",
                    Don_vi_tinh: "Cái",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP002",
                    Ten_san_pham: "Sữa tươi",
                    Gia_tien: 25000,
                    Loai_san_pham: "Đồ uống",
                    Don_vi_tinh: "Hộp",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP003",
                    Ten_san_pham: "Áo thun",
                    Gia_tien: 120000,
                    Loai_san_pham: "Thời trang",
                    Don_vi_tinh: "Chiếc",
                    Trang_thai: "Hết hàng"
                },
                {
                    Ma_so_san_pham: "SP004",
                    Ten_san_pham: "Laptop Dell",
                    Gia_tien: 15000000,
                    Loai_san_pham: "Điện tử",
                    Don_vi_tinh: "Cái",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP005",
                    Ten_san_pham: "Nước ngọt Coca-Cola",
                    Gia_tien: 10000,
                    Loai_san_pham: "Đồ uống",
                    Don_vi_tinh: "Lon",
                    Trang_thai: "Còn hàng"
                }
            ];

            return sampleData; 
        }

    },

    // Get product by ID with attributes
    async getProductDetailById(productID) {

        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try { 
                const proc = `PROC_GET_SAN_PHAM`;        
                const params = { Ma_so_san_pham : { type: sql.Char(9) , value: productID }};
                const result = await db.executeProcedure(proc, params);
                return result.recordset[0];
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /* TODO: Write Sample Data */ 
        }
    },

    // Get product by ID with attributes
    async getProductQuestionsById(productID) {

        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = `SELECT *
                               FROM CAU_HOI 
                               WHERE Ma_so_san_pham = @productID;`;
                const params = {productID: productID};
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /*TODO: Write Sample Data */ 
        }
    },

    async getProductAnswersById(stt,productID) {

        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {
                const query = `SELECT *
                               FROM CAU_TRA_LOI 
                               WHERE Ma_so_san_pham = @productID 
                                    AND So_thu_tu = @stt`;
                const params = { productID: productID, stt: stt };
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /*TODO: Write Sample Data */ 
        }
    },
    
    // Get ranges of products to show, can be sorted by name, by ID,...
    // or default
    async getRangeProducts(start, pagesize, order_by, category) {

        console.log(`start: ${start}, pagesize: ${pagesize}`)

        if (process.env.USE_DATABASE === "true") {
            /* TODO: Write Querry */
            try {

                const fil_ode = (o) => {
                    if (o === undefined || o === null)
                        return 'Ma_so_san_pham';
                    return o;
                }

                const query = `SELECT Ma_so_san_pham, Ten_san_pham, Gia_tien, Loai_san_pham, Don_vi_tinh, Trang_thai 
                               FROM SAN_PHAM
                               WHERE Loai_san_pham = @category
                               ORDER BY ${fil_ode(order_by)}
                               OFFSET ${start} ROWS 
                               FETCH NEXT ${pagesize} ROWS ONLY;`;
                const params = { category : category ,start: start, pagesize: pagesize};
                const result = await db.executeQuery(query, params);
                return result.recordset;
            } catch (err) {
                console.error("Error fetching product:", err);
                throw err;
            }
        } else if (process.env.USE_SAMPLE === "true"){
           /*TODO: Write Sample Data */ 

            // Sample data for SELECT Ma_so_san_pham, Ten_san_pham, Gia_tien, Loai_san_pham, Don_vi_tinh, Trang_thai FROM FILTER_SP;

            const sampleData = [
                {
                    Ma_so_san_pham: "SP001",
                    Ten_san_pham: "Bánh mì",
                    Gia_tien: 15000,
                    Loai_san_pham: "Thực phẩm",
                    Don_vi_tinh: "Cái",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP002",
                    Ten_san_pham: "Sữa tươi",
                    Gia_tien: 25000,
                    Loai_san_pham: "Đồ uống",
                    Don_vi_tinh: "Hộp",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP003",
                    Ten_san_pham: "Áo thun",
                    Gia_tien: 120000,
                    Loai_san_pham: "Thời trang",
                    Don_vi_tinh: "Chiếc",
                    Trang_thai: "Hết hàng"
                },
                {
                    Ma_so_san_pham: "SP004",
                    Ten_san_pham: "Laptop Dell",
                    Gia_tien: 15000000,
                    Loai_san_pham: "Điện tử",
                    Don_vi_tinh: "Cái",
                    Trang_thai: "Còn hàng"
                },
                {
                    Ma_so_san_pham: "SP005",
                    Ten_san_pham: "Nước ngọt Coca-Cola",
                    Gia_tien: 10000,
                    Loai_san_pham: "Đồ uống",
                    Don_vi_tinh: "Lon",
                    Trang_thai: "Còn hàng"
                }
            ];

            return sampleData;

        }
    },

    // Get related products
    // Noise code
    async getRelatedProducts(productId, limit = 5) {
        try {
            const product = await this.getProductById(productId);
            if (!product) return [];

            let safeLimit = parseInt(limit, 10) || 5;
            safeLimit = Math.max(1, Math.min(50, safeLimit));

            const query = `
SELECT TOP ${safeLimit} * FROM Products 
WHERE category = @category AND id != @id
ORDER BY rating DESC
`;
            const result = await db.executeQuery(query, {
                category: product.category,
                id: productId
            });
            return result.recordset;
        } catch (err) {
            console.error("Error fetching related products:", err);
            throw err;
        }
    }
};

module.exports = ProductService;
