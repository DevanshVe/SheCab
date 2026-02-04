# HerWayCabs Database Schema Documentation 🗄️

This document outlines the database design and table structures for the **HerWayCabs** microservices ecosystem. Each microservice manages its own database (Database-per-Service pattern).

---

## 1. Auth Service Database (`auth_db`)
**Purpose**: Manages User Identity, Authentication, and RBAC.

### Table: `users`
| Column Name | Data Type | Constraint | Description |
|---|---|---|---|
| `id` | BIGINT | PK, Auto Inc | Unique User ID |
| `name` | VARCHAR | Not Null | Full Name of the user |
| `email` | VARCHAR | Unique, Not Null | User's email address |
| `password` | VARCHAR | Not Null | BCrypt Encrypted Password |
| `role` | VARCHAR | Enum (RIDER/DRIVER) | User Role |
| `phone_number` | VARCHAR | | Contact Number |
| `gender` | VARCHAR | | User Gender (Enforced 'Female') |
| `is_verified` | BOOLEAN | Default False | Email/Phone Verification status |
| `current_latitude` | DOUBLE | | Cached Latitude |
| `current_longitude` | DOUBLE | | Cached Longitude |
| `is_available` | BOOLEAN | | Availability Status (if Driver) |

---

## 2. Driver Service Database (`driver_db`)
**Purpose**: Manages Driver details, real-time status, and documents.

### Table: `drivers`
| Column Name | Data Type | Constraint | Description |
|---|---|---|---|
| `id` | BIGINT | PK | Shared ID with `users.id` |
| `name` | VARCHAR | | Driver Name |
| `email` | VARCHAR | | Driver Email |
| `phone_number` | VARCHAR | | Contact Number |
| `gender` | VARCHAR | | Driver Gender |
| `is_verified` | BOOLEAN | | Document Verification Status |
| `is_available` | BOOLEAN | | Online/Offline Status |
| `current_latitude` | DOUBLE | | Real-time Latitude |
| `current_longitude` | DOUBLE | | Real-time Longitude |
| `document_path` | VARCHAR | | Local path to uploaded License |

---

## 3. Booking Service Database (`booking_db`)
**Purpose**: Manages Ride lifecycle and History.

### Table: `rides`
| Column Name | Data Type | Constraint | Description |
|---|---|---|---|
| `id` | BIGINT | PK, Auto Inc | Unique Ride ID |
| `rider_id` | BIGINT | Not Null | ID of the User requesting ride |
| `driver_id` | BIGINT | Nullable | ID of the assigned Driver |
| `status` | VARCHAR | Enum | REQUESTED, DRIVER_ASSIGNED, STARTED, COMPLETED, CANCELLED |
| `fare` | DOUBLE | | Calculated Fare Cost |
| `otp` | VARCHAR | | 4-digit OTP for ride start |
| `pickup_location` | VARCHAR | | Pickup Address String |
| `pickup_latitude` | DOUBLE | | Pickup Coord |
| `pickup_longitude` | DOUBLE | | Pickup Coord |
| `drop_location` | VARCHAR | | Drop Address String |
| `drop_latitude` | DOUBLE | | Drop Coord |
| `drop_longitude` | DOUBLE | | Drop Coord |
| `request_time` | TIMESTAMP | | When ride was requested |
| `start_time` | TIMESTAMP | | When ride started |
| `end_time` | TIMESTAMP | | When ride finished |

---

## 4. Payment Service Database (`payment_db`)
**Purpose**: Manages Transaction records.

### Table: `payments`
| Column Name | Data Type | Constraint | Description |
|---|---|---|---|
| `id` | BIGINT | PK, Auto Inc | Unique Payment ID |
| `ride_id` | BIGINT | Not Null | Reference to Booking ID |
| `rider_id` | BIGINT | Not Null | Reference to User ID |
| `amount` | DOUBLE | Not Null | Amount to be paid |
| `status` | VARCHAR | Enum | PENDING, COMPLETED, FAILED |
| `razorpay_order_id` | VARCHAR | | Razorpay Order Reference |
| `razorpay_payment_id` | VARCHAR | | Razorpay Payment Reference |
| `razorpay_signature` | VARCHAR | | Security Signature |
| `created_at` | TIMESTAMP | | Record creation time |
| `completed_at` | TIMESTAMP | | Payment completion time |

---
## Relationships
Since this is a Microservices Architecture, there are **NO Foreign Keys** between tables of different services. Relationships are logical (Software Level).
*   `drivers.id` 🔗 `users.id` (1:1)
*   `rides.rider_id` 🔗 `users.id` (1:N)
*   `rides.driver_id` 🔗 `drivers.id` (1:N)
*   `payments.ride_id` 🔗 `rides.id` (1:1)
