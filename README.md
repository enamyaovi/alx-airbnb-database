# 🏠 AirBnB Clone Backend

## 🚀 Overview

The backend for the AirBnB Clone project is designed to replicate core functionalities of Airbnb, providing robust support for user interactions, property listings, bookings, payments, and reviews. This project enables hosts to manage properties while allowing guests to search, book, and review stays with seamless transactions.

### 🎯 Project Goals

- **User Management**: Secure authentication and profile management.
- **Property Management**: Feature-rich listing creation and retrieval system.
- **Booking System**: Intuitive booking process with check-in/check-out management.
- **Payment Processing**: Integration for transaction handling.
- **Review System**: Mechanism for collecting and displaying user feedback.
- **Performance Optimization**: Caching and indexing for efficient data handling.

---
## ⚙️ Technology Stack

| Technology | Purpose |
|------------|---------|
| **Django** | High-level Python framework for building RESTful APIs and backend logic. |
| **Django REST Framework** |  Provides tools for creating and managing RESTful APIs.|
| **PostgreSQL** | Relational database for data storage. |
| **GraphQL** | Allows for flexible and efficient querying of data.|
| **Celery** | Handles asynchronous tasks like sending emails or notifications. |
| **Redis** | In-memory data store for caching and background task queues. |
| **Docker** | Containerization tool to streamline development and deployment. |
| **CI/CD Pipelines** |  Automated pipelines for testing and deploying code changes.|

---
## 👥 Team Roles

| Role | Description |
|------|-------------|
| **Backend Developer** | Responsible for building and maintaining the core backend logic of the Airbnb Clone project. This includes implementing RESTful and GraphQL API endpoints for user authentication, property listings, bookings, payments, and reviews. They also integrate third-party services like payment gateways and handle error handling, serialization, and middleware logic. |
| **QA Engineer** | Ensures the Airbnb Clone functions as expected by conducting thorough testing, including functionality, usability, performance, and security. The QA engineer creates and executes test plans, identifies bugs in features like the booking flow or payment processing, and ensures edge cases are covered before deployment. |
| **DevOps Engineer** | Streamlines development and deployment by building and maintaining the CI/CD pipeline. In this project, they automate testing and deployment using tools like GitHub Actions and Docker, manage cloud environments, and monitor infrastructure to ensure high availability and smooth delivery of new updates. |
| **Database Administrator (DBA)** | Designs and manages the database schema for entities like Users, Properties, Bookings, and Payments. They ensure optimized queries, enforce data consistency, create indexes for fast lookups, and handle database backups and recovery for the project. |

---
## 🗃️ Database Design

### Key Entities and Fields

1. **Users**
   - `id`: Unique identifier for each user.
   - `username`: Unique display name for the user.
   - `email`: User's email address.
   - `password`: Securely hashed password.
   - `role`: Indicates if the user is a "guest" or "host".

2. **Properties**
   - `id`: Unique identifier for the property.
   - `host_id`: References the `id` of the user who owns the property.
   - `title`: Name or title of the property.
   - `location`: Physical address or location information.
   - `price`: Rental cost per night.

3. **Bookings**
   - `id`: Unique booking identifier.
   - `user_id`: References the `id` of the guest who made the booking.
   - `property_id`: References the `id` of the booked property.
   - `check_in`: Booking start date.
   - `check_out`: Booking end date.

4. **Payments**
   - `id`: Unique identifier for the payment transaction.
   - `booking_id`: References the `id` of the associated booking.
   - `amount`: Total payment amount.
   - `status`: Payment status (e.g., success, pending, failed).
   - `timestamp`: Date and time the payment was processed.

5. **Reviews**
   - `id`: Unique identifier for the review.
   - `user_id`: References the `id` of the reviewer.
   - `property_id`: References the `id` of the reviewed property.
   - `rating`: Numeric rating (1 to 5 stars).
   - `comment`: Textual feedback left by the user.

### Entity Relationships

- A **User** can own multiple **Properties** (as a host).
- A **User** can book multiple **Properties** (as a guest).
- A **Property** can have many **Bookings**.
- Each **Booking** is associated with one **Payment**.
- A **User** can write multiple **Reviews**, each linked to a specific **Property**.
- A **Property** can have many **Reviews** from different users.
