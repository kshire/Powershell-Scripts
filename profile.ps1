<# Current User, All Powershell Hosts
  PowerShell  V7
  Created On:      03/06/2020
  Author:          Kevin Shire
  File:            profile.ps1
  Location:        \Documents\PowerShell\profile.ps1
  Usage:           Autoloaded by Powershell
  Version:         1.0
  Purpose:         Profile for current user in all hosts
  Requirements:    <NONE>
  Last Updated:    03/07/2020
  History:
  Notes:
#>

# Modules
Import-Module -Global BetterCredentials
Import-Module -Global Hyper-V
Import-Module -Global AdminTools
# Import-Module -Global MSOnline

#variables
# $Env:ADPS_LoadDefaultDrive = 0 # Don't mount the default AD: drive when loading ActiveDirectory moldule
New-Variable -name 'temp' -value $([io.path]::gettemppath()) -Description 'temp files location' # MrEd_Variable Scripting Guy

# Helper functions
function h50 { Get-History -Count 50 }
function h10 { Get-History -Count 10 }

# https://www.undocumented-features.com/2016/09/20/powershell-random-password-generator/
function New-ComplexPassword { ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | Sort-Object {Get-Random})[0..14] -join '' }
function Start-RDPRemoteAdmin {
    # Dell tower for access to PAM without being full screen
    Connect-RemoteDesktop -ComputerName "WORKSTATION" -Credential (get-credential "DOMAIN\USER") -Resolution 1680x1050
}
Set-Alias -Name ra -Value Start-RDPRemoteAdmin

# explorer command
function Start-Explorer {
  param (
    [Parameter(
      Position = 0,
      ValueFromPipeline = $true,
      Mandatory = $true,
      HelpMessage = "This is the path to explore..."
    )]
    [ValidateNotNullOrEmpty()]
    [Alias("Folder", "Path", "FilePath")]
    [string]
    #First param is the path you're going to explore.
    $Target
  )
  $exploration = New-Object -ComObject shell.application
  $exploration.Explore($Target)
}
Set-Alias -Name exp -Value Start-Explorer

# Now variable
# http://blogs.microsoft.co.il/scriptfanatic/2011/04/12/tied-variables-in-powershell/
Add-Type -TypeDefinition @"
using System;
using System.Management.Automation;
public class NowVariable : PSVariable
{
public NowVariable ()
    : base("Now", 0, ScopedItemOptions.ReadOnly | ScopedItemOptions.AllScope)
    {}
        public override object Value
        {
            get
            {
                return DateTime.Now;
            }
        }
}
"@
# $ExecutionContext.SessionState.PSVariable.Set((New-Object -TypeName NowVariable))

# Load credentials for easy use from Windows Credential Manager
# $pscred = BetterCredentials\Get-Credential -UserName "ps"


# Aliases
Set-Alias -Name ue -Value "C:\Program Files (x86)\IDM Computer Solutions\UltraEdit\Uedit32.exe"
Set-Alias -Name np -Value "$env:windir\system32\notepad.exe"
Set-Alias -Name posh -Value "$env:SystemRoot\system32\WindowsPowerShell\v1.0\powershell.exe"
Set-Alias -Name pwsh -Value "'C:\Program Files\PowerShell\7\pwsh.exe' -WorkingDirectory ~"
Set-Alias -Name expresso -Value "C:\Program Files (x86)\Ultrapico\Expresso\expresso.exe"
Set-Alias -Name als -Value "C:\Program Files (x86)\Windows Resource Kits\Tools\lockoutstatus.exe"
Set-Alias -Name code -Value "C:\Program Files\Microsoft VS Code\Code.exe"
Set-Alias -Name ilocon -Value 'C:\Program Files (x86)\Hewlett Packard Enterprise\HPE iLO Integrated Remote Console\HPLOCONS.exe'
Set-Alias -Name kp -Value "C:\Program Files\KeePass\KeePass.exe"
Set-Alias -Name kpx -Value "C:\Program Files\KeePassXC\KeePassXC.exe"
# AD commands
Set-Alias -Name gadu -Value "Get-ADUser"
Set-Alias -Name sadu -Value "Set-ADUser"
Set-Alias -Name gaadu -Value "Get-AzureADUser"
Set-Alias -Name saadu -Value "Set-AzureADUser"
Set-Alias -Name gadg -Value "Get-ADGroup"
Set-Alias -Name sadg -Value "Set-ADGroup"
Set-Alias -Name gaadg -Value "Get-AzureADGroup"
Set-Alias -Name saadg -Value "Set-AzureADGroup"

