# Query Optimization Summary Report

## Objective

The purpose of this task was to analyze and improve the performance of a SQL query that retrieves booking data along with associated user, property, and payment details. The focus was on reducing execution time and query cost by optimizing join operations, simplifying the query structure, and applying effective indexing strategies where needed.

---

## Initial Query (Unoptimized)

The original query joined four tables: `bookings`, `users`, `properties`, and `payments`. It was functional, but performance analysis using `EXPLAIN` revealed inefficiencies.

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

While this query returned the correct data, [EXPLAIN](./before_optimization.JPG) showed that MySQL was scanning the entire `bookings` table and using nested loop joins. The use of `CONCAT` added minor processing overhead, and the joins while logically structured could be simplified for performance and readability.

---

## EXPLAIN Analysis (Before Optimization)

Before optimization, MySQL performed a **full table scan** on the `bookings` table. Although joins with `users` and `properties` used primary keys effectively, the overall query still scanned more rows than necessary. If an index on `payments.booking_id` was present, MySQL likely used it, which helped that part of the query. However, the combination of wide SELECT fields and row-wise operations led to high cost.

---

## Optimized Query

To improve performance, I refactored the query with the following changes:

* Removed `CONCAT` to avoid inline formatting at the database layer.
* Selected individual columns instead of formatted strings.
* Cleaned up column structure for readability.
* Verified presence of relevant indexes to support the joins.

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

---

## EXPLAIN Analysis (After Optimization)

After refactoring, [EXPLAIN](./after_optimization.JPG) showed that:

* MySQL still used indexes on primary keys (`users.user_id`, `properties.property_id`).
* If `payments.booking_id` was indexed, it continued to be used effectively in the `LEFT JOIN`.
* The query structure allowed MySQL’s optimizer to execute with fewer row operations and estimated a lower query cost.

The performance gain wasn’t dramatic but was noticeable, especially on a larger dataset, due to cleaner structure and reduced formatting overhead.

---

## Index Verification

The following indexes were confirmed or recommended to support the query:

```sql
-- Indexes supporting JOIN operations
CREATE INDEX idx_bookings_user_property ON bookings(user_id, property_id);
CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_property_id ON properties(property_id);
```

These indexes reduce the need for full table scans and help the optimizer use efficient lookup paths during joins.

---

## Observation

Not all performance issues require new indexes. In this case, simplifying the SQL logic especially removing formatting functions like `CONCAT` and avoiding unnecessary column combinations was enough for MySQL to generate a more efficient execution plan. Clean, readable SQL often lets the query planner do its job better.
