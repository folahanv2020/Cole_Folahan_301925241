 Portfolio 2: Query Processing and Optimisation

Database: NaijaMart (simulated online store) on PostgreSQL, hosted on Neon.

 Data
The tables were filled using seed_data.sql: 50,000 customers, 5,000 products, 200,000 orders and 400,000 order items. Proof is in p2-rowcounts.png.

 Files
- seed_data.sql: script that generates the data
- queries.sql: the three queries and the indexes created
- Screenshots: execution plans before and after each index

 Results

| Query | Index added | Before | After |
|-------|-------------|--------|-------|
| A: orders for one customer | idx_orders_customer on orders(customer_id) | 6.74 ms (Seq Scan) | 0.057 ms (Bitmap Index Scan) |
| B: delivered orders in the last 30 days | idx_orders_status_date on orders(status, order_date) | [time] ms ([scan type]) | [time] ms ([scan type]) |
| C: top 10 customers by spending | none helped | [time] ms | 267 ms (Seq Scans and Hash Joins) |

 Analysis
Query A: Without an index, PostgreSQL read all 200,000 rows of the orders table to find one customer's orders. After creating the index on customer_id, it went straight to the matching rows and the query ran about 118 times faster. PostgreSQL does not create indexes on foreign key columns automatically, so this index had to be added by hand.

Query B: Before the index, PostgreSQL used a parallel sequential scan and took 167 ms. After I created the index on orders(status, order_date), the plan changed to a bitmap index scan and the time dropped to 1.77 ms, about 94 times faster.

Query C: This query joins three tables and totals payments. Its plan used sequential scans and hash joins with and without the index, and the time stayed close to 267 ms. The query needs about 150,000 of the 200,000 orders, so reading the whole table is cheaper than using an index. Indexes help most when a query selects a small share of the rows.

Trade-off: indexes use extra storage and make inserts and updates slower, because each index must be updated too. I only added indexes on columns used often in filters and joins.


