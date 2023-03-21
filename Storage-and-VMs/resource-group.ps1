# Don't want to save the Login information
 
Disable-AzContextAutosave

# Connecting to our Azure Account

Connect-AzAccount
Connect-AzAccount -TenantId c20a49b8-2914-4624-a197-1e882bd3abf4

#Creating a resource group

$ResourceGroupName ="powershell-grp"
$Location = "North Europe"

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

Get-AzResourceGroup | format-table

Remove-AzResourceGroup -name $ResourceGroupName