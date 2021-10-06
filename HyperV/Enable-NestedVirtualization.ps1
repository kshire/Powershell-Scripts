$HostServer = 'hostname'
$vHost = 'vhost'

Set-VMProcessor -VMName $vHost -ComputerName $HostServer -ExposeVirtualizationExtensions $true

Get-VMNetworkAdapter -VMName $vHost -ComputerName $HostServer | Set-VMNetworkAdapter -MacAddressSpoofing On