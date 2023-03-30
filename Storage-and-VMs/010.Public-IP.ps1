#Creating Public IP Address and assigning it to NIC


$PublicIPAddressName="public-ip"
$ResourceGroupName="powershell-grp"
$Location="North Europe"
$NetworkInterfaceName="Nic1" #Assuming its created

#Creating Public IP
$PublicIPAddress=New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName `
-Location $Location -Sku "Standard" -AllocationMethod "Static"

#Verifying its created
(get-azpublicipaddress -ResourceGroupName $ResourceGroupName).name


#NIC Details
$NetworkInterface=Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

#NIC IP Config Details
$IpConfig=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface

#Assigning PublicIP to NIC
$NetworkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddress `
-Name $IpConfig.Name

#Applying changes
$NetworkInterface | Set-AzNetworkInterface
#Verifying
(Get-AzNetworkInterface -name $NetworkInterfaceName).ipconfigurations.PublicIpAddress.id

