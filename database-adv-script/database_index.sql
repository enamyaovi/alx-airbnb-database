USE airbnb_clone;
-- USERS TABLE INDEXES
-- Ensure email is unique (often used for login)
CREATE UNIQUE INDEX idx_unique_email ON users(email);

-- Composite index for login queries (email + password)
CREATE INDEX idx_email_password ON users(email, password_hash);

-- Optional index for searching or sorting users by name/phone
-- Useful if there's a search feature on name/phone
CREATE INDEX idx_user_info ON users(last_name, first_name, phone_number);

-- BOOKINGS TABLE INDEXES
-- Composite index for user-property-status filtering
-- Useful in WHERE, JOIN, and ORDER BY clauses
CREATE INDEX idx_user_property_status ON bookings(user_id, property_id, status);

-- PROPERTIES TABLE INDEXES 
CREATE INDEX idx_property_id ON properties(property_id);
-- Optional: Index for sorting or filtering by property name
CREATE INDEX idx_property_name ON properties(name);

-- query to be run after indexing check index_performance.md
EXPLAIN ANALYZE SELECT user_id, email, first_name, last_name, phone_number  
FROM users
WHERE email = 'richmond@mail.com' AND first_name = 'Richmond';