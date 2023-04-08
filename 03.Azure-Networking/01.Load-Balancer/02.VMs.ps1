#Creating 1-4 virtual machines. 


param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(1,4)]
    [Int32]
    $NumberofMachines
)

$ResourceGroupName ="Load-Balancer-RG"
$VirtualNetworkName="Vnet1"

$VirtualNetwork=Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName `
-Name $VirtualNetworkName

$SubnetConfig= $VirtualNetwork | Get-AzVirtualNetworkSubnetConfig


#Network Interfaces based on VM count
$NetworkInterfaceName="Nic"
$NetworkInterfaces=@()

for($i=1;$i -le $NumberofMachines;$i++)
{
    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $SubnetConfig[0]    
}

 
#NSGs
$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389

$SecurityRule2=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$NetworkSecurityGroupName="NSG"
$Location ="North Europe"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1,$SecurityRule2


#Adding NSG to Subnet
$SubnetAddressSpace="10.0.0.0/24"
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork


# Creating the Azure Virtual Machines
$VmName="VM"
$VMSize = "Standard_DS2_v2"

$UserName="rn2703x5"
$Password="asjdb87#12sas@"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure


$VMs=@()
for($i=1;$i -le $NumberofMachines;$i++)
{
    $VirtualMachine=New-AzVMConfig -VMName $VMName$i -VMSize $VMSize 
    $VirtualMachine=Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName$i -Credential $Credential
    $VirtualMachine=Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterfaces[$i-1].Id
    $VirtualMachine=Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
    $VirtualMachine=Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

    #Saving VM names in to array for later use
    $VMs+="$VMName$i"

    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine

}