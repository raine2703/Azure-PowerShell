#Creating Resource group, Vnet, Subnet, NIC, Public IP, NSG and VM

$ResourceGroupName="powershell-grp2"
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
$NetworkInterface=New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet



#Creating Public IP
$PublicIPAddress=New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $ResourceGroupName `
-Location $Location -Sku "Standard" -AllocationMethod "Static"

#NIC IP Config Details
$IpConfig=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterface

#Assigning PublicIP to NIC
$NetworkInterface | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddress `
-Name $IpConfig.Name

#Applying changes
$NetworkInterface | Set-AzNetworkInterface



#New NSG with rules defined before
$rule1=New-AzNetworkSecurityRuleConfig `
    -Name "ssh" `
    -Description "Allow ssh" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix Internet `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 22

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



#Creating Virtual Machine

$VmName="linuxvm"
$VMSize = "Standard_DS2_v2"

$Location ="North Europe"
$UserName="linuxuser"
$Password=ConvertTo-SecureString " " -AsPlainText -Force

$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $Password);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VmName -Credential $Credential -DisablePasswordAuthentication
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterface.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'Canonical' -Offer 'UbuntuServer' -Skus '18.04-LTS' -Version latest
$VirtualMachine = Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -GenerateSshKey -SshKeyName "Linuxkey"