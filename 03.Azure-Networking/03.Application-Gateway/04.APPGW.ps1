#Creating Application Gateway Load balancer. Uses Layer 7 load balancing.
#http://gateway-ip/images/default.html will route to images server backen pool
#http://gateway-ip/videos/default.html will route to vidoes server backend pool


#AppGW required new subnet
$AppGatewaySubnet="AppGatewaySubnet"
$AppGwAddressSpace="10.0.1.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $AppGatewaySubnet `
-VirtualNetwork $virtualNetwork -AddressPrefix $AppGwAddressSpace

$virtualNetwork | Set-AzVirtualNetwork


#Creating front end public IP address
$PublicIPDetails=@{
    Name='gateway-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

$PublicIP=New-AzPublicIpAddress @PublicIPDetails


#Associating the gateway to the subnet
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$AppGatewayConfig=New-AzApplicationGatewayIPConfiguration -Name "AppGatewayConfig" `
-Subnet $VirtualNetwork.Subnets[1]

#Associating the gateway to public IP
$PublicIP=Get-AzPublicIpAddress -Name $PublicIPDetails.Name

$AppGatewayFrontEndIPConfig=New-AzApplicationGatewayFrontendIPConfig `
-Name "FrontEndIPConfig" -PublicIPAddress $PublicIP


#Associating the gateway to Frontend Port number
$AppGatewayFrontEndPort=New-AzApplicationGatewayFrontendPort `
-Name "FrontEndIPPort" -Port 80

#Creating Backend Pools and HTTP Setting
$ImageNetworkInterface=Get-AzNetworkInterface -Name "Nic1" -ResourceGroupName $ResourceGroupName
$VideoNetworkInterface=Get-AzNetworkInterface -Name "Nic2" -ResourceGroupName $ResourceGroupName

$VideoBackendAddressPool=New-AzApplicationGatewayBackendAddressPool -Name "VideoPool" `
-BackendIPAddresses $VideoNetworkInterface.IpConfigurations[0].PrivateIpAddress

$ImageBackendAddressPool=New-AzApplicationGatewayBackendAddressPool -Name "ImagePool" `
-BackendIPAddresses $ImageNetworkInterface.IpConfigurations[0].PrivateIpAddress

$HTTPSetting=New-AzApplicationGatewayBackendHttpSetting -Name "HTTPSetting" `
-Port 80 -Protocol Http -RequestTimeout 120 -CookieBasedAffinity Enabled


#Creating Listener
$Listener=New-AzApplicationGatewayHttpListener -Name "ListenerA" `
-Protocol Http -FrontendIPConfiguration $AppGatewayFrontEndIPConfig `
-FrontendPort $AppGatewayFrontEndPort

#Adding path based rules for images and videos
$ImagePathRule=New-AzApplicationGatewayPathRuleConfig -Name "ImageRule" `
-Paths "/images/*" -BackendAddressPool $ImageBackendAddressPool -BackendHttpSettings $HTTPSetting

$VideoPathRule=New-AzApplicationGatewayPathRuleConfig -Name "VideoRule" `
-Paths "/videos/*" -BackendAddressPool $VideoBackendAddressPool -BackendHttpSettings $HTTPSetting

$PathMapConfig=New-AzApplicationGatewayUrlPathMapConfig -Name "URLMap" `
-PathRules $ImagePathRule,$VideoPathRule -DefaultBackendAddressPool $ImageBackendAddressPool `
-DefaultBackendHttpSettings $HTTPSetting

$RoutingRule=New-AzApplicationGatewayRequestRoutingRule -Name "RuleA" `
-RuleType PathBasedRouting -HttpListener $Listener -UrlPathMap $PathMapConfig -Priority 100


#Creating Application Gateway
$GatewaySku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2
$ApplicationGateway=New-AzApplicationGateway -ResourceGroupName $ResourceGroupName `
-Name "app-gateway" -Sku $GatewaySku -Location $Location `
-GatewayIPConfigurations $AppGatewayConfig -FrontendIPConfigurations $AppGatewayFrontEndIPConfig `
-FrontendPorts $AppGatewayFrontEndPort -BackendAddressPools $ImageBackendAddressPool,$VideoBackendAddressPool `
-HttpListeners $Listener -BackendHttpSettingsCollection $HTTPSetting `
-RequestRoutingRules $RoutingRule -UrlPathMaps $PathMapConfig 