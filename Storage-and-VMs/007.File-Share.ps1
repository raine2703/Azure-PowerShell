#Creating File share with Directory. Uploading and downloading files from it. 

#Creating Resource Group
$ResourceGroupName ="RG3"
$Location="North Europe"
$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location 


#Creating Storage Account
$AccountName="rnstorage270355x"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$Location="North Europe"

$StorageAccount=New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU


#Creating file share
$FileSharename="fileshare"
$Dicertory="Folder1"

# Retrieve the context
$Key=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -StorageAccountName $AccountName).Value[0]
$ctx=New-AzStorageContext -StorageAccountName $AccountName -StorageAccountKey $Key

#Contructing object with splating concept
$FileShareConfig=@{
    Name = $FileSharename
    Context = $ctx
}

#Create a file share
New-AzStorageShare @FileShareConfig

#View file shares
Get-AzStorageShare -Context $ctx


#Create a new directory 
$DirectoryDetails=@{
    ShareName = $FileSharename
    Path = $Dicertory
    Context = $ctx
}

#New-AzStorageDirectory -ShareName $FileSharename -Path $Dicertory -Context $ctx ---------->instead:
New-AzStorageDirectory @DirectoryDetails
Get-AzStorageFile -ShareName $FileSharename -context $ctx


#Upload a file to the Azure file Share 
$FileDetails=@{
    ShareName = $FileSharename
    Path = "Folder1/uploaded-sample.txt"
    Context = $ctx
    Source = "sample.txt"
}

#Set-AzStorageFileContent -ShareName $FileSharename -Source "sample.txt" -Path $Dicertory -Context $ctx
Set-AzStorageFileContent @FileDetails


#View files in Directory
Get-AzStorageFile -ShareName $FileSharename -path $Dicertory -Context $ctx | Get-AzStorageFile


#Download a file to the local system 
Get-AzStorageFileContent -ShareName $Sharename -Path "recruitment\uploaded-sample.txt" -Destination "sample2.txt" -Context $ctx


#Delete the file share
Remove-AzStorageShare @FileShareConfig -Force
