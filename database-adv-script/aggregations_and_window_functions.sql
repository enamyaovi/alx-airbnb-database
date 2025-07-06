-- Use the correct database
USE airbnb_clone;

-- Total number of bookings made by each user

SELECT 
    users.user_id,
    CONCAT(users.first_name, ' ', users.last_name) AS guest,
    t_book.total_booking
FROM users 
JOIN (
    SELECT 
        user_id, 
        COUNT(*) AS total_booking 
    FROM bookings 
    GROUP BY user_id
) AS t_book 
ON users.user_id = t_book.user_id;

--  Rank properties based on number of bookings
-- Using ROW_NUMBER() and RANK()

SELECT 
    property_id,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS booking_rownum,
    RANK() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM (
    SELECT 
        property_id,
        COUNT(*) AS total_bookings
    FROM bookings
    GROUP BY property_id
) AS ranked_props;