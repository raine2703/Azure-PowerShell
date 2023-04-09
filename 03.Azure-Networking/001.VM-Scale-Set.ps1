#Creating VMSS behind Azure Load balancer. IIS Installed to verify Load balancing.
#Manual VM count Scaling

$ResourceGroupName ="RG9"
$Location="North Europe"
$VirtualNetworkName="Vnet"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"


#Defining SubnetConfig
New-AzResourceGroup -name $ResourceGroupName -Location $Location
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

#Creating Virtual Network
$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

#Creating NSG to allow access to ISS on port 80
$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$NetworkSecurityGroupName="NSG"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork



#Creating Azure Load Balancer
$PublicIPDetails=@{
    Name='lb01-publicip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

$PublicIP=New-AzPublicIpAddress @PublicIPDetails

$FrontEndIP=New-AzLoadBalancerFrontendIpConfig -Name "lb01-ipconfig" `
-PublicIpAddress $PublicIP

$LoadBalancerName="lb01"

New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName `
-Location $Location -Sku "Standard" -FrontendIpConfiguration $FrontEndIP


#Backend Pool
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool"

$LoadBalancer | Set-AzLoadBalancer


#Health Probe
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerProbeConfig -Name "ProbeA" -Protocol "tcp" -Port "80" `
-IntervalInSeconds "10" -ProbeCount "2"

$LoadBalancer | Set-AzLoadBalancer


#Load Balancing Rule. Requests to Load Balancer IP will route to Backend poool.
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$BackendAddressPool=Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
-LoadBalancer $LoadBalancer

$Probe=Get-AzLoadBalancerProbeConfig -Name "ProbeA" -LoadBalancer $LoadBalancer

$LoadBalancer | Add-AzLoadBalancerRuleConfig -Name "RuleA" -FrontendIpConfiguration $LoadBalancer.FrontendIpConfigurations[0] `
-Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -BackendAddressPool $BackendAddressPool `
-Probe $Probe

$LoadBalancer | Set-AzLoadBalancer



#Creating Virtual Machine Scale set
$ScaleSetName="VMSS"
$VMSize = "Standard_DS2_v2"

$Location ="North Europe"
$UserName="rn270s22"
$Password="7dek36%l**"


#Getting values
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$BackendAddressPool=Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
-LoadBalancer $LoadBalancer

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName


#Creating VMSS NIC
$VmssIPConfig=New-AzVmssIpConfig -Name "IPConfigScaleSet" `
-SubnetId $VirtualNetwork.Subnets[0].Id -Primary `
-LoadBalancerBackendAddressPoolsId $BackendAddressPool.Id


#Configuring VMSS
$VmssConfig=New-AzVmssConfig -SkuName $VMSize -Location $Location `
-UpgradePolicyMode "Automatic" -SkuCapacity 2

$VmssConfig=Set-AzVmssStorageProfile -VirtualMachineScaleSet $VmssConfig -ImageReferenceOffer "WindowsServer" `
-ImageReferenceSku "2019-Datacenter" -ImageReferencePublisher "MicrosoftWindowsServer" `
-ImageReferenceVersion "latest" -OsDiskCreateOption "FromImage"

$VmssConfig=Set-AzVmssOsProfile -VirtualMachineScaleSet $VmssConfig -ComputerNamePrefix "VMSS" `
-AdminUsername $UserName -AdminPassword $Password

$VmssConfig=Add-AzVmssNetworkInterfaceConfiguration -Name "NetworkConfig" `
-IpConfiguration $VmssIPConfig -VirtualMachineScaleSet $VmssConfig `
-Primary $true

New-AzVmss -ResourceGroupName $ResourceGroupName -VirtualMachineScaleSet $VmssConfig `
-Name $ScaleSetName



#Creating Storage account for storing the IIS Config file
$AccountName = "rnstoragerandom270356"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"

$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

#Creating Container
$ContainerName="data"

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context `
-Permission Blob

$BlobObject=@{
    FileLocation="C:\Users\raitisn\Desktop\Azure-PowerShell\03.Azure-Networking\01.Load-Balancer\IIS_Config.ps1"
    ObjectName ="IIS_Config.ps1"
}

$Blob=Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName



#Aplying Custom Script on VMSS
$config=@{
    "fileUris"=(,"https://rnstoragerandom270356.blob.core.windows.net/data/IIS_Config.ps1");
    "commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"    
}

$VirtualMachineScaleSet=Get-AzVmss -ResourceGroupName $ResourceGroupName `
-VMScaleSetName $ScaleSetName

$VirtualMachineScaleSet=Add-AzVmssExtension -VirtualMachineScaleSet $VirtualMachineScaleSet `
-Name "WebScript" -Publisher "Microsoft.Compute" `
-Type "CustomScriptExtension" -TypeHandlerVersion 1.9 -Setting $config

Update-AzVmss -ResourceGroupName $ResourceGroupName -Name $ScaleSetName `
-VirtualMachineScaleSet $VirtualMachineScaleSet