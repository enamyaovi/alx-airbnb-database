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

#### Notes

* Registration logic is now DRY and manager-driven, avoiding issues from duplicated `set_password()` calls.
* Serializer tests act as a foundation for future test patterns across the app.
* Next step: expand tests for `UserDetailSerializer`, `UsersListSerializer`, and `PasswordChangeSerializer`.

---

### Commit 3: Accounts App Serializer Enhancements & Test Completion

**Date:** 2025-08-04
**Focus:** Finalizing Serializer Logic, Property Methods, and Test Coverage

#### Changes Made:

##### Core Enhancements

* Added a custom model property to return users' full names.
* Refactored the `UserDetailSerializer` to override `to_representation()` for properly formatted `date_joined` values due to test issues with datetime serialization.
* Removed `username` field from serializer definition to align with the model (field does not exist on the model).
* Fixed `validate_email()` method signature to accept `value` and added an explicit return to avoid `null` constraint violations during email updates.
* Updated `UsersListSerializer` to reflect accurate `read_only_fields` based on model.
* Added a `SerializerMethodField` in `UsersListSerializer` to expose the user full name using the model property.
* Refactored `PasswordChangeSerializer.validate()` to return `attrs`, which was previously missing, causing unintended behavior.

##### Password Logic Refactor

* Rewrote both `update()` and `create()` methods of `PasswordChangeSerializer` to call `set_password()` based on whether an `instance` is passed or the user is fetched from context. This now aligns with DRF’s internal logic of invoking `update` if instance is passed, otherwise `create`.

##### Test Suite Enhancements

* Refactored test classes to use `setUpTestData()` where applicable for efficiency.
* Renamed variables and methods for clearer test intent.
* Wrote comprehensive unit tests for:

  * `UserDetailSerializer`
  * `UsersListSerializer`
  * `PasswordChangeSerializer`
* Used `MagicMock()` and `Faker` to isolate and modularize test inputs.
* Manually created DB entries to validate logic as tested in Django shell.

#### Notes:

* Password change logic now conforms to DRF best practices and provides flexibility based on how the serializer is instantiated.
* Tests are now complete and modular enough to serve as regression checks for future changes.
* Next step: Document existing code and integrate permission checks and connect serializer logic to API views.
