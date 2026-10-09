# SQL Questions

The business questions answered in [`queries.sql`](queries.sql). Numbers match the query numbering in the file.


| # | Question | Concepts |
|---|----------|----------|
| 1 | What is the total revenue per restaurant, ranked highest to lowest? | multi-table JOIN, GROUP BY, SUM |
| 2 | Who are the top 10 customers by spend, with their order count and average order value? | JOIN, COUNT DISTINCT, LIMIT |
| 3 | What are the 5 best-selling menu items by quantity, and which restaurant sells them? | JOIN, aggregation |
| 4 | What is the average order value by cuisine and city? | grouped averages |
| 5 | Which customers have never placed an order? | NOT IN |
| 6 | Which menu items have never been ordered? | NOT IN |
| 7 | What are the monthly order counts and revenue? | DATE_FORMAT, GROUP BY |
| 8 | What percentage of each restaurant's orders falls into each status? | window function over aggregate |
| 9 | Which restaurants have an average order value above the overall average? | CTEs, scalar subquery |
| 10 | When are the peak ordering times by day of week and hour? | DAYNAME, HOUR |
| 11 | What is the average delivery time per restaurant? | TIMESTAMPDIFF, conditional filter |
| 12 | Do higher-rated restaurants earn more or deliver faster? | CASE WHEN |
| 13 | What are the top 3 items by revenue within each restaurant? | DENSE_RANK, PARTITION BY |
| 14 | What is the month-over-month revenue growth percentage? | LAG, CTE chain |
| 15 | What is the cumulative revenue per restaurant over time? | running SUM window |
| 16 | What is the 7-day moving average of daily orders? | window frame (RANGE INTERVAL) |

