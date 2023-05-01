#Creating Azure Firewall

$VirtualNetworkName="Vnet1"
$ResourceGroupName="RG7"
$BastionSubnetName="AzureFirewallSubnet"
$BastionSubnetAddressSpace="10.0.1.0/24"
$FirewallName="app-firewall"
$Location="North Europe"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $BastionSubnetName `
-VirtualNetwork $virtualNetwork -AddressPrefix $BastionSubnetAddressSpace

$virtualNetwork | Set-AzVirtualNetwork


#Firewall Public IP address
$PublicIPDetails=@{
    Name='firewall-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

$FirewallPublicIP=New-AzPublicIpAddress @PublicIPDetails


#Updating value
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName


#Creating Firewall policy to manage rules
$FirewallPolicyName="firewall-policy"
$FirewallPolicy=New-AzFirewallPolicy -Name $FirewallPolicyName -ResourceGroupName $ResourceGroupName `
-Location $Location

$FirewallPublicIP=Get-AzPublicIpAddress -Name $PublicIPDetails.Name


#Creating Azure Firewall
$AzureFirewall = New-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName `
-Location $Location -VirtualNetwork $VirtualNetwork -PublicIpAddress $FirewallPublicIP `
-FirewallPolicyId $FirewallPolicy.Id