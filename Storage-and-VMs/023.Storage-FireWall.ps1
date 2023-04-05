#Storage account firewall. Allowing connection from my PC and from VMs in specific Subnet.

#Creating Azure Storage Account
$ResourceGroupName="RG7"
$Location="West Europe"
$AccountName="rnstorage270355x2"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"


$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location 
$StorageAccount=New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU


#Setting default rule to deny network connections to Storage Account
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName `
-Name $AccountName -DefaultAction Deny


#MyIpAddress
$IPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content
$IPAddress


#CASE1 - Allowing my PC to connect to Storage accout by adding new rule to Firewall
#Test by Uploading/Accessing Blow
Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName -IPAddressOrRange $IPAddress.Content


#CASE2 - Allowing connection from VMs in Azure Vnet/Subnet
#Creating Vnet for test purposes
$VirtualNetworkName="Vnet"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace
$VirtualNetwork=New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet


#If Vnet is already created just have to get values
$VirtualNetwork=Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName
$SubnetConfig = $VirtualNetwork | Get-AzVirtualNetworkSubnetConfig

#1.Adding Service endpoint to Subnet[0]
Set-AzVirtualNetworkSubnetConfig -Name $SubnetConfig[0].Name `
-ServiceEndpoint "Microsoft.Storage" -VirtualNetwork $VirtualNetwork `
-AddressPrefix $SubnetConfig[0].AddressPrefix `
| Set-AzVirtualNetwork

#2.Adding rule to Storage Firewall that adds Subnet
Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName -VirtualNetworkResourceId $SubnetConfig[0].Id

#All VMs added in Subnet will be able to connect to Storage Account