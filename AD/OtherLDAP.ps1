<#
You can try this...I use it to connect to an OpenLDAP instance and it works well. Works against AD also so it should fit your needs. You'll need to update the $basedn variable and the host/username ones.
https://stackoverflow.com/a/26301835
http://mikemstech.blogspot.com/2013/03/searching-non-microsoft-ldap.html
#>

$hostname = ''
$username = ''

$Null = [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols")
#Connects to LDAP
$LDAPConnect = New-Object System.DirectoryServices.Protocols.LdapConnection "$HostName"

#Set session options (SSL + LDAP V3)
$LDAPConnect.SessionOptions.SecureSocketLayer = $true
$LDAPConnect.SessionOptions.ProtocolVersion = 3

# Pick Authentication type:
# Anonymous, Basic, Digest, DPA (Distributed Password Authentication),
# External, Kerberos, Msn, Negotiate, Ntlm, Sicily
$LDAPConnect.AuthType = [System.DirectoryServices.Protocols.AuthType]::Basic

# Gets username and password.
$credentials = new-object "System.Net.NetworkCredential" -ArgumentList $UserName,(Read-Host "Password" -AsSecureString)
# Bind with the network credentials. Depending on the type of server,
# the username will take different forms.
Try {
$ErrorActionPreference = 'Stop'
$LDAPConnect.Bind($credentials)
$ErrorActionPreference = 'Continue'
}
Catch {
Throw "Error binding to ldap  - $($_.Exception.Message)"
}

Write-Verbose "Successfully bound to LDAP!" -Verbose
$basedn = "OU=Users and Groups,DC=TEST,DC=NET"
$scope = [System.DirectoryServices.Protocols.SearchScope]::Subtree
#Null returns all available attributes
$attrlist = $null
$filter = "(objectClass=*)"

$ModelQuery = New-Object System.DirectoryServices.Protocols.SearchRequest -ArgumentList $basedn,$filter,$scope,$attrlist

#$ModelRequest is a System.DirectoryServices.Protocols.SearchResponse
Try {
$ErrorActionPreference = 'Stop'
$ModelRequest = $LDAPConnect.SendRequest($ModelQuery) 
$ErrorActionPreference = 'Continue'
}
Catch {
Throw "Problem looking up model account - $($_.Exception.Message)"
}

$ModelRequest
