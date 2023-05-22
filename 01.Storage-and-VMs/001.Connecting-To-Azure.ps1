#Connecting to Azure subscription using Application ID.
#Correct way to manage resources.
#Application is registered in Azure AD. Permissions to it are granted via RBAC.

$Appid=""
$Appsecret=""
$Securesecret=$Appsecret | ConvertTo-SecureString -AsPlainText -force
$Credential=New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $Appid, $Securesecret
$TenandID=""

Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenandID

$SubscriptionName=""
$Subcription=Get-AzSubscription -SubscriptionName $SubscriptionName

#Set Subscription to work with
Set-AzContext -SubscriptionObject $Subcription

#Disconnect-AzAccount
