// product.js - API for product-related requests
// Uses your axios instance
import api from "./axiosInstance";

/**
 * Get product list by category, page number, and limit
 * GET /api/products/list?pagenum=&category=&limit=
 *
 * @param {Object} params
 * @param {number} params.pagenum
 * @param {number} params.category
 * @param {number} params.limit
 */
export const listProducts = async ({ pagenum = 1, category = 1, limit = 6 }) => {
  const response = await api.get("/products/list", {
    params: {
      pagenum,
      category,
      limit,
    },
  });

  console.log(response.data)

  return { items: response.data, totalPages: 10 }; // expected: { items: [...], totalPages: N 

};

/**
 * Search products using multiple filters
 * GET /api/products/search?[query...]
 *
 * @param {Object} query - search parameters
 */
export const searchProducts = async (query = {}) => {
  const response = await api.get("/products/search", {
    params: query,
  });


  return { items: response.data, totalPages: 10 }; // expected: { items: [...], totalPages: N }
};

export const getDetail = async (id) => {
  const response = await api.get(`/products/${id}`);

  return response.data 
};

export const getQuestions = async (id) => {
  const response = await api.get(`/products/${id}/questions`);

  return response.data 
};

export const getAnswers = async (stt,id) => {
  const response = await api.get(`/products/${id}/answer/${stt}`);

  return response.data 
};

export default {
  listProducts,
  searchProducts,
  getDetail,
  getQuestions,
  getAnswers,
};
