
# Performance Monitoring and Query Optimization Report

## Objective

The objective of this exercise was to continuously monitor and refine database performance by analyzing query execution plans and making appropriate schema adjustments. This involved using tools like `EXPLAIN` to inspect frequently used queries, identifying performance bottlenecks, implementing schema improvements such as new indexes and partitioning, and validating the results through observed performance gains.

---

## Initial Monitoring and Bottleneck Identification

A number of frequently used queries were identified, particularly those involving the `bookings` and `users` tables. Using `EXPLAIN`, I examined how MySQL processed these queries. For instance:

```sql
SELECT 
    b.status AS booking_status,
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

The `EXPLAIN` output showed that although joins with users and properties were efficient due to primary keys, the bookings table was scanned entirely (access type `ALL`). This was the first major bottleneck. Additionally, there was some unnecessary processing, such as string concatenation in the SELECT clause.

---

## Indexing as a First Response

To improve lookup speed and reduce full scans, I introduced several indexes across key tables. Notably:

### Users Table

* Unique index on `email`
* Composite index on `(email, password_hash)`
* Composite index on `(last_name, first_name, phone_number)`

These were based on common access patterns observed in authentication and user lookup queries. These changes reduced lookup time and allowed the planner to use index-based access types like `const` or `ref`.

### Bookings Table

* Composite index on `(user_id, property_id, status)`

This index supported several filtering patterns involving user activity and booking status. I avoided indexing `status` alone due to its low cardinality, and used the leftmost prefix rule to guide index creation.

The result of these indexes was a notable drop in query execution time and row scans, confirmed by updated `EXPLAIN` outputs.

---

## Schema Adjustment: Partitioning

To further improve queries involving date ranges especially those filtering on `start_date`, I implemented `RANGE` partitioning. This required structural changes:

* A new table, `bookings_partitioned`, was created.
* Partitioned by `YEAR(start_date)`.
* Composite primary key on `(booking_id, start_date)` to satisfy MySQL partitioning constraints.

```sql
CREATE TABLE bookings_partitioned(
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36),
    user_id CHAR(36),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),
    INDEX idx_property_id (property_id),
    INDEX idx_user_property_status (user_id, property_id, status)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);
```

---

## Performance Testing on Partitioned Table

A test query filtering by date range:

```sql
SELECT * FROM bookings_partitioned
WHERE start_date BETWEEN '2025-01-01' AND '2025-03-31';
```

### Improvements Observed:

* **Before partitioning:** Full table scan regardless of filter.
* **After partitioning:** MySQL pruned irrelevant partitions, scanned only what was needed.
* **Query time:** Reduced noticeably.

Refer to diagrams [before\_partition.png](./before_partition.png) and [after\_partition.png](./after_partition.png) for `EXPLAIN` visual evidence.

---

## Structural Tradeoffs

Partitioning required the inclusion of the partitioning key in all unique constraints. This meant redefining the primary key as `(booking_id, start_date)`. While effective, this added complexity:

* Referential queries must now use both keys or rely on a surrogate.
* Composite keys are less intuitive for general usage.

To balance this, the original `bookings_backup` table may be retained for reference and simpler access.

---

## Summary

This report captured a staged improvement process:

1. Used `EXPLAIN` to analyze slow queries.
2. Added targeted indexes based on access patterns.
3. Refactored query structure to reduce overhead.
4. Introduced partitioning to optimize time-based filtering.

| Optimization Step | Effect                             |
| ----------------- | ---------------------------------- |
| Indexing          | Reduced full scans, faster lookups |
| Query Refactoring | Removed unnecessary processing     |
| Partitioning      | Reduced row scans for date filters |

Each step delivered measurable improvements. While partitioning introduced schema constraints, it provided scalable performance benefits for time-based queries.

---

## Conclusion

Through continuous monitoring, the use of `EXPLAIN`, and a mix of indexing and schema design, I was able to enhance performance on real-world queries. These changes support long-term scalability and serve as a reference for future performance tuning efforts.
