# Commit History and Deliverables

Welcome to my **Airbnb Clone** project. This README serves as a simple log of key commit deliverables and progress updates. I'm building this to reinforce my Django skills and to continue learning through hands-on experience.

---

### Commit 1: Initial Project Setup

**Date:** 2025-07-20
**Focus:** Setup

#### Changes Made:

* Initialized the Django project and created the main settings structure.
* Configured environment-based settings using `django-environ`.
* Installed and configured `django-cors-headers` for CORS support.
* Created `.gitignore` file to exclude sensitive and unnecessary files.
* Set up a Celery app with RabbitMQ as the message broker.
* Changed the default Django admin URL for better security.

#### Notes:

* Using a single `settings.py` file for now, with conditional logic for switching between `DEVELOPMENT` and `PRODUCTION`.
* Environment variables are read from a `.env` file located in the base directory.

#### Affected Areas:

* `settings.py`
* `.env`
* `requirements.txt`
* `celery.py`

---

### Commit 2: Accounts App Setup & Serializer Testing

**Date:** 2025-07-28
**Focus:** Serializer Creation, Testing, and User Registration Logic

#### Changes Made:

##### Core Functionality

* Installed and configured `djangorestframework` for API serialization and validation.
* Created custom serializer classes for:

  * `RegisterUserSerializer` (user registration)
  * `UserDetailSerializer` (user profile)
  * `UsersListSerializer` (basic user info listing)
  * `PasswordChangeSerializer` (password update logic)

##### User Model Enhancements

* Updated `User` model to include `first_name` and `last_name` with default values (`John`, `Doe`).
* Replaced manual `set_password()` call in `RegisterUserSerializer.create()` with `User.objects.create_user(...)` to prevent password handling bugs.

##### Validation Improvements

* Integrated Django's `validate_password()` into the registration serializer.
* Added `email-validator` to verify proper formatting and MX record presence.
* Used DRF's `UniqueValidator` to enforce unique email addresses.

##### Tests Written

* Created a custom `Faker` provider for realistic fake user data (`password_gen`, `role_picker`).
* Wrote comprehensive tests for:

  * Valid user registration and field serialization
  * Password hashing and email normalization
  * Duplicate email registration
  * Missing required fields (using `subTest`)
  * Invalid email formats
  * Weak/common password rejection
  * Ensured `password` is write-only in response

---

#### Notes

* Registration logic is now DRY and manager-driven, avoiding issues from duplicated `set_password()` calls.
* Serializer tests act as a foundation for future test patterns across the app.
* Next step: expand tests for `UserDetailSerializer`, `UsersListSerializer`, and `PasswordChangeSerializer`.
