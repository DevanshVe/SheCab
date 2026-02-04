# IDE Setup Guide for HerWayCabs

This guide explains how to open and run the project in **VS Code** or **Spring Tool Suite (STS)**.

## 📂 Project Structure
Ensure your folder is named `HerWayCabProject Folder` and looks like this:
```
HerWayCabProject Folder/
├── microservices/       (Backend - Spring Boot)
│   ├── api-gateway
│   ├── auth-service
│   ├── booking-service
│   ├── discovery-server
│   ├── ...
│   └── docker-compose.yml
├── frontend/            (Frontend - React)
└── ...
```

---

## 🚀 Option 1: Visual Studio Code (Recommended)

### 1. Prerequisites
Install these extensions (Search in Extensions tab `Ctrl+Shift+X`):
*   **Extension Pack for Java** (Microsoft)
*   **Spring Boot Extension Pack** (VMware)
*   **ES7+ React/Redux/React-Native snippets** (Optional, for frontend)

### 2. Import Project
1.  File -> **Open Folder**.
2.  Select `D:\CDAC\HerWayCabProject Folder`.
3.  VS Code will detect the Maven project in `microservices`. Click **"Always"** if asked to trust the authors.
4.  Wait for the Java Language Server to import dependencies (Watch the bottom status bar).

### 3. Run Backend (Microservices)
1.  Click the **Spring Boot Dashboard** icon in the activity bar (Leaf icon).
2.  You will see `microservices-aggregator` and under it, all the apps (`api-gateway`, `auth-service`, etc.).
3.  Right-click on **Apps** (or individual services) and choose **Start** or **Debug**.
    *   *Order Matters:* Start `discovery-server` first, then the rest.

### 4. Run Frontend
1.  Open a Terminal (`Ctrl + ~`).
2.  Navigate to frontend:
    ```powershell
    cd frontend
    ```
3.  Start server:
    ```powershell
    npm run dev
    ```

---

## 🍃 Option 2: Spring Tool Suite (STS) / Eclipse

### 1. Import Backend
1.  File -> **Import...**
2.  Select **Maven** -> **Existing Maven Projects**.
3.  Click **Next**.
4.  Click **Browse** via "Root Directory".
5.  Select `D:\CDAC\HerWayCabProject Folder\microservices` (Select the backend folder, not the root).
6.  Ensure all projects (`api-gateway`, `auth-service`, etc.) are checked.
7.  Click **Finish**.

### 2. Run Backend (Alternative to Boot Dashboard)
If you prefer not to use the Dashboard, you can start services manually:
1.  In **Package Explorer**, expand the project (e.g., `discovery-server`).
2.  Navigate to `src/main/java`.
3.  Right-click the main application file (e.g., `DiscoveryServerApplication.java`).
4.  Select **Run As** -> **Spring Boot App**.
5.  *Repeat this for every service you need.*

### 3. How to Clean & Build in STS
To perform a full "Clean Compile Build" (like `mvn clean package`):
1.  Right-click the parent project `parent-microservices` (or `microservices` folder).
2.  Select **Run As** -> **Maven Build...**
3.  In the **Goals** field, type:
    ```
    clean package -DskipTests
    ```
4.  Click **Run**.
5.  Watch the **Console** tab for "BUILD SUCCESS".

### 4. Run Frontend (in VS Code)
Since you want to use **VS Code** for the frontend:
1.  Open **VS Code**.
2.  File -> **Open Folder**.
3.  Select `D:\CDAC\HerWayCabProject Folder\frontend` (Select only the frontend folder).
4.  Open a Terminal in VS Code (`Ctrl + ~`).
5.  Run the app:
    ```powershell
    npm run dev
    ```

---

## 🐳 Don't Forget Infrastructure!
Regardless of the IDE, your Database and Message Broker must be running in Docker.

**VS Code:**
Right-click `microservices/docker-compose.yml` -> **Compose Up**.

**Manual / STS:**
Open a terminal in `microservices` folder:
```powershell
docker-compose up -d postgres redis rabbitmq zipkin
```
