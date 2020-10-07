# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose



# Create a .intunewin file
$SourceFolder = "C:\IntuneWin32App\Source\7-zip"
$SetupFile = "7z1900-x64.msi"
$OutputFolder = "C:\IntuneWin32App\Output"
New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $SetupFile -OutputFolder $OutputFolder -Verbose


# Read metadata from .intunewin package
$IntunePackageMetaData = Get-IntuneWin32AppMetaData -FilePath "C:\IntuneWin32App\Output\7z1900-x64.intunewin"
$IntunePackageMetaData.ApplicationInfo
$IntunePackageMetaData.ApplicationInfo.MsiInfo
$IntunePackageMetaData.ApplicationInfo.EncryptionInfo


# Explore what's actually in the .intunewin file
Start-Process -FilePath "C:\Program Files\7-Zip\7zFM.exe" -ArgumentList "C:\IntuneWin32App\Output\7z1900-x64.intunewin"


# Expand .intunewin package
# Only works when the encryptionKey and IV properties can be read from the original '.intunewin' that contains the encoded '.intunewin file' within the Contents folder
Expand-IntuneWin32AppPackage -FilePath "C:\IntuneWin32App\Output\7z1900-x64.intunewin" -Force -Verbose


# Read MSI data from source file
Get-MSIMetaData -Path "C:\IntuneWin32App\Source\7-zip\7z1900-x64.msi" -Property "Manufacturer"
Get-MSIMetaData -Path "C:\IntuneWin32App\Source\7-zip\7z1900-x64.msi" -Property "ProductName"
Get-MSIMetaData -Path "C:\IntuneWin32App\Source\7-zip\7z1900-x64.msi" -Property "ProductCode"
Get-MSIMetaData -Path "C:\IntuneWin32App\Source\7-zip\7z1900-x64.msi" -Property "ProductVersion"