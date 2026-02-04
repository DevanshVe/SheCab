# Manual Startup Guide 🚀

This guide explains how to start the **HerWayCabs** system manually, including the new **Document Verification** features.

## Prerequisites
- Java 17+ (for backend)
- Node.js 16+ (for frontend)
- .NET 8.0 SDK (for admin portal)
- PostgreSQL & Razorpay Account (configured in `.env` or properties)

---

## 1. Start Support Services (Docker)
Ensure your databases and messaging queues are up.
```bash
cd microservices
docker-compose up -d postgres redis rabbitmq zipkin
```

## 2. Start Backend Microservices (Order Matters!)
Open separate terminals for each service and run:

**Terminal 1: Service Registry** (Port 8761)
```bash
cd microservices/service-registry
mvn spring-boot:run
```
*Wait for "Started ServiceRegistryApplication"*.

**Terminal 2: API Gateway** (Port 8080)
```bash
cd microservices/api-gateway
mvn spring-boot:run
```

**Terminal 3: Auth Service** (Port 8081)
```bash
cd microservices/auth-service
mvn spring-boot:run
```

**Terminal 4: Driver Service** (Port 8082) 🚗 **(UPDATED)**
*Contains new Document Upload logic.*
```bash
cd microservices/driver-service
mvn spring-boot:run
```

**Terminal 5: Booking Service** (Port 8083)
```bash
cd microservices/booking-service
mvn spring-boot:run
```

**Terminal 6: Payment Service** (Port 8084)
```bash
cd microservices/payment-service
mvn spring-boot:run
```

---

## 3. Start Admin Portal (Port 5000) 👩‍
This is where you verify drivers.
```bash
cd microservices/admin-portal
dotnet run
```
Access at: `http://localhost:5000`

---

## 4. Start Frontend (Port 5173) 📱
```bash
cd frontend
npm install
npm run dev
```
Access at: `http://localhost:5173`

---

## 5. Verification Flow (New!)
1.  **Driver Registration**: 
    - Go to `http://localhost:5173/register`.
    - Select **Driver** role.
    - **Upload License**: You will see a new file input. Select an image.
2.  **Admin Verification**:
    - Go to `http://localhost:5000/Admin`.
    - You will see the new driver.
    - Click **"View Doc"** to see the uploaded license.
    - If valid, click **"Verify Documents"**.
3.  **Go Online**:
    - Driver logs in and toggles "Online". It should now work!

---

## Note on File Storage
Uploaded documents are stored locally in:
`D:\CDAC\HerWayCabProject Folder\uploads\documents\`
Ensure this folder has write permissions.
