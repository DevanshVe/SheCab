@echo off
echo Starting HerWayCabs Microservices...

echo 1. Starting Service Registry (Eureka)...
start "Service Registry" cmd /k "cd microservices\service-registry && mvn spring-boot:run"
timeout /t 10

echo 2. Starting API Gateway...
start "API Gateway" cmd /k "cd microservices\api-gateway && mvn spring-boot:run"
timeout /t 5

echo 3. Starting Auth Service...
start "Auth Service" cmd /k "cd microservices\auth-service && mvn spring-boot:run"

echo 4. Starting Driver Service...
start "Driver Service" cmd /k "cd microservices\driver-service && mvn spring-boot:run"

echo 5. Starting Booking Service...
start "Booking Service" cmd /k "cd microservices\booking-service && mvn spring-boot:run"

echo 6. Starting Payment Service...
start "Payment Service" cmd /k "cd microservices\payment-service && mvn spring-boot:run"

echo 7. Starting KYC Service (if applicable)...
start "KYC Service" cmd /k "cd microservices\kyc-service && mvn spring-boot:run"

echo All services attempt to start. Please check the new windows for success messages.
pause
