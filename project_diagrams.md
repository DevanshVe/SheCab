# HerWayCabs UML & Design Diagrams 📊

This document contains the structural and behavioral diagrams for the HerWayCabs system.
**Note**: You can view these diagrams directly in VS Code (using a Markdown Preview extension) or on GitHub. They are rendered as high-quality vector graphics.

## 1. Entity Relationship Diagram (ERD)
This diagram shows the logical data model across the microservices.

```mermaid
erDiagram
    USER {
        bigint id PK
        string email
        string password
        string role
        string gender
        boolean is_verified
    }
    DRIVER {
        bigint id PK "FK to USER"
        string document_path
        boolean is_available
        boolean is_verified
        double current_latitude
        double current_longitude
    }
    RIDE {
        bigint id PK
        bigint rider_id "Ref USER"
        bigint driver_id "Ref DRIVER"
        string status
        double fare
        string otp
        timestamp request_time
    }
    PAYMENT {
        bigint id PK
        bigint ride_id "Ref RIDE"
        double amount
        string status
    }

    USER ||--o{ RIDE : requests
    DRIVER ||--o{ RIDE : accepts
    USER ||--|| DRIVER : "is a (if role=DRIVER)"
    RIDE ||--|| PAYMENT : "generates"
```

---

## 2. Use Case Diagram
High-level interactions between actors and the system.

```mermaid
usecaseDiagram
    actor Rider
    actor Driver
    actor Admin

    package HerWayCabs_System {
        usecase "Register/Login" as UC1
        usecase "Request Ride" as UC2
        usecase "View Ride History" as UC3
        usecase "Data Verification" as UC4
        usecase "Upload Documents" as UC5
        usecase "Go Online/Offline" as UC6
        usecase "Accept Ride" as UC7
        usecase "Verify Driver" as UC8
        usecase "Make Payment" as UC9
    }

    Rider --> UC1
    Rider --> UC2
    Rider --> UC3
    Rider --> UC9

    Driver --> UC1
    Driver --> UC3
    Driver --> UC5
    Driver --> UC6
    Driver --> UC7

    Admin --> UC4
    Admin --> UC8
```

---

## 3. Data Flow Diagram (DFD Level 0)
The Context Diagram showing the system as a single process.

```mermaid
graph LR
    User[Users (Rider/Driver)] -- "Credentials, Loc, Requests" --> System((HerWayCabs System))
    Admin -- "Verification Decisions" --> System
    System -- "Ride Status, Notifications" --> User
    System -- "Pending Verifications" --> Admin
    System -- "Payment Request" --> PaymentGateway[Razorpay]
    PaymentGateway -- "Payment Status" --> System
```

## 4. Data Flow Diagram (DFD Level 1)
Breakdown of the main system processes.

```mermaid
graph TD
    User[User] -->|Login Info| Auth[Auth Service]
    Auth -->|Token| User
    
    User -->|Ride Request| Booking[Booking Service]
    Booking -->|Find Driver| DriverProc[Driver Service]
    DriverProc -->|Driver Loc| Booking
    
    Driver[Driver] -->|Availability Update| DriverProc
    Driver -->|Upload Doc| DriverProc
    
    Admin[Admin] -->|Verify| DriverProc
    
    Booking -->|Ride Complete| PayProc[Payment Service]
    PayProc -->|Process| Gateway[Razorpay]
```

---

## 5. Activity Diagrams

### A. Login Flow
```mermaid
stateDiagram-v2
    [*] --> EnterCredentials
    EnterCredentials --> Validate : Submit
    Validate --> CheckDB
    CheckDB --> Success : Valid
    CheckDB --> Failure : Invalid
    Failure --> EnterCredentials : Retry
    Success --> GenerateJWT
    GenerateJWT --> [*]
```

### B. Admin Verification Flow
```mermaid
stateDiagram-v2
    [*] --> ViewDashboard
    ViewDashboard --> SelectPendingDriver
    SelectPendingDriver --> ViewDocument
    ViewDocument --> Decision
    Decision --> Verify : Document Valid
    Decision --> Reject : Document Invalid
    Verify --> UpdateStatus
    UpdateStatus --> [*]
```

