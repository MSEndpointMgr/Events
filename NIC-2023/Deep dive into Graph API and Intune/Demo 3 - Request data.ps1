# First things first, authenticate
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


#
# Construct a request using GET method
# - Retrieve data from Graph API
#
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$ManagedDevices = Invoke-RestMethod @Parameters
Clear-Host
$ManagedDevices.value | Select-Object -First 1


#
# Constructing a JSON body object using here-strings - DON'T DO THIS
# 
Clear-Host
$JSONString = @"
{
    "deviceOwner": "Nickolaj",
    "deviceName": "WIN011",
    "deviceDetails": {
        "operatingSystem": "Windows",
        "operatingSystemVersion": "11"
    }
}
"@
$JSONString

# Constructing a body table object using hash-tables, converting it to JSON - USE THIS
Clear-Host
$JSONTable = @{
    deviceOwner = "Nickolaj"
    deviceName = "WIN012"
    deviceDetails = @{
        operatingSystem = "Windows"
        operatingSystemVersion = "12"
    }
}
$JSONTable | ConvertTo-Json
Clear-Host
$JSONTable | ConvertTo-Json -Compress


#
# Construct a request using POST method
# - Add a new item resource to Graph API
#
$BodyTable = @{
    displayName = "HP Devices"
    platform = "windows10AndLater"
    rule = '(device.manufacturer -eq "Dell")'
}
$Parameters = @{
    Method = "Post"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters"
    Body = ($BodyTable | ConvertTo-Json)
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
Clear-Host
Invoke-RestMethod @Parameters


#
# Construct a request using PATCH method
# - Update an existing property of an item resource in Graph API
#
Clear-Host
(Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters" -Headers $AuthenticationHeader -ContentType "application/json").value

$BodyTable = @{
    displayName = "Dell Devices"
}
$Parameters = @{
    Method = "Patch"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters/<enter ID>"
    Body = ($BodyTable | ConvertTo-Json)
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
Clear-Host
Invoke-RestMethod @Parameters


#
# Construct a request using PATCH method, sometimes requires the @odata.type property with the value of the data type
#
$BodyTable = @{
    "@odata.type" = "#microsoft.graph.win32LobApp"
    "displayName" = "7-Zip"
}


#
# Construct a request using DELETE method
# - Remove an item resource from Graph API
#
$Parameters = @{
    Method = "Delete"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters/<enter ID>"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
Clear-Host
Invoke-RestMethod @Parameters
Clear-Host
(Invoke-RestMethod -Method "Get" -Uri "https://graph.microsoft.com/beta/deviceManagement/assignmentFilters" -Headers $AuthenticationHeader -ContentType "application/json").value


#
# Using query parameters - Filtering
#
$SerialNumber = "<enter serial number>"
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities?`$filter=contains(serialNumber,'$($SerialNumber)')"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$AutopilotDevice = Invoke-RestMethod @Parameters
Clear-Host
$AutopilotDevice.value


#
# Using query parameters - Expanding data
#
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/c82acf60-4b9b-4381-b196-c46571a472a2"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$AutopilotDevice = Invoke-RestMethod @Parameters
Clear-Host
$AutopilotDevice

$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/<enter_id>?`$expand=deploymentProfile,intendedDeploymentProfile"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$AutopilotDeviceDeploymentProfile = Invoke-RestMethod @Parameters
Clear-Host
$AutopilotDeviceDeploymentProfile
$AutopilotDeviceDeploymentProfile.intendedDeploymentProfile


#
# Using query parameters - Filtering on a collection property
#
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/v1.0/devices?`$filter=physicalIds/any(p:p eq '[OrderId]:MSE-AAD-UD-B-PRD')"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$AzureADDevice = Invoke-RestMethod @Parameters
Clear-Host
$AzureADDevice.value | Select-Object -Property "id", "displayName", "physicalIds"


#
# Using query parameters - Filtering for a given @odata.type
#
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=(isof('microsoft.graph.windows10CustomConfiguration'))"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$CustomProfiles = Invoke-RestMethod @Parameters
Clear-Host
$CustomProfiles.value | Select-Object -Property '@odata.type', "id", "displayName"


#
# Advanced queries
# - https://learn.microsoft.com/en-us/graph/aad-advanced-queries
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
    #"ConsistencyLevel" = "eventual"
}
Clear-Host
$Parameters = @{
    Method = "Get"
    Uri = 'https://graph.microsoft.com/v1.0/devices/66670736-c6c3-42a7-9f31-1262acc52ad1/transitiveMemberOf/microsoft.graph.group?$count=true'
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$DeviceGroupCount = Invoke-RestMethod @Parameters
$DeviceGroupCount