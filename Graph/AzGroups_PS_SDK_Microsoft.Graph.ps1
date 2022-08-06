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
Get-MgGroup -Filter "DisplayName eq 'test1'"

# Make a new group
$params = @{
  DisplayName = 'Test Group'
  MailEnabled = $False
  MailNickName = 'testgroup'
  SecurityEnabled = $true
}
New-MgGroup @params

