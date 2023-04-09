#Creating Storage account for storing the IIS Config file
$AccountName = "rnstoragerandom270356"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$ResourceGroupName="RG88"
$Location = "North Europe"

New-AzResourceGroup -name $ResourceGroupName -Location $Location

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