-- Use Database
USE airbnb_clone;

-- Retrieve all bookings and the respective users who made the bookings
SELECT 
    bookings.booking_id,
    bookings.start_date,
    bookings.end_date,
    bookings.status,
    properties.name AS property_name,
    CONCAT(users.first_name, ' ', users.last_name) AS guest
FROM bookings
INNER JOIN users ON bookings.user_id = users.user_id
INNER JOIN properties ON bookings.property_id = properties.property_id;

-- Retrieve all properties and their reviews, including properties with no reviews
SELECT 
    properties.name AS property_name,
    reviews.comment,
    reviews.rating,
    CONCAT(users.first_name, ' ', users.last_name) AS guest
FROM properties
LEFT JOIN reviews ON properties.property_id = reviews.property_id
LEFT JOIN users ON reviews.user_id = users.user_id
ORDER BY reviews.rating DESC;

-- Simulate a FULL OUTER JOIN between users and bookings
-- Includes users with no bookings and bookings with no user
SELECT 
    result.guest,
    result.duration,
    result.status,
    properties.name AS property_name
FROM (
    -- Left join: all users + their bookings (if any)
    SELECT 
        CONCAT(users.first_name, ' ', users.last_name) AS guest,
        CONCAT('Booked from: ', bookings.start_date, ' - ', bookings.end_date) AS duration,
        bookings.status,
        bookings.property_id
    FROM users
    LEFT JOIN bookings ON users.user_id = bookings.user_id

    UNION ALL

    -- Right join with NULL user side: bookings with no linked user
    SELECT 
        'Null' AS guest,
        CONCAT('Booked from: ', bookings.start_date, ' - ', bookings.end_date) AS duration,
        bookings.status,
        bookings.property_id
    FROM users
    RIGHT JOIN bookings ON users.user_id = bookings.user_id
    WHERE users.user_id IS NULL
) AS result
LEFT JOIN properties ON result.property_id = properties.property_id
ORDER BY result.status;