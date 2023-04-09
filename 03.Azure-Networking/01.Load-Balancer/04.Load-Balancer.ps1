#Creating Standard Load Balanced in from of Backend VMs
#Use $PublicIP to access one of VMs in Backend Pool
#Note that VMs do not have public IP

$ResourceGroupName="Load-Balancer-RG"
$Location = "North Europe"

$PublicIPDetails=@{
    Name='load-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

#Public IP
$PublicIP=New-AzPublicIpAddress @PublicIPDetails

$FrontEndIP=New-AzLoadBalancerFrontendIpConfig -Name "load-frontendip" `
-PublicIpAddress $PublicIP

#Load Balancer
$LoadBalancerName="app-balancer"

New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName `
-Location $Location -Sku "Standard" -FrontendIpConfiguration $FrontEndIP


#Adding Backend Pool
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool"

$LoadBalancer | Set-AzLoadBalancer #Updating settings! Important not to miss.


#Addings NICs from VMs to Backend Pool.
$NetworkInterfaces=@()

$NetworkInterfaces=Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName `
| Where-Object {$_.Name -Like "Nic*"}

$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$BackendAddressPool=Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
-LoadBalancer $LoadBalancer

#Updating NICs configuration. Setting that they are part of Backend pool in Load balancer.
foreach($NetworkInterface in $NetworkInterfaces)
{
    $NetworkInterface.IpConfigurations[0].LoadBalancerBackendAddressPools=$BackendAddressPool
    $NetworkInterface | Set-AzNetworkInterface    
}


#Health probe for monitoring
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerProbeConfig -Name "ProbeA" -Protocol "tcp" -Port "80" `
-IntervalInSeconds "10" -ProbeCount "2"

$LoadBalancer | Set-AzLoadBalancer


# Adding the Load Balancing Rule
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$BackendAddressPool=Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
-LoadBalancer $LoadBalancer

$Probe=Get-AzLoadBalancerProbeConfig -Name "ProbeA" -LoadBalancer $LoadBalancer

#Matching Front end IP to Backend pool. 
$LoadBalancer | Add-AzLoadBalancerRuleConfig -Name "RuleA" -FrontendIpConfiguration $LoadBalancer.FrontendIpConfigurations[0] `
-Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -BackendAddressPool $BackendAddressPool `
-Probe $Probe

$LoadBalancer | Set-AzLoadBalancer