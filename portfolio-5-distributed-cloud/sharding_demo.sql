-- Portfolio 5: Sharding demonstration (PostgreSQL on Neon)
-- Hash partitioning on one database to show the idea of sharding

CREATE TABLE orders_sharded (LIKE orders INCLUDING DEFAULTS) PARTITION BY HASH (customer_id);

CREATE TABLE orders_shard_0 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 0);
CREATE TABLE orders_shard_1 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 1);
CREATE TABLE orders_shard_2 PARTITION OF orders_sharded FOR VALUES WITH (MODULUS 3, REMAINDER 2);

INSERT INTO orders_sharded SELECT * FROM orders;

-- How the rows were spread across the shards
SELECT tableoid::regclass AS shard, COUNT(*) AS rows_in_shard
FROM orders_sharded GROUP BY 1 ORDER BY 1;

-- A lookup for one customer reads only one shard
EXPLAIN SELECT * FROM orders_sharded WHERE customer_id = 12345;
