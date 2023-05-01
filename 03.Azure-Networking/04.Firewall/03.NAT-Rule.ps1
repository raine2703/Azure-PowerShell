#Creating NAT rule. RDP to firewall-ip:4000 will connect to  VM private IP 10.0.0.4:3839


$FirewallPolicyName="firewall-policy"
$ResourceGroupName="RG7"

$PublicIPDetails=@{
    Name='firewall-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

#Creating NATCollectionGroup
$CollectionGroup = New-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" -Priority 200 `
-ResourceGroupName $ResourceGroupName -FirewallPolicyName $FirewallPolicyName

$VmName="ImageVM"
$NATRuleName="Allow-RDP-$VmName"
$MyIPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

$FirewallPublicIPAddress=(Get-AzPublicIpAddress -Name $PublicIPDetails.Name).IpAddress

#Getting VM privatge IP address
$VMNetworkProfile=(Get-AzVm -Name $VmName).NetworkProfile
$NetworkInterface=Get-AzNetworkInterface -ResourceId $VMNetworkProfile.NetworkInterfaces[0].Id
$VMPrivateIPAddress=$NetworkInterface.IpConfigurations[0].PrivateIpAddress

#Adding rule to allow connection from my PC to firewall public ip address port 4000
$Rule1=New-AzFirewallPolicyNatRule -Name $NATRuleName -Protocol "TCP" -SourceAddress $MyIPAddress.Content `
-DestinationAddress $FirewallPublicIPAddress -DestinationPort "4000" `
-TranslatedAddress $VMPrivateIPAddress -TranslatedPort "3389"

#Linking Collection with Rule1
$Collection=New-AzFirewallPolicyNatRuleCollection -Name "CollectionA" -Priority 1000 -Rule $Rule1 `
-ActionType "Dnat"
 
#Updating Collection Group
$CollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" `
-ResourceGroupName $ResourceGroupName -AzureFirewallPolicyName $FirewallPolicyName

$CollectionGroup.Properties.RuleCollection.Add($Collection)


#Updating Firewall
$FirewallPolicy = Get-AzFirewallPolicy -Name $FirewallPolicyName -ResourceGroupName $ResourceGroupName

Set-AzFirewallPolicyRuleCollectionGroup -Name "NATCollectionGroup" -Priority 200 `
-FirewallPolicyObject $FirewallPolicy -RuleCollection $CollectionGroup.Properties.RuleCollection