-- Portfolio 2: Query Processing and Optimisation
-- Database: NaijaMart (PostgreSQL on Neon)

-- Query A: orders for one customer
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 12345;

CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Query B: delivered orders in the last 30 days
EXPLAIN ANALYZE
SELECT order_id, order_date FROM orders
WHERE status = 'delivered' AND order_date >= NOW() - INTERVAL '30 days';

CREATE INDEX idx_orders_status_date ON orders(status, order_date);

-- Query C: top 10 customers by total successful payments
EXPLAIN ANALYZE
SELECT c.customer_id, c.full_name, SUM(p.amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN payments p ON p.order_id = o.order_id
WHERE p.status = 'successful'
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;
