# Audit events are accessible from the beta schema version
Update-MSGraphEnvironment -SchemaVersion "beta"
Connect-MSGraph


# Make the call to get audit events
$AuditEvents = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/auditEvents"
$AuditEvents.Value | Measure-Object

# Handle paging and add all objects returned to a list
if ($AuditEvents.'@odata.nextLink') {
    $AuditEventsList = New-Object -TypeName "System.Collections.ArrayList"
    $AuditEventsList.AddRange($AuditEvents.Value) | Out-Null
    do {
        $AuditEventsNextPage = $AuditEvents | Get-MSGraphNextPage
        $AuditEventsList.AddRange($AuditEventsNextPage.Value) | Out-Null
    }
    while ($AuditEventsNextPage.'@odata.nextLink')
}
$AuditEventsList.Count

# Handle paging with the Microsoft.Graph.Intune module - the easiest way
$AuditEvents = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/auditEvents" | Get-MSGraphAllPages
$AuditEvents | Measure-Object


# Create JSON object using here-strings - DON'T DO THIS
$JSONString = @"
{
    "deviceOwner": "Nickolaj",
    "deviceName": "iPad Gen 1",
    "deviceDetails": {
        "operatingSystem": "iOS",
        "operatingSystemVersion": "1.0"
    }
}
"@
$JSONString


# Create JSON object using hash-tables - USE THIS
$JSONTable = @{
    deviceName = "iPad Gen 1"
    deviceOwner = "Nickolaj"
    deviceDetails = @{
        operatingSystem = "iOS"
        operatingSystemVersion = "1.0"
    }
}
$JSONData = $JSONTable | ConvertTo-Json
$JSONData


# Validate JSON data
function Test-JSON {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable]$InputObject
    )
    try {
        # Convert from hash-table to JSON
        ConvertTo-Json -InputObject $InputObject -ErrorAction Stop

        # Return true if conversion was successful
        return $true
    }
    catch [System.Exception] {
        return $false
    }
}