# Retrieve auth token required for accessing Microsoft Graph
# Delegated authentication is currently supported only, app-based authentication is on the todo-list
Connect-MSIntuneGraph -TenantName "tenant.onmicrosoft.com" -Verbose



# Create more detailed detection rules, e.g. for file or script
New-IntuneWin32AppDetectionRuleFile -Existence -Path "C:\Folder1" -FileOrFolder "Folder2" -DetectionType doesNotExist
New-IntuneWin32AppDetectionRuleFile -Existence -Path "C:\Folder" -FileOrFolder "File.txt" -DetectionType "exists"
New-IntuneWin32AppDetectionRuleRegistry -StringComparison -KeyPath "HKEY_LOCAL_MACHINE\SOFTWARE\Events" -ValueName "SCUG" -StringComparisonOperator "equal" -StringComparisonValue "Awesome"
New-IntuneWin32AppDetectionRuleScript -ScriptFile "C:\IntuneWin32App\Detection\Script.ps1"
New-IntuneWin32AppDetectionRuleMSI -ProductCode "{GUID}" -ProductVersionOperator "greaterThanOrEqual" -ProductVersion "1.0.0"


# There's also support for adding multiple detection rules, used with the Add-IntuneWin32App function
# But you can't mix between Script and any other type
# Only supported to add multiple detection rules as follows:
# - Mixing between MSI, File and Registry types
# - Script type can only be used as a standalone detection rule
$DetectionRules = New-Object -TypeName "System.Collections.ArrayList"
$DetectionRule1 = New-IntuneWin32AppDetectionRuleFile -Existence -Path "C:\Folder" -FileOrFolder "File.txt" -DetectionType "exists"
$DetectionRules.Add($DetectionRule1) | Out-Null
$DetectionRule2 = New-IntuneWin32AppDetectionRuleRegistry -StringComparison -KeyPath "HKEY_LOCAL_MACHINE\SOFTWARE\Events" -ValueName "SCUG" -StringComparisonOperator "equal" -StringComparisonValue "Awesome"
$DetectionRules.Add($DetectionRule2) | Out-Null
$DetectionRules


# You can also define more detailed requirement rules other the operative system details
New-IntuneWin32AppRequirementRuleFile -Existence -Path "C:\Folder" -FileOrFolder "File.txt" -DetectionType "exists"
New-IntuneWin32AppRequirementRuleRegistry -VersionComparison -KeyPath "HKEY_LOCAL_MACHINE\SOFTWARE\Events" -ValueName "SCUG" -VersionComparisonOperator "equal" -VersionComparisonValue "Awesome" # Ohoh
New-IntuneWin32AppRequirementRuleRegistry -VersionComparison -KeyPath "HKEY_LOCAL_MACHINE\SOFTWARE\Events" -ValueName "SCUG" -VersionComparisonOperator "equal" -VersionComparisonValue "1.0.0"
New-IntuneWin32AppRequirementRuleScript -StringOutputDataType -ScriptFile "C:\IntuneWin32App\Detection\Script.ps1" -ScriptContext "system" -StringComparisonOperator "equal" -StringValue "Outputstring"


# Likewise with detection rules, multiple requirement rules are also supported
# Here you can mix however you like
$RequirementRules = New-Object -TypeName "System.Collections.ArrayList"
$RequirementRule1 = New-IntuneWin32AppRequirementRuleFile -Existence -Path "C:\Folder" -FileOrFolder "File.txt" -DetectionType "exists"
$RequirementRules.Add($RequirementRule1) | Out-Null
$RequirementRule2 = New-IntuneWin32AppRequirementRuleScript -StringOutputDataType -ScriptFile "C:\IntuneWin32App\Detection\Script.ps1" -ScriptContext "system" -StringComparisonOperator "equal" -StringValue "Outputstring"
$RequirementRules.Add($RequirementRule2) | Out-Null
$RequirementRules