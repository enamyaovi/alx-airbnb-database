
-- Use a window function (ROW_NUMBER, RANK) to rank properties based on the total number of bookings they have received.
--crude

-- Write a query to find the total number of bookings made by each user, using the COUNT function and GROUP BY clause.
select users.first_name, t_book.total_booking from users join (select user_id, count(*) as total_booking from bookings group by user_id) as t_book on users.user_
id = t_book

-- Use a window function (ROW_NUMBER, RANK) to rank properties based on the total number of bookings they have received.
select samp.property_id, samp.total_bookings, row_number() over (order by samp.total_bookings desc) as booking_rownum, rank() over (order by samp.total_bookings desc) as booking_rank  from (select distinct property_id, count(*) over (partition by property_id) as total_bookings from bookings) as samp;