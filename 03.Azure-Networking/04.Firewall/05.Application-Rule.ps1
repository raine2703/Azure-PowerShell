#Allowing traffic from VM to www.google.com via Application rule

$FirewallPolicyName="firewall-policy"
$ResourceGroupName="RG7"


#First new Rule collection required
$AppCollectionGroup = New-AzFirewallPolicyRuleCollectionGroup -Name "NewCollectionGroup" -Priority 700 `
-ResourceGroupName $ResourceGroupName -FirewallPolicyName $FirewallPolicyName

$SiteURL="*.google.com"
$AppRuleName="Allow-google-com"
$AppRuleDescription="Allow Traffic to " + $SiteURL


#Getting VM private IP
$VMNetworkProfile=(Get-AzVm -Name $VmName).NetworkProfile
$NetworkInterface=Get-AzNetworkInterface -ResourceId $VMNetworkProfile.NetworkInterfaces[0].Id
$VMPrivateIPAddress=$NetworkInterface.IpConfigurations[0].PrivateIpAddress


#Rule that allows traffic from private VM ip address true firewall to www.google.com
$AppRule1 = New-AzFirewallPolicyApplicationRule -Name $AppRuleName `
-Description $AppRuleDescription -SourceAddress $VMPrivateIPAddress `
-TargetFqdn $SiteURL -Protocol "http:80","https:443"


#Linking Collection to AppRule1
$AppCollection=New-AzFirewallPolicyFilterRuleCollection -Name "FilterCollection" `
-Priority 1000 -Rule $AppRule1 -ActionType Allow 

$AppCollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -Name "NewCollectionGroup" `
-ResourceGroupName $ResourceGroupName -AzureFirewallPolicyName $FirewallPolicyName
 
$AppCollectionGroup.Properties.RuleCollection.Add($AppCollection)


# Updating Firewall
$FirewallPolicy = Get-AzFirewallPolicy -Name $FirewallPolicyName -ResourceGroupName $ResourceGroupName
 
Set-AzFirewallPolicyRuleCollectionGroup -Name "NewCollectionGroup" -Priority 800 `
-FirewallPolicyObject $FirewallPolicy -RuleCollection $AppCollectionGroup.Properties.RuleCollection 