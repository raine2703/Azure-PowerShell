#Stopping and Starting Azure VM. Using Get-AzVM -Status

$VmName="appvm"
$ResourceGroupName="powershell-grp"

# Get VM status
$Statuses=(Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status).Statuses


#Stop VM
if($Statuses[1].Code -eq "PowerState/running"){
    'Shutting down VM!'
    Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force
}
else {
    'VM already stoped!'
}


#Start VM
if($Statuses[1].Code -eq "PowerState/deallocated"){
    'Starting VM!'
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName 
}
else {
    'VM already running!'
}