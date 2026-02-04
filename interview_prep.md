# HerWayCabs - Interview Preparation Guide 🎓

## 1. Project Overview (The "Elevator Pitch") 🚀
**"HerWayCabs is a microservices-based ride-booking platform exclusively designed for women, ensuring safety and reliability."**

**The Problem**: Women often feel unsafe using generic ride-sharing apps due to the lack of stringent verification and mixed-gender environments.
**The Solution**: A closed ecosystem where both Riders and Drivers are verified females.
**The Tech**: Built using a modern **Polyglot Microservices Architecture**:
*   **Backend**: Java Spring Boot (Core Services) & ASP.NET Core (Admin Portal).
*   **Frontend**: React.js with Tailwind CSS.
*   **Infrastructure**: Docker, PostgreSQL (Database per service), Redis (Caching), RabbitMQ (Async Messaging), Zipkin (Distributed Tracing).

---

## 2. The Interview Script 🎤
*(Use this when asked: "Tell me about your project.")*

"Hi, I'm [Your Name]. I built **HerWayCabs**, a secure cab booking system designed specifically for women.

I chose a **Microservices Architecture** to make the system scalable and modular. It consists of four main Java Spring Boot services:
1.  **Auth Service**: Handles JWT-based authentication and enforces our strict 'Female Only' registration policy.
2.  **Driver Service**: Manage driver profiles, real-time availability, and document verification.
3.  **Booking Service**: The core engine that matches riders with drivers and allows location tracking.
4.  **Payment Service**: Processes transactions using a secure gateway integration.

I also implemented an **Admin Portal using ASP.NET Core**, which acts as a Backend-for-Frontend (BFF) for administrators to verify driver documents before they can go online.

The major challenge I solved was **ensuring data consistency across services**. For example, when a user registers as a driver, the Auth service synchronously communicates with the Driver service using **Feign Client** to create a shadow profile, ensuring the user exists in both systems instantly.

I deployed the entire stack using **Docker Compose**, utilizing **Eureka for Service Discovery** and **Spring Cloud Gateway** as the single entry point. This project gave me deep exposure to distributed systems, REST APIs, and full-stack development."

---

## 3. Architecture Deep Dive (Whiteboard Session) 🏛️

**Q: Why Microservices instead of Monolith?**
**A**: "Scalability and Fault Isolation. If the *Payment Service* goes down, users can still book rides. Also, we can scale the *Booking Service* independently during peak hours without touching the rest of the system."

**Q: How do services communicate?**
**A**:
1.  **Synchronous (REST/Feign)**: Used for critical operations. *Example: Auth Service calling Driver Service during registration.*
2.  **Service Discovery (Eureka)**: Services don't hardcode IP addresses. They look up 'DRIVER-SERVICE' in Eureka to find its dynamic location.
3.  **API Gateway**: The frontend only talks to `localhost:8080`. The Gateway routes `/api/auth` to port 8081, `/api/drivers` to 8082, etc.

**Q: Explaining the Database Design?**
**A**: "I used the **Database-per-Service** pattern.
*   `auth_db`: Stores User Credentials & Roles.
*   `driver_db`: Stores Documents & Status.
*   `booking_db`: Stores Ride History.
*   This ensures loose coupling. Services cannot directly query each other's tables; they must go through APIs."

---

## 4. Technical Q&A (Hard Questions) 🔥

### Backend (Spring Boot)
**Q: How did you implement the 'Female Only' restriction?**
**A**: "I implemented a custom check in the `AuthenticationService`. During registration, the payload is inspected. If the gender is not 'Female', the transaction is rejected with a custom `RuntimeException`. This logic resides in the Business Layer to ensure no bad data ever reaches the database."

**Q: How does the Admin Portal verify drivers?**
**A**: "The Admin Portal is an ASP.NET Core app. It consumes the Java `Driver-Service` APIs.
1.  Driver uploads a document update via React.
2.  Admin logs in, fetches the list of `is_verified=false` drivers.
3.  Admin inspects the document (served effectively as a static resource).
4.  Admin clicks 'Verify', which sends a PATCH request to the Java backend to update the status."

### System Design
**Q: How do you handle Driver Availability?**
**A**: "It's a boolean flag in the Driver DB. However, for a production scale, I would utilize **Redis** to store ephemeral location data (`driver_id: {lat, lon}`) because writing GPS updates to PostgreSQL every 5 seconds would kill the database performance."

