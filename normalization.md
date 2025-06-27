# 📊 Database Normalization for AirBnB Clone Project

Database normalization is essential for reducing redundancy, improving data integrity, and avoiding inefficiencies in relational databases. Since this project relies on a relational database, it's important to ensure that all tables are properly normalized.

This document evaluates the current schema and entity design to determine whether they satisfy **Third Normal Form (3NF)**. Each entity will be analyzed and corrected where necessary, with explanations provided.

---

## First Normal Form (1NF)

A table is in **1NF** if:
1. It has a **primary key**.
2. All attributes (columns) contain **atomic values** i.e., indivisible values with no repeating groups.

---

## Second Normal Form (2NF)

A table is in **2NF** if:
1. It is already in **1NF**.
2. All non-key attributes are **fully functionally dependent** on the **entire primary key**.

This mostly applies when there’s a **composite key**, but in any case, each attribute must depend entirely on the primary key, not just part of it.

---

## Third Normal Form (3NF)

A table is in **3NF** if:
1. It is already in **2NF**.
2. All **non-key attributes** are **not transitively dependent** on the primary key. In other words, non-key attributes must depend **only** on the primary key and **not on other non-key attributes**.

---

## 🔍 Entity Review Table

| Entity     | Primary Key | Atomicity           | Notes                                             | 1NF | 2NF | 3NF |
|------------|-------------|---------------------|---------------------------------------------------|-----|-----|-----|
| Users      | user_id     |    Yes              | All columns store atomic values                   | ✅  | ✅  | ✅  |
| Properties | property_id |    Possibly No      | `location` field may contain composite values     | ⚠️  | ⚠️  | ❌  |
| Bookings   | booking_id  |    Yes              | All values atomic                                 | ✅  | ✅  | ✅  |
| Payments   | payment_id  |    Yes              | All values atomic                                 | ✅  | ✅  | ✅  |
| Reviews    | review_id   |    Yes              | All values atomic                                 | ✅  | ✅  | ✅  |
| Messages   | message_id  |    Yes              | All values atomic                                 | ✅  | ✅  | ✅  |

---

## ⚠️ Property Table — Problem with Atomicity

Initially, the `location` field in the `properties` table may be written in the form of a full address string or region-city format (e.g., `"Greater Accra, Accra"`). This can violate **1NF** because the value is **not atomic**, it's a composite of city, region, etc.

To fix this and satisfy 1NF, we **split `location` into separate columns**.

### 🛠️ Refactored Property Table (1NF Applied)

| Attribute         | Data Type   | Key / Constraint            | Notes                            |
|-------------------|-------------|-----------------------------|----------------------------------|
| property_id       | UUID        | Primary Key, Indexed        | Unique identifier                |
| host_id           | UUID        | Foreign Key → users(user_id)| Property owner                   |
| name              | VARCHAR     | NOT NULL                    | Title of the listing             |
| description       | TEXT        |                             | Description of the property      |
| city              | VARCHAR     | NOT NULL                    | City where the property is       |
| street_name       | VARCHAR     | NOT NULL                    | Street name                      |
| price_per_night   | DECIMAL     | NOT NULL                    | Price per night                  |
| created_at        | TIMESTAMP   | Default: CURRENT_TIMESTAMP  | Creation time                    |
| updated_at        | TIMESTAMP   | Default: ON UPDATE CURRENT_TIMESTAMP | Auto-update on changes  |

Now the table satisfies **1NF**.

---

## ⚙️ From 1NF to 2NF and 3NF — Introducing the Location Table

While we've achieved atomicity, we can **further normalize** by **factoring out repeated city/street values**. These may not be functionally dependent on the `property_id`, so we create a separate **Location** table.

### 🗺️ Location Table

| Attribute    | Data Type | Key / Constraint          | Notes                       |
|--------------|-----------|---------------------------|-----------------------------|
| location_id  | UUID      | Primary Key, Indexed       | Unique location identifier  |
| city         | VARCHAR   | NOT NULL                  | City                        |
| street       | VARCHAR   | NOT NULL                  | Street name                 |

---

### 🏠 Final Property Table (Fully Normalized)

| Attribute        | Data Type | Key / Constraint                      | Notes                            |
|------------------|-----------|---------------------------------------|----------------------------------|
| property_id      | UUID      | Primary Key, Indexed                  | Unique property identifier       |
| host_id          | UUID      | Foreign Key → users(user_id)         | Property owner                   |
| name             | VARCHAR   | NOT NULL                             | Title                            |
| description      | TEXT      |                                       | Details about the property       |
| location_id      | UUID      | Foreign Key → location(location_id)  | Linked location                  |
| price_per_night  | DECIMAL   | NOT NULL                             | Cost per night                   |
| created_at       | TIMESTAMP | Default: CURRENT_TIMESTAMP           | When created                     |
| updated_at       | TIMESTAMP | Default: ON UPDATE CURRENT_TIMESTAMP | Auto-update                      |

Now the table satisfies:
-  **1NF** (atomic values)
-  **2NF** (non-key columns depend fully on `property_id`)
-  **3NF** (no transitive dependencies,  location details moved)

---

##  Summary: Steps to Achieve 3NF

1. **Add a primary key** to each table.
2. Ensure each column contains **atomic**, indivisible values.
3. **Eliminate partial dependencies**,  all non-key attributes must depend on the **whole key**.
4. **Eliminate transitive dependencies**, no non-key attribute should depend on another non-key.

---
