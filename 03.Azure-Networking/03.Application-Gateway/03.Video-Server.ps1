
$NetworkInterfaceName="Nic2"


#Creating NIC
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

$NetworkInterface=New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet


$VmName="VideoVM"
$VMSize="Standard_DS2_v2"
$KeyVaultName="rkv2703x"

$Location ="North Europe"
$UserName="usera"

$Password=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name "vmpassword2" -AsPlainText
$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $PasswordSecure);

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize 
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName -Credential $Credential
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterface.Id
$VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
$VirtualMachine = Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine



$AccountName = "rnstoragerandom270356x"
$CuctomScriptStorage="CustomScripts"




#Applying Custom Script extension to VM
$blobUri=@($Blob2.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $CuctomScriptStorage `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$settings=@{"fileUris"=$blobUri}

$StorageAccountKeyValue=$StorageAccountKey.Value

$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config_Video.ps1"};

Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings