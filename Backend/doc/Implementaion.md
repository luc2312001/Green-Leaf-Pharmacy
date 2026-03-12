Implementation of GreenLeaf Pharmacy

# Backend

> in "server.py"

Purpose: 
    - Entry point 
    - Set-up app 
    - Open port - listen request

> in "routes/index.py"

Purpose:
    - Page router *return pages to the client*

> in "route/api/<api>.js"

Purpose: Client send api to serve specific item from the server

> in "controllers/"

Purpose: Call the service

> in "services/"

Purpose: talk to the database

```javascript

!ProductService.<method>

// Get all products with optional filters -- Advance search
async function serachProducts(filters = {}) {/**/}

// Get product by ID with attributes to show
async function getProductDetailById(productId) {/**/}

// Get product's comment section by ID with attributes
async function getProductCommentsById(productId) {/**/}

// Get product's question by ID with attributes
async function getProductQuestionsById(productId) {/**/}

// Get ranges of products to show, can be sorted by name, by ID,...
// or default
async function getRangeProduct(start, end, sort_by) {/**/}

```

```javascript
!DepartmentService.<method>

// Advance Search for departments
async function getDepartments(filters = {}) {/**/}

// Get Department by ID
async function getDepartmentById(deptId) {

```

```javascript
!SpecialistService

async function getSpecialists(filters = {}) {/**/}

async function getSpecialistById(specialistId) {/**/}

```

```javascript
!OrderService

// Create the order of the users when paid 
async function createOrder(userId, orderData) {/**/}

// get the orders by UserID
async function getOrdersByUserID(userId) {/**/}

// get the orders by UserName
async function getOrdersByUserName(userId) {/**/}

async function getOrderById(orderId) {/**/}

async function updateOrderStatus(orderId, status) {/**/}
```

```javascript

!HelpService

async function createHelpRequest(data) {/**/}

async function getHelpRequests(userId) {/**/}

async function getHelpRequestById(requestId) {/**/}

```

```javascript

!CartService

async function getCart(userId) {/**/}

async function updateCartItem(userId, cartItemId, quantity) {/**/}

async function clearCart(userId) {/**/}

```
