 Portfolio 4: NoSQL and Advanced Data Models

Case study: NaijaMart, the same online store used in Portfolios 1 to 3.
NoSQL type: document database (MongoDB, hosted on MongoDB Atlas free tier).
Database: naijamart, with two collections: products and orders.

 Files
- products.json and orders.json: the documents inserted
- queries.txt: the four queries run
- Screenshots p4-1 to p4-7: evidence of the setup and the query results

 The model
Products: each product stores its own attributes inside the document. A phone has ram_gb and storage_gb, a shirt has size and material, and rice has weight_kg. Products with different attributes live in the same collection.

Orders: each order is one document that contains the customer details, the list of items, the payment and the delivery information. In PostgreSQL the same order was spread over four tables (orders, order_items, payments and customers).

 Queries and results
1. All electronics: returned 2 products (p4-4).
2. Products with at least 8 GB of RAM: returned the phone and the laptop only. The other products do not have a ram_gb field, so they are skipped without any special handling (p4-5).
3. All orders for customer 1: returned 2 orders (p4-6).
4. Total spent per customer, using an aggregation pipeline: customer 2 spent 520000 across 1 order and customer 1 spent 216500 across 2 orders (p4-7).

Challenges faced
My first insert failed with an "Unexpected token" error, because Atlas treated my whole list of products as one document. I fixed it by inserting the products one at a time. I checked that products showed 6 documents and orders showed 3, and inserted the data again into the right collections. This taught me to check the collection name and the document count after every insert.

Why a document database suits this
In MongoDB I could store each product with its own details inside the same document. The phone has RAM and storage, the shirt has size and material, and the rice has weight. In PostgreSQL I would need a lot of extra columns that stay empty for most products, or a separate table for every product type. The RAM query showed this well, because only the phone and the laptop came back and I did not have to do anything special for the other products. An order is also easier to read as one document, since the customer, the items, the payment and the delivery are all in one place instead of four tables.

Trade-offs compared with PostgreSQL 
The downside is that product names and customer details are copied into every order. If a product name changes, I would have to update many documents, while in PostgreSQL I change it once. I also saw in Portfolio 3 how transactions and CHECK constraints protected the stock and the payments. For money and stock I would still keep PostgreSQL, and use MongoDB for things like product catalogues where the data varies a lot.


