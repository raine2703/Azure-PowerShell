#Resizing VM

$VmName="appvm"
$ResourceGroupName="powershell-grp"
$DesiredVMSize="Standard_B2s"

#Get Details of VM
$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

#Verifying
if($Vm.HardwareProfile.VmSize -ne $DesiredVMSize)
{
    $Vm.HardwareProfile.VmSize=$DesiredVMSize
    $Vm | Update-AzVM
    'The size of the VM has been modified'
}
else {
    'The VM is already of the desired size'
}