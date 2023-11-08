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


# Constrict array list to contain all retrieved objects from Graph API
$ResponseList = New-Object -TypeName "System.Collections.Generic.List[object]"

# Construct request with support for handling pagination responses with @odata.nextLink URI's
$Parameters = @{
    Method = "Get"
    Uri = "https://graph.microsoft.com/beta/deviceManagement/auditEvents"
    Headers = $AuthenticationHeader
    ContentType = "application/json"
}
Clear-Host
do {
    $Response = Invoke-RestMethod @Parameters
    Write-Output -InputObject "Count of objects in response: $($Response.'@odata.count')"
    if ($null -ne $Response.'@odata.nextLink') {
        Write-Output -InputObject "Response contains '@odata.nextLink'"
        $ResponseList.AddRange($Response.value)
        $Parameters["Uri"] = $Response.'@odata.nextLink'
    }
    else {
        $ResponseList.AddRange($Response.value)
    }
}
until ($null -eq $Response.'@odata.nextLink')
$ResponseList.Count