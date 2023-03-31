#Adding data disk to VM

$VmName ="appvm"
$ResourceGroupName ="powershell-grp"
$DiskName="app-disk"

#Get VM
$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

#Add data disk
$Vm | Add-AzVMDataDisk -Name $DiskName -DiskSizeInGB 16 -CreateOption Empty -Lun 0

# Update Vm
$Vm | Update-AzVM