**Q: What happens if the Payment Gateway fails?**
**A**: "The transaction is marked as `FAILED` in the database, but the Ride status is preserved. This allows the user to retry payment without losing the ride history. I used `@Transactional` annotations to ensure that if a ride is marked 'COMPLETED' but payment fails, the state remains consistent."

### Frontend (React)
**Q: How does the Frontend know which service to call?**
**A**: "It doesn't! The frontend is 'dumb' about the microservices topology. It sends ALL requests to the **API Gateway** (`localhost:8080`). This avoids CORS issues (since everything is on the same origin from the browser's perspective) and simplifies the client code."

---

## 5. Behavioral / Project Challenges 🧠

**Q: What was the hardest bug you faced?**
**A**: "Integrating the Document Upload flow. The `DriverService` needed to accept `MultipartFile`, but passing that through the Frontend -> Gateway -> Service chain caused MIME type issues. I resolved it by ensuring the correct Content-Type headers were propagated and by configuring the Gateway to allow large payloads."

**Q: What would you add next?**
**A**: "Real-time socket communication. Currently, the driver app polls for rides. I would replace this with **WebSockets (STOMP)** so the server can push ride requests instantly to the nearest driver, reducing latency and server load."

---

## 6. Diagram Reference (Mental Model)
*   **User** -> **Gateway** -> **Auth Service** (Login/Register)
*   **User** -> **Gateway** -> **Booking Service** (Book Ride)
*   **Booking Service** -> **Driver Service** (Find Driver)
*   **Booking Service** -> **Payment Service** (Pay)
*   **Admin** -> **Gateway** -> **Driver Service** (Verify)

**Good luck! You have built a sophisticated system. Be confident in your answers!** 💪

---

## 7. Advanced & Scenario-Based Questions (Bonus) 🌟

### Security & Architecture
**Q: Why did you use ASP.NET Core for the Admin Portal? Why not just React?**
**A**: "I wanted to demonstrate a **Polyglot Architecture**. In a real-world enterprise, different teams use different stacks. By using ASP.NET Core as a **BFF (Backend for Frontend)**, I could securely handle the verification logic and session management on the server side, exposing only what's necessary to the Admin UI. It also proves I can integrate distinct technologies (.NET communicating with Java Spring Boot)."

**Q: How do you secure the communication between microservices?**
**A**: "Currently, I rely on the **API Gateway** to handle external security. Internal services communicate within the private Docker network. In a production environment, I would implement **Mutual TLS (mTLS)** or pass the JWT token down the chain (using Request Interceptors) to ensure even internal calls are authenticated."

**Q: Explain the JWT flow in your app.**
**A**: "When a user logs in, the *Auth Service* validates credentials against PostgreSQL. If valid, it generates a signed **JSON Web Token** containing the user's ID, Role (Rider/Driver), and Gender. This token is sent to the Frontend. For subsequent requests (like Booking a Ride), the Frontend attaches this token in the `Authorization: Bearer` header. The Gateway (or individual service) validates the signature to allow access."

### Resilience & Scalability
**Q: What happens if the `Driver Service` goes down? Can I still log in?**
**A**: "Yes! That’s the beauty of Microservices. Login is handled by the `Auth Service`. If `Driver Service` is down, a user can log in, but they might see an error/spinner when trying to load the 'Driver Dashboard' or 'Available Cabs'. The failure is **isolated** to that specific feature."

**Q: How would you scale this for 1 million users?**
**A**:
1.  **Horizontal Scaling**: spin up multiple instances of `Booking Service` and `Driver Service`.
2.  **Load Balancing**: Use the Gateway (or Nginx) to distribute traffic.
3.  **Database Sharding**: Partition the `Rides` table by City or Region.
4.  **Caching**: Use Redis not just for driver locations, but also for frequent queries like 'Ride Types' or 'User Profiles'."

**Q: Why did you use RabbitMQ? (Even if minimal usage)**
**A**: "I used it to decouple heavy operations. For example, when a Ride is completed, we don't want the user to wait for the Invoice Email to be sent. We publish a `RideCompletedEvent` to RabbitMQ. A separate consumer picks it up and handles the notification/logging. This keeps the user experience snappy."
