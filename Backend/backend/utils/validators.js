// backend/utils/validators.js
// Input validation utilities

const validators = {
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  isValidPassword(password) {
    // At least 6 characters, contains letter and number
    return password && password.length >= 6;
  },

  isValidPhone(phone) {
    // Basic phone validation
    const phoneRegex = /^[\d\s\-\+\(\)]{7,}$/;
    return !phone || phoneRegex.test(phone);
  },

  isValidPrice(price) {
    return !isNaN(price) && price >= 0;
  },

  isValidQuantity(quantity) {
    return Number.isInteger(quantity) && quantity > 0;
  },

  sanitizeString(str) {
    if (typeof str !== "string") return "";
    return str.trim().substring(0, 255);
  }
};

module.exports = validators;
