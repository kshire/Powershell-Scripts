<#
Creating a new group in Azure via the Powershell Microsoft.Graph module


https://docs.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0
#>

# Import Modules
Import-Module MSAL.PS
Import-Module Microsoft.Graph


# Interactive Authentication
# Requires URL set to http://localhost
# ClientId is the Application ID for the "Microsoft Graph PowerShell" application
# TenantId is found in the "Default Directory Overview" in the AzureAD portal

$authParams = @{
  ClientId    = '14d82eec-204b-4c2f-b7e8-296a70dab67e'
  TenantId    = '867ef29c-c093-412a-98a6-ceefbae06c28'
  Interactive = $true
}
$auth = Get-MsalToken @authParams

# Display the authentication object
$auth

# Interactive via Device Code
# ClientId is the Application ID for the "Microsoft Graph PowerShell" application
# TenantId is found in the "Default Directory Overview" in the AzureAD portal

$authParams = @{
  ClientId    = '14d82eec-204b-4c2f-b7e8-296a70dab67e'
  TenantId    = '867ef29c-c093-412a-98a6-ceefbae06c28'
  DeviceCode  = $true
}
$auth = Get-MsalToken @authParams

# Display the authentication object
$auth


# Script Authentication
$authparams = @{
  ClientId     = ''
  TenantId     = '867ef29c-c093-412a-98a6-ceefbae06c28'
  ClientSecret = ('MySuperSecretClientSecret' | ConvertTo-SecureString -AsPlainText -Force)
}

$auth = Get-MsalToken @authParams

# Display the authentication object
$auth



<#
Connect to Graph, specify scopes, will be prompted for authentication in browser
Look at some stuff
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

