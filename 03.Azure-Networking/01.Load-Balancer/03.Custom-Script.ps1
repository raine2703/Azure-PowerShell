#Custom Script to install IIS on all backend VMs

#Creating Storage account for storing the IIS Config file
$AccountName = "rnstoragerandom270356"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$ResourceGroupName="Load-Balancer-RG"
$Location = "North Europe"

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



#Aplying Script to VMs
$VMs=@()
$VMs=Get-AzVM -ResourceGroupName $ResourceGroupName `
| Where-Object {$_.Name -Like "VM*"}

#For logic to apply Script on all VMs
$NumberofMachines=$VMs.Count


#Accessing Custom Script on Azure Storage
$StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
-Name $AccountName
$BlobName="IIS_Config.ps1"
$Blob=Get-AzStorageBlob -Context $StorageAccount.Context `
-Container $ContainerName -Blob $BlobName
$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}
$settings=@{"fileUris"=$blobUri}
$StorageAccountKeyValue=$StorageAccountKey.Value
$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"};


#Applying Custom Script on all VMs
for($i=1;$i -le $NumberofMachines;$i++)
{
Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VMs[$i-1].Name -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings
}