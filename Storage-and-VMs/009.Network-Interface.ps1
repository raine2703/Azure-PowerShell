#Creating Network Interface. Attaching it to Subnet. Deleteing it.

$ResourceGroupName ="RG3"
$VirtualNetworkName="Vnet"
$SubnetName="SubnetA"
$Location = "North Europe"
$NetworkInterfaceName="Nic1"

#Getting Details of Vnet and Subnet
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

#Creating NIC
$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet

#Details of NIC
$NetworkInterface
#Available NICs in RG
(Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName).name

#Removing NIC
Remove-AzNetworkInterface -name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName -Force
