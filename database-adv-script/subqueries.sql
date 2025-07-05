-- Write a query to find all properties where the average rating is greater than 4.0 using a subquery.
select avg(rating) as average_rating, property_id from reviews where property_id  is not null group by property_id having average_rating>4;

select property_avg.property_id, property_avg.average_rating from (select property_id, avg(rating) as average_rating from reviews where property_id is not null group by property_id) as property_avg where property_avg.average_rating > 4;

-- Write a correlated subquery to find users who have made more than 3 bookings.

select results.user_id from (select user_id, count(*) as total_bookings from bookings group by user_id) as results where results.total_bookings >=3;

select u.user_id, concat(u.first_name, ' ', u.last_name) as guest, (select count(*) from bookings b where b.user_id = u.user_id) as t_book from users u where (select count(*) from bookings b where b.user_id = u.user_id) > 3;

-- Write a query to find the total number of bookings made by each user, using the COUNT function and GROUP BY clause.

select user_id, count(*) as total_bookings from bookings group by user_id;




