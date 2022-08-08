<#
Groups using Microsoft.Graph Module
#>

<#
Connect to Graph, specify scopes, will be prompted for authentication in browser
Interactive authentication
#>
Connect-MgGraph -Scopes group.readwrite.all,user.read.all,Directory.Read.All
Get-MgContext
$context = Get-MgContext
$user = Get-MgUser -UserId $context.Account -Select 'displayName, id, mail, userPrincipalName'

# Get list of groups
Get-MgGroup

# Get a group by DisplayName
# https://docs.microsoft.com/en-us/powershell/module/microsoft.graph.groups/get-mggroup?view=graph-powershell-1.0#example-2-get-a-group-by-the-display-name
Get-MgGroup -Filter "DisplayName eq 'test group 2'" | fl

# Make a new group
# Put parameters in a hashtable
$params = @{
  DisplayName = 'AZ_ServerSecurity_Barn'
  MailEnabled = $False
  MailNickName = 'AZ_ServerSecurity_Barn'
  SecurityEnabled = $true
}
# splat the parameters to the command
$group = New-MgGroup @params



# Add an Owner
## Useing UPN by ref
New-MgGroupOwnerByRef -GroupId $group.Id -AdditionalProperties @{"@odata.id"="https://graph.microsoft.com/v1.0/users/kshire@shirekevinjohndeere.onmicrosoft.com"}
## Using user Id
New-MgGroupOwnerByRef -GroupId $group.Id -AdditionalProperties @{"@odata.id"="https://graph.microsoft.com/v1.0/users/a0512e69-7815-4685-b916-e9da762a578f"}



# Add a member
New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
# Add a member by reference
New-MgGroupMemberByRef -GroupId $group.Id -AdditionalProperties @{"@odata.id"="https://graph.microsoft.com/v1.0/users/kshire@shirekevinjohndeere.onmicrosoft.com"}



# Remove a group
Remove-MgGroup -GroupId $group.Id



# Get group members
Get-MgGroupMember -GroupId $group.id

(Get-MgGroup -GroupId $group.Id -ExpandProperty members).members | ForEach-Object { $_.additionalproperties }
(Get-MgGroup -GroupId $group.Id -ExpandProperty members).members | Select-Object -ExpandProperty AdditionalProperties
Get-MgGroup -GroupId $group.Id -ExpandProperty members | select -ExpandProperty members | select -ExpandProperty additionalproperties
