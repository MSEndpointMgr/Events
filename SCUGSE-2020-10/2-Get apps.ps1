# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose



# Retrieve all Win32 apps in Intune
Get-IntuneWin32App -Verbose | Select-Object -Property displayName


# Get a specific Win32 app with a name that starts with '7-zip'
# Performs a sort of wildcard search, e.g. *<string>*
Get-IntuneWin32App -DisplayName "7-zip" -Verbose | Select-Object -Property displayName


# Get a specific Win32 app with a certain ID
Get-IntuneWin32App -ID "1e127386-e5cf-43af-bd5b-d261029e6d0f" -Verbose | Select-Object -Property displayName

