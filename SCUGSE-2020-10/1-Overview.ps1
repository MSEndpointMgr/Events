# Install IntuneWin32App module from PowerShellGallery
# - Required modules:
# -- AzureAD
# -- PSIntuneAuth
Install-Module -Name "IntuneWin32App"
Get-installedModule -Name IntuneWin32App


# Explore the module
Get-Command -Module "IntuneWin32App"


# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose
$Global:AuthToken