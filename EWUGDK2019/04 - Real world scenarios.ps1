# Restart an Intune managed device
$ManagedDevice = Get-IntuneManagedDevice -Filter "deviceName eq 'CL02'" -Select "deviceName", "id"
Invoke-IntuneManagedDeviceRebootNow -managedDeviceId $ManagedDevice.id


# Get managed devices compliance states
$ManagedDevices = Get-IntuneManagedDevice -Select "deviceName", "complianceState" | Get-MSGraphAllPages
$ManagedDevices
Get-IntuneDeviceCompliancePolicyDeviceStateSummary -Select "compliantDeviceCount", "nonCompliantDeviceCount", "notApplicableDeviceCount", "unknownDeviceCount"


# Rename all iOS devices that are Supervised with serialNumber as the name
$ManagedDevices = Get-IntuneManagedDevice -Filter "(contains(operatingsystem, 'iOS'))" | Get-MSGraphAllPages | Select-Object -Property deviceName, serialNumber, id, isSupervised
if ($ManagedDevices -ne $null) {
    foreach ($ManagedDevice in $ManagedDevices) {
        $ManagedDeviceID = $ManagedDevice.id
        $Resource = "deviceManagement/managedDevices('$ManagedDeviceID')/setDeviceName"
        $GraphVersion = "Beta"
        $GraphURI = "https://graph.microsoft.com/{0}/{1}" -f $GraphVersion, $Resource
        
        # Construct JSON object for POST call
        $JSONTable = @{
            deviceName = "$($ManagedDevice.serialNumber)"
        }
        $JSONData = $JSONTable | ConvertTo-Json

        # Invoke rename request
        Invoke-MSGraphRequest -HttpMethod POST -Url $GraphURI -Content $JSONData
    }
}


# Generate dummy IMEI numbers for corporate device identifiers import
$FilePath = "C:\Temp\IMEI.csv"
"Identifier,Type,Description" | Out-File -FilePath $FilePath -NoClobber
(1..3) | ForEach-Object {( (0..14) | ForEach-Object { Get-Random -Minimum 0 -Maximum 9 } ) -join '' } | ForEach-Object { "$_,imei,iPhone XS PlusPlus" } | Out-File -FilePath $FilePath -NoClobber -Force -Append

# Get access token
$AuthToken = Get-MSIntuneAuthToken -TenantName "configmgrse.onmicrosoft.com"

# Upload corporate device identifiers
$CorporateIdentifierData = Import-Csv -Path $FilePath -Delimiter "," -Encoding UTF8 -ErrorAction Stop
foreach ($CorporateIdentifierItem in $CorporateIdentifierData) {
    # Construct table for new corporate device identifiers
    $CorporateIdentifierTable = New-Object -TypeName System.Collections.Hashtable
    $CorporateIdentifierTable.Add("importedDeviceIdentifier", $CorporateIdentifierItem.Identifier)
    $CorporateIdentifierTable.Add("importedDeviceIdentityType", $CorporateIdentifierItem.Type)
    $CorporateIdentifierTable.Add("description", $CorporateIdentifierItem.Description)

    $DeviceIdentitiyList = New-Object -TypeName System.Collections.ArrayList
    $DeviceIdentitiyList.Add($CorporateIdentifierTable) | Out-Null

    # Convert ordered hash-table to JSON 
    $CorporateIdentifier = [ordered]@{
        "overwriteImportedDeviceIdentities" = $false
        "importedDeviceIdentities" = @($DeviceIdentitiyList)
    }
    $CorporateIdentifierJSON = ConvertTo-Json -InputObject $CorporateIdentifier -Depth 100

    # Invoke Graph API call
    $CorporateResource = "https://graph.microsoft.com/beta/deviceManagement/importedDeviceIdentities/importDeviceIdentityList"
    (Invoke-RestMethod -Uri $CorporateResource -Method Post -ContentType "application/json" -Body $CorporateIdentifierJSON -Headers $AuthToken -ErrorAction Stop -Verbose:$false).value
}