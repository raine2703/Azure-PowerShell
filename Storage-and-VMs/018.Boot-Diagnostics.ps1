#How to add Boot diagnostics to VM

#Create Storage account
$AccountName = "vmdiagnostics4000"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$ResourceGroupName="powershell-grp"
$Location = "North Europe"

New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

# Then lets get our VM details
$VmName="appvm"
$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

# Then we set the diagnostics details
Set-AzVMBootDiagnostic -VM $Vm -ResourceGroupName $ResourceGroupName `
-StorageAccountName $AccountName -Enable

# Then we need to update the virtual machine
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $Vm