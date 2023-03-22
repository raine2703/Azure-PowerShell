#Creating Resource group, Storage account, Container and uploading Blob

#Creating Resource Group
$ResourceGroupName ="RG3"
$Location = "North Europe"
$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location 


#Creating Storage Account
$AccountName = "rnstorage270355x"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$Location = "North Europe"

$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

Get-AzStorageAccount

#Creating Container
$ContainerName="data"

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context -Permission Blob
Get-AzStorageContainer -Context $StorageAccount.Context

#Uploading Blob

$BlobObject=@{
    FileLocation="sample.txt"
    ObjectName ="sample.txt"
}

Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

Get-AzStorageBlob -Context $StorageAccount.Context -container $ContainerName

#Delete Blob
Remove-AzStorageBlob -Container $containername -Blob $BlobObject.ObjectName -context $StorageAccount.Context







