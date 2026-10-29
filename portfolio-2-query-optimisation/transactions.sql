-- Portfolio 3: Transactions and Concurrency
-- Database: NaijaMart (PostgreSQL on Neon)

-- Step 1: Reset stock and check the starting state
UPDATE products SET stock_qty = 10 WHERE product_id = 1;
SELECT (SELECT stock_qty FROM products WHERE product_id = 1) AS stock_qty,
       (SELECT COUNT(*) FROM orders) AS order_count;

-- Step 2: A transaction that commits (place one order of 2 items)
BEGIN;
INSERT INTO orders(customer_id, status) VALUES (1, 'paid');
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
SELECT currval('orders_order_id_seq'), product_id, 2, price FROM products WHERE product_id = 1;
UPDATE products SET stock_qty = stock_qty - 2 WHERE product_id = 1;
INSERT INTO payments(order_id, amount, method, status, paid_at)
SELECT currval('orders_order_id_seq'), 2 * price, 'card', 'successful', NOW() FROM products WHERE product_id = 1;
COMMIT;

-- Check after commit
SELECT (SELECT stock_qty FROM products WHERE product_id = 1) AS stock_qty,
       (SELECT COUNT(*) FROM orders) AS order_count;

-- Step 3: A transaction that is rolled back
BEGIN;
UPDATE products SET stock_qty = stock_qty - 3 WHERE product_id = 1;
SELECT stock_qty FROM products WHERE product_id = 1;
ROLLBACK;
SELECT stock_qty FROM products WHERE product_id = 1;

-- Step 4: A failed order (stock cannot go below zero)
BEGIN;
INSERT INTO orders(customer_id, status) VALUES (1, 'paid');
UPDATE products SET stock_qty = stock_qty - 100 WHERE product_id = 1;
COMMIT;
-- This fails with a CHECK constraint error, so ROLLBACK is required
ROLLBACK;

-- Check after the failed order
SELECT (SELECT stock_qty FROM products WHERE product_id = 1) AS stock_qty,
       (SELECT COUNT(*) FROM orders) AS order_count;

-- Step 5: Concurrency test (run in two browser tabs)
-- Tab 1:
BEGIN;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 1;
SELECT pg_sleep(60);
COMMIT;

-- Tab 2 (run while Tab 1 is still sleeping, it waits for the lock):
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 1;

-- Final check
SELECT stock_qty FROM products WHERE product_id = 1;
SHOW transaction_isolation;
