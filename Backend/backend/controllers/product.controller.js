// backend/controllers/product.controller.js
// Product endpoint handlers

const ProductService = require("../services/product.service");

SAFE_LIMIT = 10;

const ProductController = {
  async searchProducts(req, res, next) {
    try {
      const filters = req.query ;

      console.log(req.query);

      const products = await ProductService.searchProducts(filters);
      res.json(products);

      console.log(`Serving ${req.ip}:${req.socket.remotePort}: searchProducts`);  
      console.log(products)

    } catch (err) {
      next(err);
    }
  },

  async listProducts(req, res, next) {
    try {
      const page_num = req.query.pagenum || 0;
      const category = req.query.category || '1';
      const limit = req.query.limit || SAFE_LIMIT;
      const orderby = req.query.orderby || 'Ma_so_san_pham';

      const products = await ProductService.getRangeProducts(
                (page_num - 1) * limit, 
                limit,
                orderby,
                category
      );

      res.json(products);

      console.log(`Serving ${req.ip}:${req.socket.remotePort}: listProducts`);  
      console.log(products)

    } catch (err) {
      next(err);
    }
  },

  async getProduct(req, res, next) {
    try {

      console.log(`Serving ${req.ip}:${req.socket.remotePort}: getProducts`);  

      const { id } = req.params;
      const product = await ProductService.getProductDetailById(id);

      if (!product) {
        const err = new Error("Product not found");
        err.status = 404;
        throw err;
      }


      res.json(product);
    } catch (err) {
      next(err);
    }
  },

  async getProductQuestions(req, res, next) {
    try {

      console.log(`Serving ${req.ip}:${req.socket.remotePort}: getProductQuestions`);  

      const id = req.params.id;
      const questions = await ProductService.getProductQuestionsById(id);

      res.json(questions);

      console.log(questions);
    } catch (err) {
      next(err);
    }
  },

  async getProductAnswers(req, res, next) {
    try {
      console.log(`Serving ${req.ip}:${req.socket.remotePort}: getProductAnswers`);  

      const id = req.params.id;
      const stt = req.params.stt;
      const answers = await ProductService.getProductAnswersById(stt, id);

      res.json(answers);

      console.log(answers)
    } catch (err) {
      next(err);
    }
  },

};

module.exports = ProductController;
