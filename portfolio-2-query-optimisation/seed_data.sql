-- Portfolio 2: Seed data for NaijaMart
-- Creates about 50,000 customers, 5,000 products, 200,000 orders,
-- 400,000 order items and 200,000 payments.

INSERT INTO categories(name) VALUES
('Electronics'),('Fashion'),('Groceries'),('Home'),('Beauty');

INSERT INTO customers(full_name, email, phone, city, created_at)
SELECT 'Customer ' || g,
       'customer' || g || '@naijamart.test',
       '080' || lpad((random()*99999999)::int::text, 8, '0'),
       (ARRAY['Lagos','Abuja','Ibadan','Port Harcourt','Kano','Enugu'])[1 + (random()*5)::int],
       NOW() - make_interval(days => (random()*730)::int)
FROM generate_series(1, 50000) g;

INSERT INTO products(category_id, name, price, stock_qty)
SELECT 1 + (g % 5),
       'Product ' || g,
       round((500 + random()*199500)::numeric, 2),
       (random()*500)::int
FROM generate_series(1, 5000) g;

INSERT INTO orders(customer_id, order_date, status)
SELECT 1 + (random()*49999)::int,
       NOW() - make_interval(days => (random()*365)::int),
       (ARRAY['pending','paid','shipped','delivered','cancelled'])[1 + (random()*4)::int]
FROM generate_series(1, 200000);

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, 1 + (random()*4)::int, p.price
FROM orders o
CROSS JOIN LATERAL (VALUES (1 + (o.order_id % 5000)), (1 + ((o.order_id + 2500) % 5000))) v(pid)
JOIN products p ON p.product_id = v.pid;

INSERT INTO payments(order_id, amount, method, status, paid_at)
SELECT o.order_id,
       SUM(oi.quantity * oi.unit_price),
       (ARRAY['card','transfer','cash_on_delivery'])[1 + (random()*2)::int],
       CASE WHEN o.status = 'cancelled' THEN 'failed'
            WHEN o.status = 'pending' THEN 'pending'
            ELSE 'successful' END,
       CASE WHEN o.status IN ('paid','shipped','delivered') THEN o.order_date END
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.status, o.order_date;

ANALYZE;
