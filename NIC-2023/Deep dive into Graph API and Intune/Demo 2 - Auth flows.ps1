#
# Authorization Code
# - Using custom app registration
#
$Parameters = @{
    TenantId = "<enter_tenantid>"
    ClientId = "<enter_clientid>"
    RedirectUri = "http://localhost"
}
$AccessToken = Get-MsalToken @Parameters
$AuthenticationHeader = @{
    "Content-Type" = "application/json"
    "Authorization" = $AccessToken.CreateAuthorizationHeader()
    "ExpiresOn" = $AccessToken.ExpiresOn.LocalDateTime
}
Clear-Host
$AuthenticationHeader
$MobileApps = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Headers $AuthenticationHeader -ContentType "application/json"
$MobileApps.value | Select-Object -First 1


#
# Client Credentials
# - Using custom app registration
#
$Parameters = @{
    TenantId = "<enter_tenantid>"
    ClientId = "<enter_clientid>"
    ClientSecret = ("<client_secret>" | ConvertTo-SecureString -AsPlainText -Force)
    RedirectUri = "http://localhost"
}
$AccessToken = Get-MsalToken @Parameters
$AuthenticationHeader = @{
    "Content-Type" = "application/json"
    "Authorization" = $AccessToken.CreateAuthorizationHeader()
    "ExpiresOn" = $AccessToken.ExpiresOn.LocalDateTime
}
Clear-Host
$AuthenticationHeader
$MobileApps = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Headers $AuthenticationHeader -ContentType "application/json"


#
# Device Code
# - Using native Microsoft Intune PowerShell application
#
$Parameters = @{
    TenantId = "<enter_tenantid>"
    ClientId = "<enter_clientid>"
    RedirectUri = "http://localhost"
    DeviceCode = $true # This is the only difference parameters wise from authorization code flow
}
$AccessToken = Get-MsalToken @Parameters
$AuthenticationHeader = @{
    "Content-Type" = "application/json"
    "Authorization" = $AccessToken.CreateAuthorizationHeader()
    "ExpiresOn" = $AccessToken.ExpiresOn.LocalDateTime
}
Clear-Host
$AuthenticationHeader
$MobileApps = Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps" -Headers $AuthenticationHeader -ContentType "application/json"
$MobileApps.value | Select-Object -First 1