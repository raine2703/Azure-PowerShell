#Creating load balances
#http://13.69.197.72/images/default.html will link to images server backen pool
#http://13.69.197.72/videos/default.html will link to vidoes server backend pool



$BastionSubnetName="AppGatewaySubnet"
$BastionSubnetAddressSpace="10.0.1.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $BastionSubnetName `
-VirtualNetwork $virtualNetwork -AddressPrefix $BastionSubnetAddressSpace

$virtualNetwork | Set-AzVirtualNetwork

# We also need a public IP Address that is going to be assigned to the Azure Application Gateway

$PublicIPDetails=@{
    Name='gateway-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

# First we are going to create the Public IP Address that is going to be used by the Load Balancer
$PublicIP=New-AzPublicIpAddress @PublicIPDetails

# Then lets create the different initial configurations for the Application Gateway

# First is associating the gateway to the subnet

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$AppGatewayConfig=New-AzApplicationGatewayIPConfiguration -Name "AppGatewayConfig" `
-Subnet $VirtualNetwork.Subnets[1]

# Then the FrontEnd IP Config

$PublicIP=Get-AzPublicIpAddress -Name $PublicIPDetails.Name

$AppGatewayFrontEndIPConfig=New-AzApplicationGatewayFrontendIPConfig `
-Name "FrontEndIPConfig" -PublicIPAddress $PublicIP

# Then the Frontend Port number

$AppGatewayFrontEndPort=New-AzApplicationGatewayFrontendPort `
-Name "FrontEndIPPort" -Port 80

# Then we will create the BackendAddress Pool and the HTTP Setting


$ImageNetworkInterface=Get-AzNetworkInterface -Name "Nic1" -ResourceGroupName $ResourceGroupName
$VideoNetworkInterface=Get-AzNetworkInterface -Name "Nic2" -ResourceGroupName $ResourceGroupName

$VideoBackendAddressPool=New-AzApplicationGatewayBackendAddressPool -Name "VideoPool" `
-BackendIPAddresses $VideoNetworkInterface.IpConfigurations[0].PrivateIpAddress

$ImageBackendAddressPool=New-AzApplicationGatewayBackendAddressPool -Name "ImagePool" `
-BackendIPAddresses $ImageNetworkInterface.IpConfigurations[0].PrivateIpAddress

$HTTPSetting=New-AzApplicationGatewayBackendHttpSetting -Name "HTTPSetting" `
-Port 80 -Protocol Http -RequestTimeout 120 -CookieBasedAffinity Enabled



# We will then create the Listener
$Listener=New-AzApplicationGatewayHttpListener -Name "ListenerA" `
-Protocol Http -FrontendIPConfiguration $AppGatewayFrontEndIPConfig `
-FrontendPort $AppGatewayFrontEndPort

# We then need to add two path-based rules

$ImagePathRule=New-AzApplicationGatewayPathRuleConfig -Name "ImageRule" `
-Paths "/images/*" -BackendAddressPool $ImageBackendAddressPool -BackendHttpSettings $HTTPSetting

$VideoPathRule=New-AzApplicationGatewayPathRuleConfig -Name "VideoRule" `
-Paths "/videos/*" -BackendAddressPool $VideoBackendAddressPool -BackendHttpSettings $HTTPSetting

$PathMapConfig=New-AzApplicationGatewayUrlPathMapConfig -Name "URLMap" `
-PathRules $ImagePathRule,$VideoPathRule -DefaultBackendAddressPool $ImageBackendAddressPool `
-DefaultBackendHttpSettings $HTTPSetting

$RoutingRule=New-AzApplicationGatewayRequestRoutingRule -Name "RuleA" `
-RuleType PathBasedRouting -HttpListener $Listener -UrlPathMap $PathMapConfig -Priority 100

# Then we create the Azure Application gateway

$GatewaySku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2


$ApplicationGateway=New-AzApplicationGateway -ResourceGroupName $ResourceGroupName `
-Name "app-gateway" -Sku $GatewaySku -Location $Location `
-GatewayIPConfigurations $AppGatewayConfig -FrontendIPConfigurations $AppGatewayFrontEndIPConfig `
-FrontendPorts $AppGatewayFrontEndPort -BackendAddressPools $ImageBackendAddressPool,$VideoBackendAddressPool `
-HttpListeners $Listener -BackendHttpSettingsCollection $HTTPSetting `
-RequestRoutingRules $RoutingRule -UrlPathMaps $PathMapConfig 