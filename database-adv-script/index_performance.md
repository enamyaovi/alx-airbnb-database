# Optimization Report: Impact of Indexing on `users` and `bookings` Tables

*Author: Cephas Tay*
*Date: July 2025*

---

## Objective

To analyze query performance before and after indexing, specifically focusing on queries involving `user_id`, `property_id`, and `status` in the `bookings` table, and queries involving `email` and `first_name` in the `users` table.

---

## Baseline Query Performance (Before Indexes)

I began with a basic query on the `users` table:

```sql
SELECT user_id, email, first_name, last_name, phone_number  
FROM users
WHERE email = 'richmond@mail.com' AND first_name = 'Richmond';
```

At this stage, no supporting index existed for either `email` or `first_name`. As expected, MySQL performed a full table scan to find the matching row, inefficient and costly, especially at scale. Check [before\_index.png](./before_index.png) for a screenshot of full performance details from the SQL CLI.

To optimize query performance, I created the following indexes:

```sql
CREATE UNIQUE INDEX email ON users(email);
CREATE INDEX idx_email_password ON users(email, password_hash);
CREATE INDEX idx_user_info ON users(last_name, first_name, phone_number);
```

These indexes were informed by observed query patterns. For instance, many authentication-related queries rely on `email` and `password_hash`, while user lookups tend to reference a combination of names and contact details.

Re-running the earlier query:

```sql
SELECT user_id, email, first_name, last_name, phone_number  
FROM users
WHERE email = 'richmond@mail.com' AND first_name = 'Richmond';
```

This time, the EXPLAIN output showed MySQL using the `email` index directly, achieving a `type: const` access and scanning just one row. This means the engine was able to locate the exact match through the index alone, a major performance gain. Full table filtering was avoided entirely. Refer to [after\_index.png](./after_index.png) for detailed output.

---

## Bookings Table Indexing Strategy

Initially, the `bookings` table had the following indexes:

* PRIMARY on `booking_id`
* Index on `property_id` as foreign_key
* Index on `user_id` as foreign_key

While these supported some queries, further inspection showed most application queries filter by `status` and often combine `user_id`, `property_id`, and `status`.

The `status` column had low cardinality (only three values), making it inefficient to index on its own. Instead, I created a composite index:

```sql
CREATE INDEX idx_user_property_status ON bookings(user_id, property_id, status);
```

This index was designed using `user_id` as the leftmost prefix to follow MySQL's prefix matching rule. It supports:

* Queries filtering by only `user_id`
* Queries using both `user_id` and `property_id`
* Queries involving all three: `user_id`, `property_id`, and `status`

This significantly improved performance in common use cases and reduced read costs.

---

## Summary of Indexing Across Tables

### Users Table

The `users` table contains several fields that are frequently used in queries, particularly `email`, `first_name`, `last_name`, and `phone_number`. To improve performance, I added a unique index on the `email` field due to its importance in lookups and authentication.

In addition, I created a composite index on `email` and `password_hash` to support login-related queries more efficiently. Another composite index was added on `last_name`, `first_name`, and `phone_number` to cover queries that retrieve full user profiles. All these indexes showed good cardinality (10), which made them cost-effective for filtering and lookups.

### Bookings Table

For the `bookings` table, the fields `user_id`, `property_id`, and `status` were identified as high-usage columns. These are commonly used in SELECT and WHERE clauses, particularly for filtering, grouping, or joins. Initially, individual indexes existed for `user_id` and `property_id`, but indexing `status` alone proved inefficient due to low cardinality.

To address this, I created a composite index on `user_id`, `property_id`, and `status`. With `user_id` as the leftmost prefix, this index allowed the optimizer to benefit from prefix-based index matching, which supports a wider range of query patterns and significantly improves performance.

### Properties Table

In the case of the `properties` table, existing indexes on `property_id`, `host_id`, and `location_id` were sufficient for the current query workload. These indexes already supported the most common lookups and filtering conditions. As a result, no additional optimization or new indexes were needed based on observed query behavior.

---

## Observations

After recreating the indexes and rerunning the tests, there was a noticeable improvement in query performance. Queries that previously depended on full table scans were now efficiently resolved using index lookups. The query planner selected more selective access types such as `const` and `ref`, avoiding the inefficient `ALL` access type.

This reduced the number of rows examined during execution and lowered the overall query cost.

This shift in performance is clearly illustrated in the diagrams provided below, which offer a side-by-side comparison of query behavior:

* [Before Index](./before_index.png)
* [After Index](./after_index.png)

These visuals show the transition from full table scans to optimized, index-based query execution, reinforcing the value of targeted indexing in performance tuning.
