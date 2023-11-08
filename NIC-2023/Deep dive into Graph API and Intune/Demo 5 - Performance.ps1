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


#
# Optimization - Select only what's required
#
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices?`$select=deviceName"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
$ManagedDevices = Invoke-RestMethod @Parameters
Clear-Host
$ManagedDevices.value


#
# Optimization - Filter at the request level rather than in PowerShell code
#
$Command1 = Measure-Command {
    $Parameters = @{
        Method = "Get"
        Uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations"
        Headers = $AuthenticationHeader
        ContentType = "application/json"
    }
    $Response = Invoke-RestMethod @Parameters
    $CustomProfiles = $Response.value | Where-Object { $PSItem.'@odata.type' -like "#microsoft.graph.windows10CustomConfiguration" }
    $CustomProfiles | Select-Object -Property '@odata.type', "id", "displayName"
}
$Command1

$Command2 = Measure-Command {
    $Parameters = @{
        Method = "Get"
        Uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=(isof('microsoft.graph.windows10CustomConfiguration'))"
        Headers = $AuthenticationHeader
        ContentType = "application/json"
    }
    $CustomProfiles = Invoke-RestMethod @Parameters
    $CustomProfiles.value | Select-Object -Property '@odata.type', "id", "displayName"
}
$Command2


#
# Optimization - exportJobs resource
#
$BodyTable = @{
    reportName = "Devices"
    format = "json" # Default is CSV
}
$Parameters = @{
    Method = "Post"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs"
    Headers = $AuthenticationHeader
    Body = ($BodyTable | ConvertTo-Json)
    ContentType = "application/json"
}
$ExportJobResponse = Invoke-RestMethod @Parameters
Clear-Host
do {
    Write-Output -InputObject "Waiting for 1 seconds before retrieving completion status"
    Start-Sleep -Seconds 1
    $Parameters = @{
        Method = "Get"
        Uri = "https://graph.microsoft.com/beta/deviceManagement/reports/exportJobs/$($ExportJobResponse.id)"
        Headers = $AuthenticationHeader
        ContentType = "application/json"
    }
    $ExportJobResponse = Invoke-RestMethod @Parameters
}
until ($ExportJobResponse.status -like "completed")
$ExportJobResponse


#
# Optimization - batch requests
#

#
# Without batching in a foreach loop, 1 item at a time
#

# Retrieve access token for Graph API
$AccessToken = Get-AccessToken -TenantID "domain.com"

# Read user group membership identities
$GroupID = "<guid>"
$UserGroupMembers = Invoke-MSGraphOperation -Get -APIVersion "v1.0" -Resource "groups/$($GroupID)/members"

# Construct list for Graph API responses
$UserRegisteredDevices = New-Object -TypeName "System.Collections.Generic.List[object]"

$Command = Measure-Command {
    foreach ($UserGroupMember in $UserGroupMembers) {
        $RegisteredDevice = Invoke-MSGraphOperation -Get -APIVersion "beta" -Resource "users/$($UserGroupMember.Id)/registeredDevices"
        foreach ($DeviceItem in $RegisteredDevice) {
            $UserRegisteredDevices.Add($DeviceItem)
        }
    }
    $UserRegisteredDevices.Count
}
$Command

#
# With batching, 20 items at a time
#

# Set batch size, 20 is the maximum
$BatchSize = 20

# Construct list for Graph API responses of each batch
$UserRegisteredDevices = New-Object -TypeName "System.Collections.Generic.List[object]"

# Construct list for batch requests
$BatchRequestList = New-Object -TypeName "System.Collections.Generic.List[object]"

# Construct batch requests with size defined by $BatchSize
for ($i = 0; $i -lt $UserGroupMembers.Count; $i += $BatchSize) {
    # Calculate end position of current batch
    $EndPosition = $i + $BatchSize - 1
    if ($EndPosition -ge $UserGroupMembers.Count) {
        $EndPosition = $UserGroupMembers.Count
    }

    # Set current index for each batch request based of current count of $i (current count of array items)
    $Index = $i

    # Construct list object for current batch request
    $CurrentBatchList = New-Object -TypeName "System.Collections.Generic.List[object]"

    # Process each item in array from current index to end position and add to current batch list
    foreach ($UserGroupMember in $UserGroupMembers[$i..($EndPosition)]) {
        $BatchRequest = [PSCustomObject]@{
            "Id" = ++$Index
            "Method" = "GET"
            "Url" = "users/$($UserGroupMember.Id)/registeredDevices"
        }
        $CurrentBatchList.Add($BatchRequest)
    }

    # Construct current batch request object for Graph API call containing all batch requests defined in $CurrentBatchList
    $BatchRequest = @{
        "Method" = "Post"
        "Uri" = 'https://graph.microsoft.com/beta/$batch'
        "ContentType" = "application/json"
        "Headers" = $Global:AuthenticationHeader
        "ErrorAction" = "Stop"
        "Body" = @{
            "requests" = $CurrentBatchList
        } | ConvertTo-Json
    }
    $BatchRequestList.Add($BatchRequest)
}

$Command = Measure-Command {
    # Call Graph API for each batch request
    foreach ($BatchRequestItem in $BatchRequestList) {
        $Responses = Invoke-RestMethod @BatchRequestItem
        foreach ($ResponseItem in $Responses.responses) {
            foreach ($ResponseValueItem in $ResponseItem.body.value) {
                if ($ResponseValueItem -ne $null) {
                    $UserRegisteredDevices.Add($ResponseValueItem)
                }
            }
        }
    }
    $UserRegisteredDevices.Count
}
$Command