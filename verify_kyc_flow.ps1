$ErrorActionPreference = "Stop"

# Configuration
$GatewayUrl = "http://localhost:8080/api"
$AdminPortalUrl = "http://localhost:5000" 

# Colors
function Print-Green ($msg) { Write-Host $msg -ForegroundColor Green }
function Print-Red ($msg) { Write-Host $msg -ForegroundColor Red }
function Print-Yellow ($msg) { Write-Host $msg -ForegroundColor Yellow }

Print-Yellow "🚀 Starting KYC Flow Verification..."

# 1. Register a new test driver
$DriverEmail = "driver_test_$(Get-Random)@herway.com"
$DriverPassword = "password123"
Print-Yellow "1. Registering new driver: $DriverEmail"

try {
    $RegisterBody = @{
        name = "Test Driver"
        email = $DriverEmail
        password = $DriverPassword
        role = "DRIVER"
        phoneNumber = "9876543210"
    } | ConvertTo-Json

    $RegResponse = Invoke-RestMethod -Uri "$GatewayUrl/v1/auth/register" -Method Post -Body $RegisterBody -ContentType "application/json"
    $DriverId = $RegResponse.userId
    Print-Green "   ✅ Registered (ID: $DriverId)"
} catch {
    Print-Red "   ❌ Registration Failed: $_"
    exit
}

# 2. Login to get Token
Print-Yellow "2. Logging in to get JWT..."
try {
    $LoginBody = @{
        email = $DriverEmail
        password = $DriverPassword
    } | ConvertTo-Json

    $LoginResponse = Invoke-RestMethod -Uri "$GatewayUrl/v1/auth/login" -Method Post -Body $LoginBody -ContentType "application/json"
    $Token = $LoginResponse.token
    Print-Green "   ✅ Logged In"
} catch {
    Print-Red "   ❌ Login Failed: $_"
    exit
}

# 3. Try to go Online (Expect Failure)
Print-Yellow "3. Attempting to go ONLINE (Should FAIL)..."
try {
    $Headers = @{ Authorization = "Bearer $Token" }
    # Note: DriverService uses @RequestParam for status
    Invoke-RestMethod -Uri "$GatewayUrl/drivers/$DriverId/availability?status=true" -Method Post -Headers $Headers -ContentType "application/json"
    Print-Red "   ❌ FAILURE: Unverified driver was allowed to go online!"
    exit
} catch {
    # We expect a 500 or 400 error with our message
    if ($_.Exception.Response.StatusCode -eq "InternalServerError" -or $_.Exception.Response.StatusCode -eq "BadRequest") {
        Print-Green "   ✅ BLOCKED: Server rejected unverified driver (Expected behavior)."
    } else {
        Print-Red "   ⚠️ Unexpected Error: $($_.Exception.Message)"
    }
}

# 4. Verify Driver via Admin Portal Logic (Simulating Admin action)
# Since we might not have Admin Portal running, we call the DRIVER SERVICE verify endpoint directly (as if we were the Admin Portal)
# In reality, Admin Portal calls POST /api/drivers/{id}/verify
Print-Yellow "4. Admin verifying driver..."
try {
    # Note: This endpoint is internal/open in our current MVP config (not behind Gateway auth for demo simplicity, or we use Admin Token)
    # Getting an Admin Token is complex here, so we'll assume the internal endpoint is reachable via Gateway if configured, 
    # OR we use the Admin Console simulation.
    # Let's try hitting the verified endpoint.
    
    Invoke-RestMethod -Uri "$GatewayUrl/drivers/$DriverId/verify" -Method Post -ContentType "application/json"
    Print-Green "   ✅ Driver Verified Successfully"
} catch {
    Print-Red "   ❌ Verification Failed: $_" 
    # Try alternate path if Gateway blocks it (direct to service?) No, sticking to Gateway.
    exit
}

# 5. Try to go Online AGAIN (Expect Success)
Print-Yellow "5. Attempting to go ONLINE again (Should SUCCEED)..."
try {
    $Headers = @{ Authorization = "Bearer $Token" }
    $Response = Invoke-RestMethod -Uri "$GatewayUrl/drivers/$DriverId/availability?status=true" -Method Post -Headers $Headers -ContentType "application/json"
    
    if ($Response.isAvailable -eq $true) {
        Print-Green "   ✅ SUCCESS: Verified driver is now ONLINE."
    } else {
        Print-Red "   ❌ Status did not change."
    }
} catch {
    Print-Red "   ❌ Failed to go online: $_"
}

Print-Green "🎉 KYC Flow Verification Complete!"
