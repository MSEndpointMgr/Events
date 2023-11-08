Import-Module -Name "JWTDetails"

# Delegated access (authorization code flow)
# Property with permissions: scp
$Parameters = @{
    TenantId = "<enter_tenantid>"
    ClientId = "<enter_clientid>"
    RedirectUri = "http://localhost"
}
$DelegatedAccessToken = Get-MsalToken @Parameters
Clear-Host
$DelegatedAccessToken.AccessToken | Get-JWTDetails | Select-Object -ExpandProperty "scp" | ForEach-Object { $PSItem.Split(" ") }


# Application access (client credentials flow)
# Property with permissions: roles
$Parameters = @{
    TenantId = "<enter_tenantid>"
    ClientId = "<enter_clientid>"
    ClientSecret = ("<client_secret>" | ConvertTo-SecureString -AsPlainText -Force)
    RedirectUri = "http://localhost"
}
$CredentialsAccessToken = Get-MsalToken @Parameters
Clear-Host
$CredentialsAccessToken.AccessToken | Get-JWTDetails | Select-Object -ExpandProperty "roles" | ForEach-Object { $PSItem.Split(" ") }