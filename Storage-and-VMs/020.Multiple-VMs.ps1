#Creating Mutiple NICs, Public IPs and VMs

$ResourceGroupName="powershell-grp"
$Location="North Europe"

$VirtualNetworkName="Vnet"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"
$NetworkInterfaceName="Nic1"
$PublicIPAddressName="public-ip"
$NSGName="NSG"



#Creating RG
$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location



#Creating Vnet with Subnet

#Default Subnet config
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

$VirtualNetwork=New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet



#Creating NIC
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork
$NetworkInterfaces=@()
for($i=1;$i -le 2;$i++)
{
    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet    
}



#Creating Public IP
$PublicIPAddresses=@()
$IpConfigs=@()

for($i=1;$i -le 2;$i++)
{
    $PublicIPAddresses+=New-AzPublicIpAddress -Name $PublicIPAddressName$i -ResourceGroupName $ResourceGroupName `
    -Location $Location -Sku "Standard" -AllocationMethod "Static"

    #NIC IP Config Details
    $IpConfigs+=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces[$i-1]

    #Assigning PublicIP to NIC
    $NetworkInterfaces[$i-1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses[$i-1] `
    -Name $IpConfigs[$i-1].Name

    #Applying changes
    $NetworkInterfaces[$i-1] | Set-AzNetworkInterface
}


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



#Creating Availability Set to add VMs in different fault and update domains.
$AvailabilitySetName="availabiliy-set"
$AvailabilitySet=New-AzAvailabilitySet -Location $Location -Name $AvailabilitySetName `
-ResourceGroupName $ResourceGroupName -Sku aligned `
-PlatformFaultDomainCount 2 -PlatformUpdateDomainCount 2



#Creating Virtual Machine

$VmName="appvm"
$VMSize = "Standard_DS2_v2"

$Location ="North Europe"
$UserName="usera"
$Password=ConvertTo-SecureString "nsdfn9283yrxnzznklxc@" -AsPlainText -Force

$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $Password);

$VMs=@()
for($i=1;$i -le 2;$i++)
{
    $VirtualMachine=New-AzVMConfig -VMName $VMName$i -VMSize $VMSize -AvailabilitySetId $AvailabilitySet.Id
    $VirtualMachine=Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName$i -Credential $Credential
    $VirtualMachine=Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterfaces[$i-1].Id
    $VirtualMachine=Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
    $VirtualMachine=Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

    #Saving VM names in to array for later use
    $VMs+="$VMName$i"

    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

}

'Created VMs:' + $VMs