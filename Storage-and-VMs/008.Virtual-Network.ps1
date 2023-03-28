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
(Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName).Name


#Adding another subnet:
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name "SubnetC" -AddressPrefix "10.0.2.0/24" -VirtualNetwork $virtualNetwork

#Applying Configuration
$virtualNetwork | Set-AzVirtualNetwork
#Checking Result
(Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName).Subnets.name
(Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName).Subnets[0].AddressPrefix

#Subet + ip address foreach loop in a vnet
$x=Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName
foreach ($a in $x.Subnets) {
   $a.name + ' address prefix is ' + $a.AddressPrefix
}
#Another option to get subnet cofnig
$x | Get-AzVirtualNetworkSubnetConfig


#Removing subnet (conected resources should be removed first)
Remove-AzVirtualNetworkSubnetConfig -Name "SubnetC" ` -VirtualNetwork $virtualNetwork
$virtualNetwork | Set-AzVirtualNetwork
$virtualNetwork.subnets.name

#Delete Vnet
Remove-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName -Force
$virtualNetwork.name

