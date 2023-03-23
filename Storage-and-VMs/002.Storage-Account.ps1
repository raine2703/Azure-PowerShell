#Creating Azure Storage Account

$ResourceGroupName="RG3"
$Location="North Europe"
$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location 

$AccountName="rnstorage270355x"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$Location="North Europe"

$StorageAccount=New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

Get-AzStorageAccount

$RemoveStorageAccount=Remove-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName -Force