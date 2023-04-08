#Creating VNet


$ResourceGroupName ="Load-Balancer-RG"
$Location="North Europe"

$VirtualNetworkName="Vnet1"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

#Resource Group
New-AzResourceGroup -name $ResourceGroupName -Location $Location

#Subnet
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

#Vnet
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet