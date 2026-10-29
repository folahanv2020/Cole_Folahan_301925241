 Portfolio 3: Transactions and Concurrency

Database: NaijaMart (simulated online store) on PostgreSQL, hosted on Neon.
Script: transactions.sql

 Why transactions matter here
Placing an order takes four steps: create the order, add the order item, reduce the stock, and record the payment. These must all succeed or all fail. A transaction groups them together using BEGIN, COMMIT and ROLLBACK.

 Evidence

1. Starting state (p3-1-start.png): stock was reset to 10. The order count was 200003.

2. Commit (p3-2-commit.png): one order of 2 items was placed in a single transaction. Stock dropped from 10 to 8 and the order count rose by exactly one, to 200004.

3. Rollback (p3-3a-rollback-inside.png and p3-3b-rollback-after.png): inside the transaction the stock showed 5. After ROLLBACK it returned to 8, so the change was undone.

4. Failed order (p3-4a-failure.png and p3-4b-failure-check.png): an order for 100 items broke the rule that stock cannot be negative, so PostgreSQL returned a CHECK constraint error. After ROLLBACK, the stock was still 8 and the order count was still 200004. The new order row was not saved either, so no half-finished order was left behind.

5. Concurrency (p3-5a-concurrency-waiting.png and p3-5b-concurrency-result.png): two sessions tried to reduce the stock of the same product at the same time. The second session waited until the first one committed. The final stock was 6, so both sales counted and neither was lost. The isolation level shown is read committed, which is the PostgreSQL default.

 Explanation
This portfolio showed me that a transaction is what protects the data when something goes wrong halfway. The most useful moment was the failed order. When I tried to buy 100 items, PostgreSQL rejected it, and in Neon I had to click ROLLBACK before I could run anything else. After that, the stock and the order count were unchanged, so nothing half finished was saved.
I also made mistakes along the way. I ran the order transaction more than once, so my order count was not what I expected, and my stock ended up at 2 after repeating the concurrency test several times. I fixed this by resetting the stock to a known number before each test and running each test once. For the concurrency test, I had to add a 60 second pause in the first tab before the second tab had time to show the waiting behaviour.
One thing that surprised me was seeing order numbers skip. I learned that PostgreSQL does not reuse a number when a transaction fails or rolls back, so a gap in the numbers is normal.
ACID stands for atomicity, consistency, isolation and durability. Placing an order needs a transaction because it changes four tables, and a failure in the middle would leave an order with no payment or the wrong stock. With BEGIN and COMMIT, either all four changes are saved or none are. In the concurrency test, PostgreSQL locked the product row while the first session was updating it, so the second session had to wait. This stopped one sale from overwriting the other, and the final stock was correct.

## Lessons learned[Write 2 or 3 sentences in your own words. For example, what surprised you, or what went wrong while testing and how you fixed it.]
