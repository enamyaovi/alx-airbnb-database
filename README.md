# AirBnB Clone Backend

##  Overview

The backend for the AirBnB Clone project is designed to replicate core functionalities of Airbnb, providing robust support for user interactions, property listings, bookings, payments, and reviews. This project enables hosts to manage properties while allowing guests to search, book, and review stays with seamless transactions.

### Project Goals

- **User Management**: Secure authentication and profile management.
- **Property Management**: Feature-rich listing creation and retrieval system.
- **Booking System**: Intuitive booking process with check-in/check-out management.
- **Payment Processing**: Integration for transaction handling.
- **Review System**: Mechanism for collecting and displaying user feedback.
- **Performance Optimization**: Caching and indexing for efficient data handling.

---
## Technology Stack

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
## Team Roles

| Role | Description |
|------|-------------|
| **Backend Developer** | Responsible for building and maintaining the core backend logic of the Airbnb Clone project. This includes implementing RESTful and GraphQL API endpoints for user authentication, property listings, bookings, payments, and reviews. They also integrate third-party services like payment gateways and handle error handling, serialization, and middleware logic. |
| **QA Engineer** | Ensures the Airbnb Clone functions as expected by conducting thorough testing, including functionality, usability, performance, and security. The QA engineer creates and executes test plans, identifies bugs in features like the booking flow or payment processing, and ensures edge cases are covered before deployment. |
| **DevOps Engineer** | Streamlines development and deployment by building and maintaining the CI/CD pipeline. In this project, they automate testing and deployment using tools like GitHub Actions and Docker, manage cloud environments, and monitor infrastructure to ensure high availability and smooth delivery of new updates. |
| **Database Administrator (DBA)** | Designs and manages the database schema for entities like Users, Properties, Bookings, and Payments. They ensure optimized queries, enforce data consistency, create indexes for fast lookups, and handle database backups and recovery for the project. |

---
## Database Design

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

---
## 🔧 Feature Breakdown

### 1. **User Authentication**
Enables secure user registration, login, and profile management. This ensures that only verified users can access personalized services, such as booking properties or managing listings. Roles like "guest" and "host" are managed to provide tailored access and functionality.

### 2. **Property Management**
Allows hosts to create, update, and manage property listings. Each listing contains key information such as pricing, location, and availability, giving users a comprehensive view when searching for accommodations. It ensures hosts can maintain accurate, up-to-date property details.

### 3. **Booking System**
Provides a mechanism for guests to search availability and book stays at listed properties. The system validates booking dates, prevents scheduling conflicts, and manages check-in/check-out details. This feature is central to the platform’s operation and user satisfaction.

### 4. **Payment Processing**
Securely processes transactions related to property bookings using integrated payment gateways. Each booking is tied to a payment, and statuses like "pending", "success", or "failed" are tracked. This ensures reliable financial operations for both guests and hosts.

### 5. **Review System**
Enables guests to leave ratings and written feedback on properties after their stay. These reviews help maintain platform quality, build trust, and assist future users in making informed booking decisions. Hosts can also use feedback to improve their services.

### 6. **Database Optimizations**
Implements performance-enhancing techniques such as indexing and caching. These optimizations speed up data retrieval, reduce server load, and ensure the application scales efficiently as the user base grows. It's vital for maintaining a fast and responsive user experience.

---
## API Security

### Key Security Measures

- **Authentication**: JSON Web Tokens (JWT) will be used to securely identify users during requests. This ensures only authenticated users can access protected routes such as bookings and payments.
  
- **Authorization**: Role-based access control ensures that users can only perform actions permitted by their role (e.g., only hosts can list properties, only guests can make bookings). This prevents privilege abuse and enforces user boundaries.

- **Rate Limiting**: API rate limiting will restrict the number of requests per user or IP address within a given time window. This helps prevent abuse such as brute force attacks and server overload.

- **Input Validation & Sanitization**: All user input will be validated and sanitized to protect against common vulnerabilities like SQL injection and cross-site scripting. This ensures data integrity and protects the application from malicious inputs.

### Why Security Matters

- **User Data Protection**: The platform stores sensitive user data, including login credentials and personal details. Strong authentication and encryption are vital to prevent data leaks or identity theft.

- **Secure Payments**: Financial transactions are central to the project. Secure handling of payment data is essential to prevent fraud and build user trust.

- **System Integrity**: Without proper protections like rate limiting and input validation, the backend could be exposed to DDoS attacks, spam, or data corruption. Security measures ensure the system remains stable and reliable.

---
## CI/CD Pipeline

### What is CI/CD?

CI/CD stands for **Continuous Integration** and **Continuous Deployment/Delivery**. It is a development practice that enables teams to automatically test, 
integrate, and deploy code changes with speed and confidence. CI ensures that new code integrates well with the existing codebase by running automated tests, 
while CD automates the release process, pushing validated changes to production or staging environments.

This approach minimizes human error, speeds up delivery cycles, and improves software quality—making it essential for a scalable and evolving project like the Airbnb Clone.

### Tools and Workflow

- **GitHub Actions**: Automates workflows such as running unit tests, linting code, and deploying updates whenever code is pushed or merged into the main branch.
- **Docker**: Provides isolated and reproducible environments for development, testing, and deployment, ensuring consistency across all stages.
- **PostgreSQL & Redis Containers**: Spun up during automated tests to replicate real production environments and ensure code reliability with external services.

CI/CD is critical for delivering new features, bug fixes, and security patches quickly while maintaining the overall health and stability of the application.

---

## API Endpoints Overview

### Users
- `GET /users/`
- `POST /users/`
- `GET /users/{user_id}/`
- `PUT /users/{user_id}/`
- `DELETE /users/{user_id}/`

### Properties
- `GET /properties/`
- `POST /properties/`
- `GET /properties/{property_id}/`
- `PUT /properties/{property_id}/`
- `DELETE /properties/{property_id}/`

### Bookings
- `GET /bookings/`
- `POST /bookings/`
- `GET /bookings/{booking_id}/`
- `PUT /bookings/{booking_id}/`
- `DELETE /bookings/{booking_id}/`

### Payments
- `POST /payments/`

### Reviews
- `GET /reviews/`
- `POST /reviews/`
- `GET /reviews/{review_id}/`
- `PUT /reviews/{review_id}/`
- `DELETE /reviews/{review_id}/`

---

## API Documentation

- **REST API**: Compliant with OpenAPI (Swagger) standards for easy integration.
- **GraphQL**: Offers flexible data fetching for clients needing specific nested or filtered fields.

---

>  _This README is a living document and will evolve as the project progresses._


