BEGIN;
-- Users Table with Secure Hashed Passwords
INSERT INTO Users (user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES 
  ('9a5f4d4d-cc64-4c3d-9420-59716c5d304e', 'John', 'Doe', 'john@yahoo.com', '$2b$12$IBPBF2y8xBoZg0Cr86bLGu.fjd63N7nxTxgB01r0Cma4UVByIhC86', '0501234567', 'guest'),
  ('33e59795-4208-4d40-9c7e-91b96cd2ec9d', 'Sarah', 'Adams', 'sarah@gmail.com', '$2b$12$x/tx86UjVpt6TBm8OkItJ.aeJQmhIXmHvMKwtpNSOo6d2iLrJ86o2', '0552345678', 'guest'),
  ('ca84617c-9ff6-4669-9ce8-64baf3b5aa8e', 'Kwame', 'Mensah', 'kwame@hostmail.com', '$2b$12$y2f4CtQuY5/Ew3kkU5uwi.lUJYRJtVq.JeNV/PSUC5SbCqiv5q0Ue', '0593456789', 'host'),
  ('7ef02b9d-561f-4305-8743-b8a8c5772536', 'Admin', 'User', 'admin@clonebnb.com', '$2b$12$Kq0dbMiQNfe3xdagQkrIDuyyf0lzDRyyaF8LceS4Ch9/JJA741f8K', NULL, 'admin');

-- Insert Locations
INSERT INTO Location (location_id, city, street) VALUES  
  ('f0c71a3b-e204-4e95-a9c6-ff01f1d7ed2d', 'Accra', 'Ring Road Central'),
  ('dfab128a-b99f-4e27-923e-90e27f3a912f', 'Kumasi', 'Adum Market Street'),
  ('b6b7330e-d489-4f47-a0e5-6ac011394822', 'Tamale', 'Lamashegu Industrial Rd');

-- Insert Properties (owned by Kwame)
INSERT INTO Properties (property_id, host_id, name, description, location_id, price_per_night) VALUES
  ('89415761-26e9-43a4-83b5-7da94f9392f3', 'ca84617c-9ff6-4669-9ce8-64baf3b5aa8e', 'Modern Studio in Accra', 'Cozy studio in the heart of Accra with Wi-Fi and A/C.', 'f0c71a3b-e204-4e95-a9c6-ff01f1d7ed2d', 200.0),
  ('f04cc792-6b0c-426c-8279-6af46f4ace76', 'ca84617c-9ff6-4669-9ce8-64baf3b5aa8e', 'Family Apartment - Kumasi', 'Spacious 3-bedroom flat perfect for family stays.', 'dfab128a-b99f-4e27-923e-90e27f3a912f', 350.0),
  ('b24776e4-781e-4b08-bc3c-850008c895b4', 'ca84617c-9ff6-4669-9ce8-64baf3b5aa8e', 'Budget Room in Tamale', 'Affordable room in a quiet area of Tamale.', 'b6b7330e-d489-4f47-a0e5-6ac011394822', 100.0);

-- insert bookings (By Sarah and John)
INSERT INTO Bookings (booking_id, property_id, user_id, start_date, end_date, total_price, status) VALUES 
  ('e5f6d335-fe8a-4b1b-b171-7fae15ac89ab','f04cc792-6b0c-426c-8279-6af46f4ace76', '33e59795-4208-4d40-9c7e-91b96cd2ec9d', '2025-07-01', '2025-07-06', 1750.0, 'confirmed'),
  ('0d008ba1-6eff-4da3-84c0-8fba9bd291ae', '89415761-26e9-43a4-83b5-7da94f9392f3', '9a5f4d4d-cc64-4c3d-9420-59716c5d304e', '2025-07-08', '2025-07-12', 800.0, 'pending');

-- insert payments by sarah and john
INSERT INTO Payments (payment_id, booking_id, amount, payment_method) VALUES 
  ('c7b6c9fa-47f5-4a96-82a0-35630b73a9dc', 'e5f6d335-fe8a-4b1b-b171-7fae15ac89ab', 1750.00, 'stripe'),
  ('817e2d65-43e5-4337-b615-8b6fd4fa3fdf', '0d008ba1-6eff-4da3-84c0-8fba9bd291ae', 800.0, 'paypal');
COMMIT;


