-- Create the database
CREATE DATABASE IF NOT EXISTS airbnb_clone;
USE airbnb_clone;

-- Users table
CREATE TABLE Users (
  user_id CHAR(36) PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50),
  email VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone_number VARCHAR(20),
  role ENUM('guest', 'host', 'admin') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);

-- Location table
CREATE TABLE Location (
  location_id CHAR(36) PRIMARY KEY,
  city VARCHAR(100) NOT NULL,
  street VARCHAR(150) NOT NULL
);

-- Properties table
CREATE TABLE Properties (
  property_id CHAR(36) PRIMARY KEY,
  host_id CHAR(36),
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  location_id CHAR(36),
  price_per_night DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (host_id) REFERENCES Users(user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (location_id) REFERENCES Location(location_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- Bookings table
CREATE TABLE Bookings (
  booking_id CHAR(36) PRIMARY KEY,
  property_id CHAR(36),
  user_id CHAR(36),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  status ENUM('pending', 'confirmed', 'cancelled') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (property_id) REFERENCES Properties(property_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  INDEX idx_property_id (property_id)
);

-- Payments table
CREATE TABLE Payments (
  payment_id CHAR(36) PRIMARY KEY,
  booking_id CHAR(36),
  amount DECIMAL(10, 2) NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
  FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  INDEX idx_booking_id (booking_id)
);

-- Reviews table
CREATE TABLE Reviews (
  review_id CHAR(36) PRIMARY KEY,
  property_id CHAR(36),
  user_id CHAR(36),
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (property_id) REFERENCES Properties(property_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- Messages table
CREATE TABLE Messages (
  message_id CHAR(36) PRIMARY KEY,
  sender_id CHAR(36),
  recipient_id CHAR(36),
  message_body TEXT NOT NULL,
  sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES Users(user_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  FOREIGN KEY (recipient_id) REFERENCES Users(user_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);
