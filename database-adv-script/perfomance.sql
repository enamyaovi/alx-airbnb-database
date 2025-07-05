-- before optimizaiton
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

-- after optimization
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
