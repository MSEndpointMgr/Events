# Select specific properties during the call to Graph API
Get-IntuneManagedDevice -Select deviceName, complianceState, managementAgent


# Filtering objects during the call to Graph API
Get-AADGroup -Filter "startswith(displayName, 'Test')"
Get-IntuneManagedDevice -Filter "startswith(deviceName, 'CL')"


# Filtering using the PowerShell pipeline instead as we're used to
Get-IntuneDeviceCompliancePolicy | Where-Object { $_.displayName -like "Windows*" }


# Get debug information if an error occurs
Get-IntuneDeviceCompliancePolicy -Filter "startswith(displayName, 'iOS')" # This will throw an error
Get-MSGraphDebugInfo


# Get devices based on compliance state
Get-IntuneManagedDevice -Filter "(complianceState eq 'compliant')" | Select-Object -Property deviceName, complianceState
Get-IntuneManagedDevice -Filter "(complianceState eq 'unknown')" | Select-Object -Property deviceName, complianceState
Get-IntuneManagedDevice -Filter "(complianceState eq 'noncompliant')" | Select-Object -Property deviceName, complianceState


# Get devices based on operative system
Get-IntuneManagedDevice -Filter "(contains(operatingsystem, 'iOS'))" | Select-Object -Property isSupervised, deviceName
Get-IntuneManagedDevice -Filter "(contains(operatingsystem, 'Android'))" | Select-Object -Property model, deviceName


# Handling properties of boolean type
Get-IntuneManagedDevice -Filter "isSupervised eq 'False'" # Nope
Get-IntuneManagedDevice -Filter "isSupervised eq False" # Nope
Get-IntuneManagedDevice -Filter "isSupervised eq false" # Winner


# Dealing with encoding issues when using Invoke-MSGraphRequest
$Filter = "startswith(deviceName%2C+`'CL`')"
$ManagedDevices = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/managedDevices?`$filter=$($Filter)"
$ManagedDevices.Value