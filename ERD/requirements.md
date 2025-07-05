 # Entity Relationship Diagram for Airbnb Clone Project

This document outlines the key entities and their attributes for the Airbnb clone project. It defines relationships between entities and their respective cardinalities.  

The visual representation of the ER diagram is saved as `erd_diagram.png`.  
The declarative database structure is defined in `airbnb.dbml`, which contains all entity definitions and relationships in DBML format.

## User Entity

The `users` table stores details of all people who use the platform. A user can be a **guest**, **host**, or **admin**. This role determines their capabilities in the system.

### Attributes

| Attribute        | Data Type   | Key / Constraint          | Notes                         |
|------------------|-------------|---------------------------|-------------------------------|
| user_id          | UUID        | Primary Key, Indexed      | Unique identifier             |
| first_name       | VARCHAR     | NOT NULL                  | User's first name             |
| last_name        | VARCHAR     |                           | User's last name              |
| email            | VARCHAR     | Unique, NOT NULL, Indexed | Used for login                |
| password_hash    | VARCHAR     | NOT NULL                  | Hashed password               |
| phone_number     | VARCHAR     | Null                      | Optional                      |
| role             | ENUM        | NOT NULL                  | guest, host, or admin         |
| created_at       | TIMESTAMP   | Default: CURRENT_TIMESTAMP| Timestamp of account creation |


## Property Entity

The `properties` table stores listings added by users who are **hosts**. Each property is owned by a user.

### Relationships:
- Many-to-One with `users` (each property belongs to one host)

### Attributes

| Attribute         | Data Type   | Key / Constraint            | Notes                               |
|-------------------|-------------|------------------------------|------------------------------------|
| property_id       | UUID        | Primary Key, Indexed         | Unique property identifier         |
| host_id           | UUID        | Foreign Key → users(user_id) | Owner of the listing               |
| name              | VARCHAR     | NOT NULL                     | Title of the property              |
| description       | TEXT        |                              | Property details                   |
| location          | VARCHAR     | NOT NULL                     | City or area                       |
| price_per_night   | DECIMAL     | NOT NULL                     | Cost per night                     |
| created_at        | TIMESTAMP   | Default: CURRENT_TIMESTAMP   | When the listing was created       |
| updated_at        | TIMESTAMP   | Default: ON UPDATE CURRENT_TIMESTAMP | Auto-updates on record change |


## Booking Entity

The `bookings` table keeps track of reservations made by users for properties listed on the platform. Each booking links a guest (`user_id`) to a property and includes dates, pricing, and status.

### Relationships:
- Many-to-One with `users` (each booking is made by one user)
- Many-to-One with `properties` (each booking is for one property)

### Attributes

| Attribute     | Data Type | Key / Constraint                               | Notes                             |
|---------------|-----------|------------------------------------------------|-----------------------------------|
| booking_id    | UUID      | Primary Key, Indexed                           | Unique booking reference          |
| property_id   | UUID      | Foreign Key → properties(property_id), Indexed | Property being booked             |
| user_id       | UUID      | Foreign Key → users(user_id)                   | Guest making the booking          |
| start_date    | DATE      | NOT NULL                                       | Check-in date                     |
| end_date      | DATE      | NOT NULL                                       | Check-out date                    |
| total_price   | DECIMAL   | NOT NULL                                       | Full cost of the booking          |
| status        | ENUM      | NOT NULL                                       | pending, confirmed, or canceled   |
| created_at    | TIMESTAMP | Default: CURRENT_TIMESTAMP                     | Timestamp of booking creation     |


## Payment Entity

The `payments` table stores details of financial transactions made by users for confirmed bookings. Each payment is tied to a specific booking and includes method and amount.

### Relationships:
- One-to-One with `bookings` (each booking has one payment record)

### Attributes

| Attribute        | Data Type   | Key / Constraint                                | Notes                                 |
|------------------|-------------|------------------------------------------------ |---------------------------------------|
| payment_id       | UUID        | Primary Key, Indexed                            | Unique identifier for the payment     |
| booking_id       | UUID        | Foreign Key → bookings(booking_id), Indexed     | Booking associated with this payment  |
| amount           | DECIMAL     | NOT NULL                                        | Amount paid                           |
| payment_date     | TIMESTAMP   | Default: CURRENT_TIMESTAMP                      | When the payment was made             |
| payment_method   | ENUM        | NOT NULL                                        | credit_card, paypal, or stripe        |


