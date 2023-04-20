$ResourceGroupName = "RG6"
$Location = "North Europe"
$VirtualNetworkName ="VNet1"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"
$NetworkInterfaceName="Nic1"
$NSGName="NSG"

#Creating NIC
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

$NetworkInterface=New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet

#New NSG with rules defined before
$rule1=New-AzNetworkSecurityRuleConfig `
    -Name "rdp-rule" `
    -Description "Allow RDP" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 3389

$nsg=New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name `
$NSGName -SecurityRules $rule1


#Assigning NSG to Subnet
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$nsg=Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $nsg `
    -AddressPrefix $SubnetAddressSpace #or accessing array value $VirtualNetwork.Subnets[0].AddressPrefix

#Updating Subnet
$VirtualNetwork | Set-AzVirtualNetwork



#Then Create VM. then second vm. Apply scripts on both. Same subnet. Then AppGW