### C. Ride Flow (User)
```mermaid
stateDiagram-v2
    [*] --> RequestRide
    RequestRide --> WaitingForDriver
    WaitingForDriver --> DriverAssigned : Match Found
    DriverAssigned --> InProgress : OTP Verified
    InProgress --> Completed : Destination Reached
    Completed --> 1_Payment
    1_Payment --> [*]
```

---

## 6. Class Diagram
Key classes and their relationships in the backend codes.

```mermaid
classDiagram
    class User {
        +Long id
        +String email
        +String role
        +String gender
        +register()
        +login()
    }
    class Driver {
        +Long id
        +String documentPath
        +Boolean isVerified
        +updateLocation()
        +toggleAvailability()
    }
    class Ride {
        +Long id
        +RideStatus status
        +String otp
        +Double fare
        +requestRide()
        +acceptRide()
        +startRide()
        +completeRide()
    }
    class Payment {
        +Long id
        +Double amount
        +PaymentStatus status
        +createOrder()
        +verifyPayment()
    }

    User <|-- Driver : Inherits ID
    User "1" --> "*" Ride : Requests
    Driver "1" --> "*" Ride : Fulfills
    Ride "1" --> "1" Payment : Has
```

---

## 7. Component Diagram
Shows how the microservices are wired together.

```mermaid
graph TD
    Client[React Client] <--> Gateway[API Gateway :8080]
    Gateway <--> Registry[Eureka Server :8761]
    
    Gateway <--> Auth[Auth Service :8081]
    Gateway <--> Driver[Driver Service :8082]
    Gateway <--> Booking[Booking Service :8083]
    Gateway <--> Payment[Payment Service :8084]
    
    Gateway <--> Admin[Admin Portal (ASP.NET) :5000]
    
    Auth -.->|Syncs User| Driver
    Booking -.->|Queries| Driver
    Booking -.->|Triggers| Payment
```

---

## 8. Sequence Diagram (Ride Booking Flow)
The chronological sequence of a successful ride booking.

```mermaid
sequenceDiagram
    participant Rider
    participant Gateway
    participant BookingService
    participant DriverService
    participant Driver

    Rider->>Gateway: POST /api/bookings/request
    Gateway->>BookingService: requestRide(details)
    BookingService->>BookingService: Calculate Fare
    BookingService->>BookingService: Save Ride (REQUESTED)
    BookingService-->>Rider: Return Ride Details
    
    loop Every 5 Seconds
        Driver->>Gateway: GET /api/bookings/available
        Gateway->>BookingService: getAvailableRides()
        BookingService-->>Driver: List of Rides
    end
    
    Driver->>Gateway: POST /accept/{rideId}
    Gateway->>BookingService: acceptRide(rideId, driverId)
    BookingService->>BookingService: Update Status (DRIVER_ASSIGNED)
    BookingService-->>Driver: Success
```

---

## 9. Deployment Diagram
How the application nodes are physically (or virtually) deployed.

```mermaid
graph TD
    subgraph Host Machine (Windows Laptop)
        subgraph Browser Environment
            Frontend[React App :5173]
        end
        
        subgraph Docker / Runtime Environment
            Gateway[API Gateway]
            Auth[Auth Service]
            Booking[Booking Service]
            Driver[Driver Service]
            Payment[Payment Service]
            Admin[Admin Portal]
            Registry[Eureka]
        end
        
        subgraph Database Layer
            PG[(PostgreSQL :5432)]
            Redis[(Redis :6379)]
        end
    end
    
    Frontend --> Gateway
    Admin --> Gateway
    Gateway --> Auth
    Gateway --> Booking
    Gateway --> Driver
    Gateway --> Payment
    
    Auth --> PG
    Booking --> PG
    Driver --> PG
    Payment --> PG
    
    Driver --> Redis
```
