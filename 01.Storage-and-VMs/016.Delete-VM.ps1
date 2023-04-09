#Delete VM and its resources

$VmName="appvm"
$ResourceGroupName="powershell-grp"

$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName



#Delete Data Disks
foreach($DataDisk in $Vm.StorageProfile.DataDisks){
    #Remove Disk from VM
    Remove-AzVmDataDisk -VM $Vm -DataDiskNames $DataDisk.Name
    $Vm | Update-AzVM
    #Get Disk and Remove it!
    Get-AzDisk -ResourceGroupName $ResourceGroupName -Name $DataDisk.Name | Remove-AzDisk -Force 

}



#Delete public IP
$Vm=Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

#Get Interface ID
$NetworkInterface=Get-AzNetworkInterface -ResourceId $Vm.NetworkProfile.NetworkInterfaces.Id
$NetworkInterface

#Get Public IP id
$PublicAddress=Get-AzResource -ResourceId $NetworkInterface.IpConfigurations.publicIPAddress.Id
$PublicAddress

#Disasociate NIC with public IP
$NetworkInterface.IpConfigurations.publicIPAddress.Id=$null

#Update NIC
$NetworkInterface | Set-AzNetworkInterface

#Finally - delete public IP
Remove-AzPublicIpAddress -ResourceGroupName $ResourceGroupName `
-Name $PublicAddress.Name -Force



#Get details of OS Disk
$OSDisk=$Vm.StorageProfile.OsDisk
$OSDisk

#Delete VM
Remove-AzVm -Name $VmName -ResourceGroupName $ResourceGroupName -Force

#Delete NIC
$NetworkInterface | Remove-AzNetworkInterface -Force

#Delete OS Disk
Get-AzDisk -ResourceGroupName $ResourceGroupName -Name $OSDisk.Name | Remove-AzDisk -Force



#Delete NSG without hardcoding name of NSG
$ResourceGroupName="powershell-grp"
$VirtualNetworkName="Vnet"

$VirtualNetwork=Get-AzVirtualNetwork -ResourceGroup $ResourceGroupName -Name $VirtualNetworkName

$NetworkSecurityGroup=$VirtualNetwork.Subnets[0].NetworkSecurityGroup
$NetworkSecurityGroup

$NetworkSecurityGroupId=$NetworkSecurityGroup.Id
$NetworkSecurityGroupId

#Getting name of NSG from
$Length=$NetworkSecurityGroupId.Length
$Position=$NetworkSecurityGroupId.LastIndexOf('/') #name starts from +1, using that later

#Substring returns Strings between given range. In this case from 131+1 next 3 letters.
#ID is "/subscriptions/d030343c-fdd7-47cb-a6b7-b7027471025d/resourceGroups/powershell-grp/providers/Microsoft.Network/networkSecurityGroups/NSG"
$NetworkSecurityGroupName=$NetworkSecurityGroupId.Substring($Position+1,$Length-$Position-1) #-1 to ignore / and get count of 3!
$NetworkSecurityGroupName

#Disasociate NSG
$VirtualNetwork.Subnets[0].NetworkSecurityGroup=$null

#Update Vnet
$VirtualNetwork | Set-AzVirtualNetwork

#Remove NSG
Remove-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NetworkSecurityGroupName -Force