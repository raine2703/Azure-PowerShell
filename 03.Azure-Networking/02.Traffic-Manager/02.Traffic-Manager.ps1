#Creating Traffic Manager with Priority routing
#Provides Load balancing between Regions

$TrafficManagerProfileName="traffic-mgrrn2745"
$ResourceGroupName ="RG11"

$TrafficManagerProfile = New-AzTrafficManagerProfile -Name $TrafficManagerProfileName `
-ResourceGroupName $ResourceGroupName -TrafficRoutingMethod Priority -Ttl 30 `
-MonitorProtocol HTTP -MonitorPort 80 -MonitorPath "/" -RelativeDnsName "rntrafficmanager"

#Adding Endpoints to the Traffic Manager Profile
$PublicIPAddresses=@()

$PublicIPAddresses=Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName `
| Where-Object {$_.Name -Like "app*"}

$i=1 #Again different logic. $i defined before foreach
foreach($PublicIPAddress in $PublicIPAddresses)
{
    Add-AzTrafficManagerEndpointConfig -EndpointName "Endpoint$i" `
    -TrafficManagerProfile $TrafficManagerProfile -Type ExternalEndpoints `
    -Target $PublicIPAddress.IpAddress -EndpointStatus Enabled `
    -Priority $i

    Set-AzTrafficManagerProfile -TrafficManagerProfile $TrafficManagerProfile

    $i++
}