#Creating Resource group, Storage account, Container and uploading Blob
#Defining Storage Context as variable

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


#Creating Container
$ContainerName="data2"
$Key = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -StorageAccountName $AccountName).Value[0]
$ctx = New-AzStorageContext -StorageAccountName $AccountName -StorageAccountKey $Key
New-AzStorageContainer -name $containername -Permission off -Context $ctx

Get-AzStorageContainer -Context $ctx |format-table

Remove-AzStorageContainer -name $containername -context $ctx


#Uploading File to container
$ContainerName="data2"
$BlobObject=@{
    FileLocation="sample.txt"
    ObjectName ="sample.txt"
}

Set-AzStorageBlobContent -Context $ctx -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

Get-AzStorageBlob -Context $ctx -container $ContainerName

#Remove Blob
Remove-AzStorageBlob -Container $ContainerName -Blob $BlobObject.ObjectName -context $ctx


#Create 3 containers
$Containers = 'cont1','cont2','cont3'

foreach ($x in $Containers) {
    New-AzStorageContainer -name $x -Permission off -Context $ctx
}


#Delete all containers
$ContainerList = Get-AzStorageContainer -context $ctx
$ContainerList

foreach ($x in $ContainerList) {
    Remove-AzStorageContainer -name $x.name -context $ctx
}