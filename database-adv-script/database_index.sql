
-- indexes for users table
CREATE UNIQUE INDEX email ON users(email);
CREATE INDEX idx_email_password ON users(email, password_hash);
CREATE INDEX idx_user_info ON users(last_name, first_name, phone_number);

--indexes for bookings table
CREATE INDEX idx_user_property_status ON bookings(user_id, property_id, status);