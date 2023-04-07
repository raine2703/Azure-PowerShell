#Checking if resources alredy exist before creating them

#Creating Resource Group
$ResourceGroupName="RG3"
$Location="North Europe"

$RG=$null
if(Get-AzResourceGroup -name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue){
    'Resource group ' + $ResourceGroupName + ' aleardy exists!'
} else {
    'Creating resource group ' + $ResourceGroupName + ' with help of PowerShell!'
    $RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

$RemoveRG=Remove-AzResourceGroup -name $ResourceGroupName -Force

Get-AzResourceGroup | format-table


#Creating Storage Account
$AccountName = "rnstorage270355x"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$Location = "North Europe"

$StorageAccount = $null
if(Get-AzStorageAccount -name $AccountName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue) {
    'Storage Account ' + $AccountName + ' already exists!'
} else {
    'Creating Storage account ' + $AccountName + ' with PowerShell!'
    $StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU
}

Get-AzStorageAccount