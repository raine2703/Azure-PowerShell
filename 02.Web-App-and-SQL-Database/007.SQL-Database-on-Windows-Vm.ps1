#Creating Resource group, Vnet, Subnet, NIC, Public IP, NSG, Availability set and VM
#Credentials used from KeyVault. Powershell identity is granted Get access policy to Secrets

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
$VMSize="Standard_DS2_v2"
$KeyVaultName="rkv2703x"

$Location ="North Europe"
$UserName="usera"

<#
Vault Already created! But Could use this:

New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName `
-Location $Location -SoftDeleteRetentionInDays 7

# Access to Powershell application:

$ObjectID=""
Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -ObjectId $ObjectID `
-PermissionsToSecrets Get
#>

$Password=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "vmpassword2" -AsPlainText
$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force


$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $PasswordSecure);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetId $AvailabilitySet.Id
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterface.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
$VirtualMachine = Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine