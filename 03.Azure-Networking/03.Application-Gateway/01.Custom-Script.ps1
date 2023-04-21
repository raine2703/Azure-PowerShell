#Creating Storage account for storing the IIS Config files for Images and Videos Servers

$AccountName = "rnstoragerandom270356x"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$ResourceGroupName="CustomScripts"
$Location = "North Europe"

New-AzResourceGroup -name $ResourceGroupName -Location $Location

$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

$ContainerName="data"

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context `
-Permission Blob

$BlobObject=@{
    FileLocation="C:\Users\raitisn\Desktop\Azure-PowerShell\03.Azure-Networking\03.Application-Gateway\IIS_Config_Image.ps1"
    ObjectName ="IIS_Config_Image.ps1"
}

$BlobObject2=@{
    FileLocation="C:\Users\raitisn\Desktop\Azure-PowerShell\03.Azure-Networking\03.Application-Gateway\IIS_Config_Video.ps1"
    ObjectName ="IIS_Config_Video.ps1"
}

$Blob=Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

$Blob2=Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject2.FileLocation -Blob $BlobObject2.ObjectName

#Remove-AzResourceGroup -name $ResourceGroupName -force