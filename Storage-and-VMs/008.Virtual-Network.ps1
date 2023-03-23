#Creating and deleting Vnet with Subnet

$ResourceGroupName="RG3"
$Location="North Europe"

$VirtualNetworkName="Vnet"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

#Default Subnet config
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

#Creating Vnet
$VirtualNetwork=New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

#Checking result
$VirtualNetwork
$virtualNetwork.name

#Adding another subnet
Add-AzVirtualNetworkSubnetConfig -Name "SubnetC" -AddressPrefix "10.0.2.0/24" -VirtualNetwork $virtualNetwork
#Applying configuration
$virtualNetwork | Set-AzVirtualNetwork

$virtualNetwork.subnets.name

#Removing subnet
Remove-AzVirtualNetworkSubnetConfig -Name "SubnetC" ` -VirtualNetwork $virtualNetwork
$virtualNetwork | Set-AzVirtualNetwork
$virtualNetwork.subnets.name

#Delete Vnet
Remove-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Force
$virtualNetwork.name

