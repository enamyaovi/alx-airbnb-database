# Database Schema – Airbnb Clone

This script defines the database structure for the **Airbnb Clone** backend. It includes commands for creating the database and all necessary tables, along with their relationships and constraints.

## File: `schema.sql`

###  What it does:
- Creates the main database (e.g., `airbnb_clone`).
- Defines all entities as tables: `Users`, `Properties`, `Bookings`, `Payments`, `Reviews`, `Messages`, and `Location`.
- Adds foreign key relationships to enforce data integrity.
- Creates indexes for faster lookups (e.g., on `email`, `booking_id`, etc.).
- Uses UUIDs for primary keys across all tables.
- Includes enum-like constraints (e.g., roles, status, payment options).

###  Constraints & Features:
- Primary keys on all main entities.
- Foreign key constraints with `ON DELETE` / `ON UPDATE` logic.
- Not-null constraints for required fields.
- Secure design consideration for storing hashed passwords.

> This script should be run before inserting any sample data. It sets up the full database schema.
