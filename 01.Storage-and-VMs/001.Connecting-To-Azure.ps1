#Connecting to Azure subscription using Application ID.
#Correct way to manage resources.
#Application is registered in Azure AD. Permissions to it are granted via RBAC.

$Appid="2825a820-aceb-4cc5-a33b-888cd0c9a7e2"
$Appsecret="g-P8Q~iQodLcTzDc_K3LL~VxUwPIM.PgP1Zi6bzS"
$Securesecret=$Appsecret | ConvertTo-SecureString -AsPlainText -force
$Credential=New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $Appid, $Securesecret
$TenandID="c20a49b8-2914-4624-a197-1e882bd3abf4"

Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenandID

$SubscriptionName="Pay-As-You-Go"
$Subcription=Get-AzSubscription -SubscriptionName $SubscriptionName

#Set Subscription to work with
Set-AzContext -SubscriptionObject $Subcription

#Disconnect-AzAccount