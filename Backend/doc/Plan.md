# Pharmacy Web App Plan

## Note

1. When *ask the server for retrival/ information* that means when loading the webpage, the webpage should be served and the webpage *javascript code* will ask server for more informations, items, boxes and load it into the webpage - And it should also be styled.

2. The code should be easily expandable, easily interagted with database. For example, for product, it had many attributes and all of the attributes should be easily change and interagtable without breaking the code. 

For example, product has Attribute list of [A1, A2, A3], if we add another attribute, A4, the attribute list of produts is [A1,A2,A3,A4] and it should not have any problem for the client to load and see that the product has 4 attributes with its associated name.

One solution for doing so would be to store the product-attribute and the product name to be loaded, example:
``` javascript
{
`<A1>`: `<A1 name to show in client's browser>`,
`<A2>`: `<A2 name to show in client's browser>`
}
```

So that the backend could use the attribute A1 of product, and the frontend could know what to show to the client without changing much. For example the product has attribute price, and that suppose price = 10.

```
price: Price
```

The backend query from the database the attribute price of the product and know that price = 10 and then the backend could tell the frontend to load the information that: please load Price=<price>=10 

For seperation of logic and data, it should be stored in another file like `setting.js`

## Style

- Green color palette, nature theme
- Soft, Modern UI

## Technology

Server: Node.js
Database: MSSQL
Frontend: Static HTML, CSS, JS

## View of the pharmacy page

### Customer's Static Pages 
> Project's Directory: './Frontend'

#### Index/Main page

> Web Dir: '/' -> return index.html.

The index.html include things to reference to : 
- Product page *Click to the tab page*
- Shopping card page *Click to the shopping card icon*
- Login / Account page *Click personal-icon*
- Advertisement: Some paied advertiment pop up *Ask the server for the advertisement in index page*
- About us *Click to tab page*
- Our Specialist *Click to tab page*
- Help with *Click to tab page*
- Our Department *Click to the tab page*

#### Product Page
> Web Dir: '/product' -> serve product.html

Include: 
- Product's Catagory Box:
    + Icon
    + Description
    + Subcategory
    *-> Click in and move to the subcategory of the product*

> Web Dir: '/product/<subcategory>' -> sever will route to serve

Include:
- Search bar: *For advance search 
    -> Click it and server will querry and return page
    Dir-request: /product/<subcategory>/search=<search-info>
    has advance search button*
- Advance Search: Pop-up window - slide down - Tick box *dynamic - will ask server to get advance search bar category*
- Page 1..n of products *Show m items for each page as product-box
    will ask the server to load it*
- Product-Box *Dynamic - Server will return m the product boxes and return page to customer*:
    + Image of the product
    + Price
    + View-detail *click view-detail -> move to that product page - Dynamic*

- End of page: `<pre page> [<pagenum>...] <next page>`, the page show top m products

#### Login - Account page
> Web Dir: '/login' -> serve login.html
- Basic username/password form to sign in -> authetication/cookie

Success-login or cookies auth:
> Web Dir: '/account' -> serve account.html
- Different tabs
    + Personal information: Image, Name, Address, Birthday *ask the server for retrieval*
    + My shopping-card *ask the server for retrieval*
    + My order *ask the server to retrieval*
    + My Discount *ask the server for the lists of discounts*

#### Shopping Card page

> Web Dir: '/shopping-card' -> serve shopping-card.html

Include:
- The list of shopping goods *ask the server for retrieval*:
    + remove button
    + number: with '- <number> +'
- `Buy` button which the server serve the page contain:
    + list of shopping lists
    + Cancle payment
    + Address Form
    + Name and Age form
    + Payment method list *ask the server for retrieval*


#### Our Specialist

> Web Dir: '/specialists' -> serve specialists.html

Include
- The list of boxes of specialists *ask the server for retreival*
When click to the box: direct to the page '/specialists/spec-id=<spec-id>'
*Dynamic - ask the server with information to load the page*

#### Help with

> Web Dir: '/help-with' -> serve help-with.html

Include:
- A form to fill in to help with customer's problem, consulting about the specific medicine or condition 

#### Our Department

> Web Dir: '/department' -> serve departments.html

Include:
- A list of boxes of department *ask the server for information*
- Search bar
- Advance search bar *Only visible if *

### Customer's Component Items

The component Items like products,..., which need the server serving the specific items in the database, and client's browser *javascript code* load the component inside the webpage.

The Items include:
    + Product-box on recommendation list of Product
    + Product specific page with dir '/product/<subcategory>/product-id=<product-id>'
    + Product list of shopping card
    + Specialist's information
    + Departments
    + ...

Provide the template (with style) to load the items

#### Product specific page
When the server serving the page of '/product/<subcategory>/product-id=<product-id>'. The architecture of the page is:
```
<Product-general-information> *Ask the server for information, Format like a list*
<Product-specific-information> *Ask the server for information, Format like a paper*
<Questions> *Ask the server for the information, lists of questions -> click, show one answer*
<Rating> *Ask the server for the rating, show as star ratign*
<Comment> *Ask the server for the information*
```

#### Specialist specific page
With access dir: '/specialists/spec-id=<spec-id>', show like the portfolio *ask the server for the information*

#### Department specific page
Access dir: '/departments/dept-id=<department-id>'

## Backend 

The backend use Node.js as server to serve webpage and perform business logic.

The should be 4 master components in the backend: Routes, Controllers, Authentication , DatabaseConnection

The backend has Routes to route the the web request to the Controller that solve the request and perform respond.

The Controllers purpose is to resolve the request and perform respond, also use the DatabaseConnection to store and retreive information. The Controllers is to control, all the service happens in different components *slave component of the controller* and the controllers uses the service to perform business logic. 

The backends also track cookies, authentication.

The DatabaseConnection has connection to the Database, it call the database to store and retrieve specific information.

## Architecture
```
Frontend
Backend
Docs
server.js
<requiement to install and run server>
README.md
```

The Frontend holding the static pharmacy's web page that will be load in customer's browser. The backend is holding
pharmacy's logic, routing, core, controllers,... The Docs is where the document belongs to.

`server.js` is to start the server, together with the installation requrement and the README.md

## Buiness Logic

### Adding to shopping cart and Buying logi

When users click on the buy to buy some products, it will add to the shopping cart *sent the information to the server to update shopping cart, should use the POST method with the information in the payment*

When users change the shopping cart, either buy changing the items on the cart or delete an item, it should notice the server *should use the POST method with payment is the change*

When the users click on the button pay *complete the payment in shopping*, it should notice the server *via POST with payment as information*
