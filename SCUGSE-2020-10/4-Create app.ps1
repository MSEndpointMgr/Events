# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose



# Get MSI meta data from .intunewin file
$IntuneWinFile = "C:\IntuneWin32App\Output\7z1900-x64.intunewin"
$IntuneWinMetaData = Get-IntuneWin32AppMetaData -FilePath $IntuneWinFile


# Create custom display name like 'Name' and 'Version'
$DisplayName = $IntuneWinMetaData.ApplicationInfo.Name + " " + $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductVersion


# Create MSI detection rule
$DetectionRuleArguments = @{
    "ProductCode" = $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode
    "ProductVersionOperator" = "greaterThanOrEqual"
    "ProductVersion" = $IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductVersion
}
$DetectionRule = New-IntuneWin32AppDetectionRuleMSI @DetectionRuleArguments


# Create operative system requirement rule
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "All" -MinimumSupportedOperatingSystem "1903"


# Create custom return code
$ReturnCode = New-IntuneWin32AppReturnCode -ReturnCode 1337 -Type retry


# Construct a table of default parameters for the Win32 app
$Win32AppArgs = @{
    "FilePath" = $IntuneWinFile
    "DisplayName" = $DisplayName
    "Description" = "SCUG.se demo 2020-10-07"
    "Publisher" = "MSEndpointMgr"
    "InstallExperience" = "system"
    "RestartBehavior" = "suppress"
    "DetectionRule" = $DetectionRule
    "RequirementRule" = $RequirementRule
    "ReturnCode" = $ReturnCode
    "Verbose" = $true
}
Add-IntuneWin32App @Win32AppArgs