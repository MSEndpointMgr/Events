# Install Microsoft.Graph.Intune module and import
Install-Module -Name "Microsoft.Graph.Intune"
Import-Module -Name "Microsoft.Graph.Intune"


# Admin consent for first time use in organization
Connect-MSGraph -AdminConsent


# Authenticate and connect to Graph API
Connect-MSGraph


# Commands in the module
Get-Command -Module Microsoft.Graph.Intune -Name "*" | Format-Table -AutoSize
(Get-Command -Module Microsoft.Graph.Intune -Name "*" | Format-Table -AutoSize).Count


# Get information about connected Graph API environment
Get-MSGraphEnvironment


# Change from v1.0 (production) to Beta API schema version
Update-MSGraphEnvironment -SchemaVersion v1.0


# Use your custom Enterprise Application (default is Microsoft Intune PowerShell enterprise application)
Update-MSGraphEnvironment -AppId "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"


# Re-connect using the updated environment settings
Connect-MSGraph
Get-MSGraphEnvironment


# Fallback cmdlet for advanced calls to Graph API
Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/managedDevices"