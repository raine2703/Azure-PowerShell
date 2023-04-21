#Creating first server - ImageVM

$ResourceGroupName = "RG7"
$Location = "North Europe"
$VirtualNetworkName ="VNet1"
$SubnetName="SubnetA"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetAddressSpace="10.0.0.0/24"
$NetworkInterfaceName="Nic1"
$NSGName="NSG"


New-AzResourceGroup -name $ResourceGroupName -Location $Location


#Creating Vnet with Subnet
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace
New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet


#Creating NIC
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

$NetworkInterface=New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet


#New NSG 
$rule1=New-AzNetworkSecurityRuleConfig `
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
$NSGName -SecurityRules $rule1


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


#Creating VM
$VmName="ImageVM"
$VMSize="Standard_DS2_v2"
$KeyVaultName="rkv2703x"
$UserName="usera"

#Credentials used from KeyVault
$Password=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "vmpassword2" -AsPlainText
$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $PasswordSecure);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize 
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterface.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
$VirtualMachine = Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine


#Applying Custom Script extension to VM
$AccountName = "rnstoragerandom270356x"
$CuctomScriptStorage="CustomScripts"

$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $CuctomScriptStorage `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$settings=@{"fileUris"=$blobUri}

$StorageAccountKeyValue=$StorageAccountKey.Value

$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config_Image.ps1"};

Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings