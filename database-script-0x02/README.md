
# `README.md` for `seed.sql` (Sample Data Insertion)


``` 🌱 Seed Data – Airbnb Clone

This script populates the database with sample data for development and testing purposes.
```

## 📁 File: `seed.sql`

### 📌 What it contains:
- Inserts **4 users**: 2 guests, 1 host, and 1 admin — with securely hashed passwords.
- Inserts **3 locations** and **3 properties** (all hosted by Kwame).
- Creates **2 bookings** (one confirmed, one pending).
- Adds **2 payments** (one via Stripe, one via PayPal).
- Wrapped in a `BEGIN;` / `COMMIT;` transaction block to ensure data consistency.

### 🔐 Sample UUIDs and realistic data:
- Sample UUIDs are used in place of auto-generated ones.
- Booking and payment dates are future-dated to simulate real activity.
- All relational references (foreign keys) match the values declared in `script.sql`.

> Run this script only after the schema (`script.sql`) has been created successfully.
