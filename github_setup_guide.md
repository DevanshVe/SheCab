# How to Push HerWayCabs to GitHub

## Prerequisites
-   **Git** installed on your machine.
-   A **GitHub Account**.

## Step 1: Initialize Git Repository
1.  Open your terminal (PowerShell or CMD).
2.  Navigate to the **Project Root** (where the `.gitignore` is):
    ```powershell
    cd "d:\CDAC\HerWayCabProject Folder"
    ```
3.  Initialize Git:
    ```powershell
    git init
    ```

## Step 2: Add Files
1.  Add all files (the `.gitignore` will ensure we don't upload junk):
    ```powershell
    git add .
    ```
2.  Commit the changes:
    ```powershell
    git commit -m "Initial commit: HerWayCabs Full Stack (Microservices + React + Docs)"
    ```

## Step 3: Create Repository on GitHub
1.  Go to [github.com/new](https://github.com/new).
2.  **Repository Name**: Enter your unique name (e.g., `HerWayCabs-Project` or `Final-Year-Project`).
3.  **Do NOT** check "Initialize with README", .gitignore, or license.
4.  Click **Create repository**.

## Step 4: Link and Push
1.  **Link your local repo to GitHub**:
    ```powershell
    git remote add origin https://github.com/DevanshVe/SheCab.git
    ```
2.  **Push the code**:
    ```powershell
    git branch -M main
    git push -u origin main
    ```

    *If it asks simply for credentials, a browser window might pop up to sign you in.*

## Done! 🚀
Your code is now on GitHub.