## Review Entity

The `reviews` table stores user feedback for properties. A review includes a numeric rating and a text comment, both tied to a specific user and property.

### Relationships:
- Many-to-One with `users` (each review is written by one user)
- Many-to-One with `properties` (each review belongs to one property)

### Attributes

| Attribute     | Data Type   | Key / Constraint                             | Notes                                       |
|---------------|-------------|----------------------------------------------|---------------------------------------------|
| review_id     | UUID        | Primary Key, Indexed                         | Unique review identifier                    |
| property_id   | UUID        | Foreign Key → properties(property_id)        | The property being reviewed                 |
| user_id       | UUID        | Foreign Key → users(user_id)                 | The user who left the review                |
| rating        | INTEGER     | CHECK: rating ≥ 1 AND ≤ 5, NOT NULL          | Numeric score given (1 to 5)                |
| comment       | TEXT        | NOT NULL                                     | User’s written feedback                     |
| created_at    | TIMESTAMP   | Default: CURRENT_TIMESTAMP                   | Timestamp of when the review was submitted  |


## Message Entity

The `messages` table records communication between users on the platform. Each message is sent by one user to another, and is stored with a timestamp.

### Relationships:
- Many-to-One with `users` (each message has a sender and a recipient, both from the users table)

### Attributes

| Attribute      | Data Type   | Key / Constraint                          | Notes                                    |
|----------------|-------------|-------------------------------------------|------------------------------------------|
| message_id     | UUID        | Primary Key, Indexed                      | Unique identifier for the message        |
| sender_id      | UUID        | Foreign Key → users(user_id)              | User sending the message                 |
| recipient_id   | UUID        | Foreign Key → users(user_id)              | User receiving the message               |
| message_body   | TEXT        | NOT NULL                                  | Content of the message                   |
| sent_at        | TIMESTAMP   | Default: CURRENT_TIMESTAMP                | Timestamp of when the message was sent   |


## Normalization Procedure

> **Summary:**  
> As part of optimizing the database design, a normalization audit was conducted and documented in `normalization.md`.

> **Issue Identified:**  
> The original `properties` table violated **First Normal Form (1NF)** due to the `location` attribute potentially storing non-atomic data (e.g., full addresses or compound region-city values).

> **Deeper Impact:**  
> Further analysis showed this affected compliance with **2NF** and **3NF**, as some attributes were not fully or directly dependent on the primary key.

> **Resolution:**  
> - A new `locations` table was introduced to store atomic, reusable location data (`city`, `street`).
> - The `properties` table was updated to reference `locations` via a `location_id` foreign key.

> **Reference:**  
> For full details and revised table structures, refer to the file `normalization.md`.
---

## Deletion Rules & Data Integrity

To keep the data in the Airbnb Clone database clean and consistent, certain **deletion restrictions** are enforced using foreign key constraints. These rules prevent accidental loss of important data or broken relationships between tables.

### Key Restrictions:

- **Users with Active Bookings**  
  → Cannot be deleted.  
  _(Guests or Hosts involved in current or past bookings are protected from deletion to preserve history.)_

- **Properties with Active Bookings**  
  → Cannot be deleted.  
  _(Prevents removing listings that are already booked or linked to reviews/payments.)_

- **Locations used by Properties**  
  → Can be deleted, but the location on those properties will be set to `NULL`.  
  _(This avoids breaking the property record while allowing location updates.)_

- **Bookings linked to Payments**  
  → Deleting a booking will also delete its related payment record.  
  _(Handled with `ON DELETE CASCADE` for cleanup.)_

- **Users linked to Messages**  
  → If a user is deleted, their messages will remain, but the sender/recipient fields will be set to `NULL`.  
  _(So chat history isn’t lost even if the user leaves.)_

- **Users or Properties with Reviews**  
  → If deleted, their reviews will also be deleted automatically.  
  _(Helps maintain a clean review system.)_

---

### Why This Matters:
These rules ensure that:
- No “orphaned” records are left behind.
- Bookings, reviews, and payments stay connected to valid users and listings.
- Important history and financial data are not lost due to accidental deletions.
