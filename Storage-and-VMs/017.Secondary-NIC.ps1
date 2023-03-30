#How to add Secondary NIC to VM

$VmName="appvm"
$ResourceGroupName="powershell-grp"

#VM Must be stopped!
Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

$NetworkInterfaceName="NIC2"

$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $Subnet

#Geting VM
$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

#To add secondary NIC primary must be defined
$Vm.NetworkProfile.NetworkInterfaces[0].Primary=$true

#Adding secondary NIC
Add-AzVMNetworkInterface -VM $Vm -Id $NetworkInterface.Id

#Then updating
Update-AzVM -ResourceGroupName $ResourceGroupName -VM $Vm

#Finally starting VM
Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

