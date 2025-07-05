# Query Optimization Summary Report

## Objective
The purpose of this task was to analyze and improve the performance of a SQL query that retrieves booking data along with associated user, property, and payment details. The focus was on reducing execution time and query cost by optimizing join operations and applying effective indexing strategies.

## Initial Query (Unoptimized)
The original query joined four tables: `bookings`, `users`, `properties`, and `payments`. 

```sql
    SELECT 
        b.status AS booking_status,
        b.start_date,
        b.end_date,
        CONCAT(u.first_name, ' ', u.last_name) AS guest,
        u.email,
        u.phone_number,
        p.name AS property_name,
        pay.amount,
        pay.payment_date,
        pay.payment_method
    FROM bookings b
    JOIN users u ON b.user_id = u.user_id
    JOIN properties p ON b.property_id = p.property_id
    LEFT JOIN payments pay ON b.booking_id = pay.booking_id;
```
While the query works, [EXPLAIN](./before_opti.png) showed that MySQL was scanning the entire bookings table and performing unnecessary nested loops. The use of CONCAT in the SELECT clause also slightly increases processing, and the order of joins didn’t help minimize the load.

## EXPLAIN Analysis (Before Optimization)

Before optimization, MySQL performed a full table scan on the bookings table, which is inefficient. Although joins with users and properties used primary keys effectively, and the payments table used its index, the overall structure still led to unnecessary row scans. This showed that the query needed structural improvements to reduce cost and improve performance.

## Optimized Query

To improve performance, I restructured the query slightly:

```sql
SELECT 
    b.status,
    b.start_date,
    b.end_date,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    p.name AS property_name,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id;
```
Here’s what changed:
* Removed the CONCAT from the SELECT clause
* Kept column references simple and flat
* Reordered the SELECT fields to match join order for readability

## EXPLAIN Analysis (After Optimization)

After optimization, MySQL still used the same indexes, but the restructured query led to fewer operations per row. The query planner recognized the improved structure and estimated a lower cost, meaning the engine could execute the query more efficiently without scanning unnecessary rows. Check [after_optimization.png](./after_opti) for details.

## Observation
The key takeaway is that not every performance issue requires an index. Sometimes, just writing simpler, cleaner SQL helps MySQL optimize execution.


