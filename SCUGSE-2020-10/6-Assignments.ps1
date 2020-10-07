# Connect and retrieve authentication token
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose


# Get Azure AD group ObjectId property using AzureAD module
Connect-AzureAD
$GroupID = Get-AzureADGroup -SearchString "Autopilot-All" | Select-Object -ExpandProperty "ObjectId"


# Get Win32 app ID using IntuneWin32App module
$Win32AppID = Get-IntuneWin32App -DisplayName "7-Zip 19.00 (x64 edition)" -Verbose | Select-Object -ExpandProperty "id"
$Win32AppID = "dbb50bd3-bbbb-4d15-be23-110171694b3f"

# Create a group based include assignment
$AssignmentArgs = @{
    "Include" = $true
    "ID" = $Win32AppID
    "GroupID" = "efd0b26d-0713-4397-b9fe-2e9b5d916a67"
    "Intent" = "required" #available, uninstall
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentGroup @AssignmentArgs


# Create a group based include assignment with additional configuration
$AssignmentArgs = @{
    "Include" = $true
    "ID" = $Win32AppID
    "GroupID" = "efd0b26d-0713-4397-b9fe-2e9b5d916a67"
    "Intent" = "required" #available, uninstall
    "Notification" = "hideAll"
    "AvailableTime" = (Get-Date).AddHours(1)
    "DeadlineTime" = (Get-Date).AddDays(1)
    "UseLocalTime" = $true
    "DeliveryOptimizationPriority" = "foreground"
    "EnableRestartGracePeriod" = $true
    "RestartNotificationSnooze" = 220
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentGroup @AssignmentArgs

# Clear all assignments for a Win32 app
Remove-IntuneWin32AppAssignment -ID $Win32AppID -Verbose

# Create a group based exclude assignment
$AssignmentArgs = @{
    "Exclude" = $true
    "ID" = $Win32AppID
    "GroupID" = "efd0b26d-0713-4397-b9fe-2e9b5d916a67"
    "Intent" = "required" #available, uninstall
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentGroup @AssignmentArgs


# Add an 'All Devices' assignment
$AssignmentArgs = @{
    "ID" = $Win32AppID
    "Intent" = "required" #available, uninstall
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentAllDevices @AssignmentArgs

# Add an 'All Devices' assignment with additional configuration
$AssignmentArgs = @{
    "ID" = "1e127386-e5cf-43af-bd5b-d261029e6d0f"
    "Intent" = "required" #available, uninstall
    "Notification" = "hideAll"
    "AvailableTime" = (Get-Date).AddHours(1)
    "DeadlineTime" = (Get-Date).AddDays(1)
    "UseLocalTime" = $true
    "DeliveryOptimizationPriority" = "foreground"
    "EnableRestartGracePeriod" = $true
    "RestartNotificationSnooze" = 220
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentAllDevices @AssignmentArgs


# Add an 'All Users' assignment
$AssignmentArgs = @{
    "ID" = $Win32AppID
    "Intent" = "required" #available, uninstall
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentAllUsers @AssignmentArgs

# Add an 'All Users' assignment with additional configuration
$AssignmentArgs = @{
    "ID" = "1e127386-e5cf-43af-bd5b-d261029e6d0f"
    "Intent" = "required" #available, uninstall
    "Notification" = "hideAll"
    "AvailableTime" = (Get-Date).AddHours(1)
    "DeadlineTime" = (Get-Date).AddDays(1)
    "UseLocalTime" = $true
    "DeliveryOptimizationPriority" = "foreground"
    "EnableRestartGracePeriod" = $true
    "RestartNotificationSnooze" = 220
    "Verbose" = $true
}
Add-IntuneWin32AppAssignmentAllUsers @AssignmentArgs