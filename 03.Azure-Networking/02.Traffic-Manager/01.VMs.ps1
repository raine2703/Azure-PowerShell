#Creating VMs in two different regions

#Defining Variables
$ResourceGroupName ="RG11"
$Locations="North Europe","West Europe"
$VirtualNetworkName="Vnet1","Vnet2"
$VirtualNetworkAddressSpace="10.0.0.0/16","10.1.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24","10.1.0.0/24"
$NetworkSecurityGroupName="NSG1","NSG2"
$NetworkInterfaceName="NIC"
$VmName="VM"
$VMSize = "Standard_DS2_v2"
$Location ="North Europe"
$UserName="raitisn278x"
$Password="&^%JMsppppA"

$VirtualNetworks=@()
$NetworkInterfaces=@()
$PublicIPAddresses=@()
$IpConfig=@()
$VMs=@()

#Credentials
$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

New-AzResourceGroup -name $ResourceGroupName -Location $Location

$i=1 #Experimenting with different logic. $i defined before foreach loop.
foreach($Location in $Locations)
    {
    
    #Creating Subnet Cofig and Vnet    
    $Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace[$i-1] -WarningAction silentlyContinue
    $VirtualNetworks+=New-AzVirtualNetwork -Name $VirtualNetworkName[$i-1] -ResourceGroupName $ResourceGroupName `
    -Location $Location -AddressPrefix $VirtualNetworkAddressSpace[$i-1] -Subnet $Subnet


    #Getting Subnet Cofig for each loop    
    Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName[$i-1]
    $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetworks[$i-1]


    # Creating the Network Interface
    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet    


    # Creating the Public IP Addresss
    $PublicIPAddressName="app-ip"

    $PublicIPAddresses+=New-AzPublicIpAddress -Name "$PublicIPAddressName$i" -ResourceGroupName $ResourceGroupName `
    -Location $Location -Sku "Standard" -AllocationMethod "Static" -WarningAction silentlyContinue

    $IpConfig+=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces[$i-1]

    $NetworkInterfaces[$i-1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses[$i-1] `
    -Name $IpConfig[$i-1].Name

    $NetworkInterfaces[$i-1] | Set-AzNetworkInterface


    # Creating the Network Security Group
    $SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

    $SecurityRule2=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

    $NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName[$i-1]  `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -SecurityRules $SecurityRule1,$SecurityRule2

    Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetworks[$i-1] `
    -NetworkSecurityGroup $NetworkSecurityGroup `
    -AddressPrefix $SubnetAddressSpace[$i-1] 

    $VirtualNetworks[$i-1] | Set-AzVirtualNetwork



    #Creating VMs
    $NetworkInterfaces[$i-1]= Get-AzNetworkInterface -Name "$NetworkInterfaceName$i" -ResourceGroupName $ResourceGroupName
    $VirtualMachine=New-AzVMConfig -VMName $VMName$i -VMSize $VMSize 
    $VirtualMachine=Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VmName$i -Credential $Credential
    $VirtualMachine=Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NetworkInterfaces[$i-1].Id
    $VirtualMachine=Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2019-Datacenter' -Version latest
    $VirtualMachine=Set-AzVMBootDiagnostic -Disable -VM $VirtualMachine

    #Saving VM names in to array for later use
    $VMs+="$VMName$i"

    New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine


    
    #Installing IIS on all VMs
    $AccountName = "rnstoragerandom270356"
    $ContainerName="data"
    $BlobName="IIS_Config.ps1"
    $StorageRG="RG88"
    
    $StorageAccount=Get-AzStorageAccount -ResourceGroupName $StorageRG `
    -Name $AccountName
    
    $Blob=Get-AzStorageBlob -Context $StorageAccount.Context `
    -Container $ContainerName -Blob $BlobName
    
    $blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
    $StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $StorageRG `
    -AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}
    
    $settings=@{"fileUris"=$blobUri}
    
    $StorageAccountKeyValue=$StorageAccountKey.Value
    
    $protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
    "commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"};
    
    Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
    -VMName $VMs[$i-1] -Name "IISExtension" -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
    -Settings $settings -ProtectedSettings $protectedSettings      
  
    $i++

}