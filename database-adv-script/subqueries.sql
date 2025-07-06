-- Use the target database
USE airbnb_clone;

-- Find all properties where the average rating is greater than 4.0
-- (Non-correlated subquery in the FROM clause)

SELECT 
    property_avg.property_id,
    property_avg.average_rating
FROM (
    SELECT 
        property_id,
        AVG(rating) AS average_rating
    FROM reviews
    WHERE property_id IS NOT NULL
    GROUP BY property_id
) AS property_avg
WHERE property_avg.average_rating > 4;

-- Find users who have made more than 3 bookings
-- (Correlated subquery in the WHERE clause)
SELECT 
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS guest,
    (
        SELECT COUNT(*) 
        FROM bookings b 
        WHERE b.user_id = u.user_id
    ) AS total_bookings
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM bookings b 
    WHERE b.user_id = u.user_id
) > 3;

--Total number of bookings made by each user
SELECT 
    user_id, 
    COUNT(*) AS total_bookings
FROM bookings
GROUP BY user_id;
