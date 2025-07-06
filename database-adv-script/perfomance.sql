USE airbnb_clone;

--  ORIGINAL QUERY (Before Optimization)
-- Retrieves all bookings with user, property, and payment details
-- EXPLAIN 
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
WHERE u.email IS NOT NULL AND pay.amount > 200
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id;

-- OPTIMIZED QUERY (After Refactoring)
-- Reduces overhead by avoiding CONCAT, selecting only necessary columns

-- EXPLAIN ANALYSIS (Optional - uncomment to use)
-- EXPLAIN 
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
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.status = 'confirmed'
AND b.start_date > '2025-01-01';
