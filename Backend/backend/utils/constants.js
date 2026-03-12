// backend/utils/constants.js
// Application constants

const PRODUCT_ATTRIBUTES = {
  price: "Price",
  stock: "Stock",
  description: "Description",
  category: "Category",
  department: "Department",
  rating: "Rating",
  expiry: "Expiry Date",
  manufacturer: "Manufacturer",
  barcode: "Barcode"
};

const PAYMENT_METHODS = ["cash", "credit-card", "debit-card", "e-wallet"];

const ORDER_STATUS = {
  pending: "Pending",
  confirmed: "Confirmed",
  processing: "Processing",
  shipped: "Shipped",
  delivered: "Delivered",
  cancelled: "Cancelled"
};

const HELP_REQUEST_STATUS = {
  pending: "Pending",
  in_progress: "In Progress",
  resolved: "Resolved",
  closed: "Closed"
};

module.exports = {
  PRODUCT_ATTRIBUTES,
  PAYMENT_METHODS,
  ORDER_STATUS,
  HELP_REQUEST_STATUS
};
