 Portfolio 5: Distributed and Cloud Database Exercise

Case study: NaijaMart, the same online store used in Portfolios 1 to 4.

 Cloud deployment
 
The Neon project is on the free plan, hosted on AWS US East 2 (Ohio), with production as the default branch. The Atlas cluster, Cluster0, is on the free tier, hosted on AWS in one region, with backups and auto-scaling both switched off.

Both databases are in a single region, so if that region had an outage, the store would be unavailable. Backups being off on Atlas also means I could lose data if something went wrong. My Neon database is in Ohio, while customers of NaijaMart would be in Lagos, so every query travels a long way. For a real business I would choose a region closer to the users, turn backups on and keep copies in more than one place.

Sharding

Script: sharding_demo.sql. I split a copy of the orders table into three partitions using a hash of customer_id (p5-3a-sharding-setup.png). All 200,004 rows were copied in and spread across the three shards: orders_shard_0 holds 66,756 rows, orders_shard_1 holds 67,679 and orders_shard_2 holds 65,569 (p5-3b-shard-counts.png). A lookup for customer 12345 only read orders_shard_2 and did not touch the other two (p5-4-shard-lookup.png). That lookup still did a sequential scan inside the shard, because the demo table has no index, so an index on customer_id would make it faster again. This was done on a single Neon database, so it demonstrates the idea of sharding and is not a real multi-server setup.

If NaijaMart grew, customer_id would be a good shard key, because most queries ask about one customer's orders and customers are spread evenly. A bad key would be order status, because most orders would sit in a few shards.

 Replication and availability
 
 Replication means keeping copies of the same data on more than one server, so that if one server fails, another can take over. Both of my databases run in the cloud: Neon on AWS in Ohio, and MongoDB Atlas on AWS in one region. My Atlas page shows a free cluster in a single region with backups switched off. This means that if that region had a problem, NaijaMart would be down, and with backups off I could lose data. A real store would keep copies in more than one place and turn backups on. I also noticed that my Neon database is in Ohio while my customers would be in Lagos, so every query travels a long way. The two branches in my Neon project are copies for testing, not replicas for availability. From the Atlas documentation I learned that clusters are normally set up as replica sets, where one primary server takes the writes and the other servers keep copies 
 
  References
- Neon. About branching. https://neon.com/docs/introduction/branching (accessed 31 October 2026)
- MongoDB. Replica Set Members, MongoDB Manual. https://www.mongodb.com/docs/manual/core/replica-set-members/ (accessed 31 October 2026)
- PostgreSQL Global Development Group. Table Partitioning, PostgreSQL Documentation. https://www.postgresql.org/docs/current/ddl-partitioning.html (accessed 31 October 2026).

 Consistency

 Strong consistency means everyone reads the latest saved data. I saw this in Portfolio 3. After my order committed, the stock showed 8 straight away, and in the concurrency test the second buyer had to wait for the first, so no sale was lost. In a replicated MongoDB setup, a read from a secondary server can be slightly behind the primary, so someone might briefly see old data. This is called eventual consistency. For stock and payments I would choose strong consistency, because wrong stock could mean selling something that is not there, and wrong payment records cost real money. For the product catalogue, slightly old data is fine, because a new description showing a few seconds late harms nobody, and it lets the reads be spread across more servers.

 Lessons learned

The sharding demo made the idea clear to me. The orders split almost evenly into three shards (66,756, 67,679 and 65,569 rows), and a lookup for one customer only read one shard. It was only a demo on one database, so it shows the idea but not the real work of running several servers. Looking at my Neon and Atlas pages also showed me that free setups have real weaknesses, like a single region and backups turned off.

