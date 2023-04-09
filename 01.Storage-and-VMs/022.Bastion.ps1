#Idea how to create Azure Bastion
#Can be added to Windows-VM.ps1 file

#First is Bastion Subnet
$BastionSubnetName="AzureBastionSubnet"
$BastionSubnetAddressSpace="10.0.1.0/24"
$BastionSubnet=New-AzVirtualNetworkSubnetConfig -Name $BastionSubnetName `
-AddressPrefix $BastionSubnetAddressSpace


#Then Vnet with BastionSubnet
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace `
-Subnet $Subnet,$BastionSubnet


#New Public IP Address 
$PublicIPAddressName="bastion-ip"
$PublicIPAddress=New-AzPublicIpAddress -Name $PublicIPAddressName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Sku "Standard" -AllocationMethod "Static"
 

#Finally Azure Bastion Host
$BastionName="app-bastion"
New-AzBastion -ResourceGroupName $ResourceGroupName -Name $BastionName `
-PublicIpAddress $PublicIPAddress -VirtualNetworkId $VirtualNetwork.Id