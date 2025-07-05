
-- create a partitioned table
CREATE TABLE bookings_partitioned (
    booking_id CHAR(36) NOT NULL,
    property_id CHAR(36),
    user_id CHAR(36),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Composite primary key must include the partitioning column i.e start_date
    PRIMARY KEY (booking_id, start_date),

    -- Supporting indexes (based on previous optimization work)
    INDEX idx_property_id (property_id),
    INDEX idx_user_property_status (user_id, property_id, status)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);


-- migrate the data
INSERT INTO bookings_partitioned SELECT * FROM bookings;
