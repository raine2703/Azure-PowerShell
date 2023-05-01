#Routing all traffic from VMs Vnet/Subnet true Azure Firewall. By Default all traffic will be denied and accesing intertnet wont work.

$ResourceGroupName="RG7"
$Location="North Europe"


#Creating Route table
$RouteTable=New-AzRouteTable -Name "FirewallRouteTable" -ResourceGroupName $ResourceGroupName `
-Location $Location -DisableBgpRoutePropagation


#Adding route. All traffic from subnet routed true firewall
$FirewallName="app-firewall"
$Firewall=Get-AzFirewall -Name $FirewallName -ResourceGroupName $ResourceGroupName
$FirewallPrivateIPAddress=$Firewall.IpConfigurations[0].PrivateIPAddress

Add-AzRouteConfig -Name "FirewallRoute" -RouteTable $RouteTable `
-AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" `
-NextHopIpAddress $FirewallPrivateIPAddress | Set-AzRouteTable


#Assigning route table to SubnetA
$VirtualNetworkName="Vnet1"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $VirtualNetwork -Name $SubnetName `
-AddressPrefix $SubnetAddressSpace -RouteTable $RouteTable | Set-AzVirtualNetwork