## Default Parameter values
# Find the PDC
# $pdc = (Get-ADDomain).PDCEmulator.Split('.')[0]
$pdc = 'DC1'
# AD Values
$PSDefaultParameterValues['Format-[wt]*:Autosize'] = $true
$PSDefaultParameterValues.Add("New-ADUser:Server","$pdc")
$PSDefaultParameterValues.Add("New-ADGroup:Server","$pdc")
$PSDefaultParameterValues.Add("Get-ADUser:Server","$pdc")
$PSDefaultParameterValues.Add("Get-ADGroup:Server","$pdc")
$PSDefaultParameterValues.Add("Set-ADUser:Server","$pdc")
$PSDefaultParameterValues.Add("Set-ADGroup:Server","$pdc")
$PSDefaultParameterValues.Add("Remove-ADUser:Server","$pdc")
$PSDefaultParameterValues.Add("Remove-ADGroup:Server","$pdc")
$PSDefaultParameterValues.Add("Move-ADObject:Server","$pdc")
$PSDefaultParameterValues.Add("Rename-ADObject:Server","$pdc")
$PSDefaultParameterValues.Add("Set-ADAccountPassword:Server","$pdc")
$PSDefaultParameterValues.Add('Get-ADServiceAccount:Server', $pdc)
$PSDefaultParameterValues.Add('Get-ADServiceAccount:Filter', '*')

# PSKeePass Values
$PSDefaultParameterValues.Add("New-KeePassEntry:DatabaseProfileName","PS")
$PSDefaultParameterValues.Add("Update-KeePassEntry:DatabaseProfileName","PS")
$PSDefaultParameterValues.Add("Get-KeePassEntry:DatabaseProfileName","PS")
$PSDefaultParameterValues.Add("Remove-KeePassEntry:DatabaseProfileName","PS")
$PSDefaultParameterValues.Add("*-Csv:NoTypeInformation",$true)



# And of course Update-TypeData:
Update-TypeData -TypeName Microsoft.ActiveDirectory.Management.ADEntity -MemberType ScriptProperty -MemberName Container -Value {
  $this.DistinguishedName -replace '^cn=(.*?)(?<!\\),(.*?DC=([^,]+).*)$', '$2'
}

Update-TypeData -TypeName Microsoft.ActiveDirectory.Management.ADEntity -MemberType ScriptProperty -MemberName Domain -Value {
  $this.DistinguishedName -replace '^.*?DC=([^,]+),DC=.*', '$1'
}

function Convert-ArrayPropertyToString {
  # https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/repairing-csv-exports-part-2
  process {
    $original = $_
    Foreach ($prop in $_.PSObject.Properties) {
      if ($Prop.Value -is [Array] -and $prop.MemberType -ne 'AliasProperty') {
        Add-Member -InputObject $original -MemberType NoteProperty -Name $prop.Name -Value ($prop.Value -join ',') -Force  
      }
    }
    $original
  }
} 

#ShellFolders
$sf = [enum]::GetNames( [System.Environment+SpecialFolder] ) |
    Select-Object @{ n="Name"; e={$_}},@{ n="Path"; e={ [environment]::getfolderpath( $_ ) }}


# Set working folder to User profile path
Set-Location $env:USERPROFILE
