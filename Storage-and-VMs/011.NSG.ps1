#NSG

$ResourceGroupName="RG3"
$Location="North Europe"
$NSGName="NSG"


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

$rule2=New-AzNetworkSecurityRuleConfig `
    -Name "web-rule" `
    -Description "Allow HTTP" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 101 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80

$nsg=New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name `
    $NSGName -SecurityRules $rule1,$rule2

#Checking result    
(Get-AzNetworkSecurityGroup).name 
(Get-AzNetworkSecurityGroup).SecurityRules.name

#Remove NSG
Remove-AzNetworkSecurityGroup -name $NSGName -ResourceGroupName $ResourceGroupName -Force


#Add rule to existing NSG
$nsg=Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

# Add the inbound security rule.
$nsg | Add-AzNetworkSecurityRuleConfig `
    -Name "custom-rule" `
    -Description "Allow app port" `
    -Access Allow `
    -Protocol * `
    -Direction Inbound `
    -Priority 3891 `
    -SourceAddressPrefix "*" `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 8081

#Update the NSG.
$nsg | Set-AzNetworkSecurityGroup


#Change config to existing NSG rule. Allow to Deny.
$nsg = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
Set-AzNetworkSecurityRuleConfig `
-NetworkSecurityGroup $nsg `
-Name "custom-rule" `
-Description "Allow app port" `
-Access Deny `
-Protocol * `
-Direction Inbound `
-Priority 3891 `
-SourceAddressPrefix "*" `
-SourcePortRange * `
-DestinationAddressPrefix * `
-DestinationPortRange 8081

#Update NSG
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
#Or
$nsg | Set-AzNetworkSecurityGroup
#Checking result
(Get-AzNetworkSecurityGroup).SecurityRules


#Assign NSG to Subnet in Vnet
$VirtualNetworkName="Vnet"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$nsg=Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName

#Updating Subnet config
Set-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -VirtualNetwork $VirtualNetwork `
    -NetworkSecurityGroup $nsg `
    -AddressPrefix $SubnetAddressSpace

#Updating Subnet
$VirtualNetwork | Set-AzVirtualNetwork


#Assign NSG to NIC
$nsg=Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $ResourceGroupName
$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name "Nic1"

$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzNetworkInterface