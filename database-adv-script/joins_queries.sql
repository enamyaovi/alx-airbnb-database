-- use database with table info

USING DATABASE airbnb_clone;


-- query to simulate inner join to retrieve all bookings and respective users who made the bookings

SELECT booking_id, start_date, end_date, status, properties.name, CONCAT(first_name, ' ',last_name) AS Guest
    FROM bookings INNER JOIN users ON bookings.user_id =users.user_id
    INNER JOIN properties ON bookings.property_id=properties.property_id;

-- query to simulate left join retrieving all properties and their reviews including properties with no reviews

SELECT properties.name, reviews.comment, reviews.rating, CONCAT(users.first_name, ' ', users.last_name) AS Guest  FROM properties LEFT JOIN reviews ON properties.property_id=reviews.property_id LEFT JOIN users ON reviews.user_id=users.user_id ORDER BY rating DESC;

--full outer join on bookings and users even if the user has no booking or a booking is not linked to a user results.
SELECT results.guest, results.duration, results.status, properties.name FROM (SELECT CONCAT(users.first_name, ' ', users.last_name) AS guest, CONCAT('Booked from: ', bookings.start_date, ' - ', bookings.end_date) as duration, bookings.status FROM users LEFT JOIN bookings ON users.user_id=bookings.user_id union all select CONCAT(users.first_name, ' ', users.last_name) AS guest, CONCAT('Booked from: ', bookings.start_date, ' - ', bookings.end_date) as duration, bookings.status FROM users RIGHT JOIN bookings ON users.user_id=bookings.user_id WHERE users.user_id IS NULL) AS results INNER JOIN properties ON results.property_id = properties.property_id ORDER BY results.status;