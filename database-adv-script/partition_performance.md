# Partition Query Performance Report

## Objective

To evaluate and compare the performance of queries executed on the `bookings_backup` table before and after applying partitioning by date. The goal is to determine how range partitioning affects query efficiency, especially for date-range filters.

---

## Before Partitioning

### Query Tested

```sql
SELECT * FROM bookings_backup
WHERE start_date BETWEEN '2025-01-01' AND '2025-03-31';
```

### Performance Observation

* **Execution Plan:** MySQL used a full table scan (type: ALL) to retrieve matching rows.
* **Cost:** The optimizer had to evaluate all rows in the `bookings_backup` table regardless of the date range.
* **Scalability Concern:** This approach is inefficient for larger datasets, especially as the number of bookings grows.

Refer to [before\_partition.png](./before_partition.png) for EXPLAIN output details.

---

## After Partitioning

### Partitioning Setup

The `bookings_partitioned` table was created with `RANGE` partitioning on the `start_date` column, with yearly boundaries (e.g., 2021, 2022, 2023). A composite primary key consisting of `booking_id` and `start_date` was defined to satisfy MySQL's partitioning requirements, which mandate that all unique keys include the partitioning column. Indexes from the original table were retained to preserve lookup efficiency.

### Query Tested

```sql
SELECT * FROM bookings_partitioned
WHERE start_date BETWEEN '2025-01-01' AND '2025-03-31';
```

### Performance Observation

* **Execution Plan:** MySQL was able to prune irrelevant partitions and access only the ones matching the specified range.
* **Access Type:** Only relevant partitions were scanned, reducing unnecessary I/O.
* **Improvement:** Query execution was faster, with significantly fewer rows scanned.

Refer to [after\_partition.png](./after_partition.png) for visual evidence of optimization.

---

## Structural Considerations

To enable partitioning on `start_date`, a composite primary key (`booking_id`, `start_date`) was introduced. This decision was made in response to MySQL's rule that all unique constraints must include the partitioned column. While it slightly complicates the schema, especially for referencing `booking_id` alone. It is a practical tradeoff when partitioning is needed for performance gains.

This change means that any foreign key or application logic relying solely on `booking_id` will now need to account for `start_date` as well, or rely on surrogate keys elsewhere. It’s a deviation from the simplicity of a single-column primary key, but necessary within the constraints of MySQL’s partitioning engine.

---

## Summary

Partitioning on date fields such as `start_date` provides a scalable way to improve query performance when dealing with large time-series data. While indexing helps optimize row-level filtering, partitioning reduces the number of rows examined at the storage level.

To meet MySQL's partitioning constraints, we introduced a composite primary key using both `booking_id` and `start_date`. This allowed us to keep `booking_id` unique while enabling efficient partitioning. The overall structure now supports better query performance for date-based filters while maintaining referential integrity for downstream access patterns.

However, partitioning comes with tradeoffs. The need to include the partitioning column in all unique keys can increase schema complexity. In some cases, maintaining a simpler non-partitioned table for general reference or backups might be a more manageable solution when full normalization and flexibility are required.

| Metric              | Before Partitioning | After Partitioning  |
| ------------------- | ------------------- | ------------------- |
| Access Type         | ALL                 | RANGE INDEX PRUNING |
| Partitions Accessed | All                 | Relevant Only       |
| Rows Scanned        | High                | Low                 |
| Query Time          | Higher              | Lower               |

Partitioning complements indexing and should be used strategically based on the dataset's access patterns and the specific performance issues being addressed.
