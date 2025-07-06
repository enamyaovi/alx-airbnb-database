USE airbnb_clone;

-- Create a partitioned version of the bookings table
CREATE TABLE bookings_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36),
    user_id CHAR(36),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Composite primary key must include the partitioning column
    PRIMARY KEY (booking_id, start_date),

    -- Supporting indexes for performance
    INDEX idx_property_id (property_id),
    INDEX idx_user_property_status (user_id, property_id, status)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);

-- Migrate data from original bookings table

INSERT INTO bookings_partitioned (
    booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at
)
SELECT 
    booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at
FROM bookings;

-- Sample query to test partition performance

-- EXPLAIN SELECT * 
-- FROM bookings_partitioned 
-- WHERE start_date BETWEEN '2023-01-01' AND '2023-12-31';
