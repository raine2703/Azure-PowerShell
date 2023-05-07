

### Change Terminal from PowerShell Integrated Console to PowerShell in VSCode AzureAd module to work !!! 


#Connect to Azure
Connect-AzAccount -tenantid c20a49b8-2914-4624-a197-1e882bd3abf4
Set-AzContext -Subscription 'XXXX'
Disconnect-AzAccount

#You aslo need AzureAD module
Install-Module AzureAD -Force
Update-Module -Name AzureAD -force
Import-Module AzureAD
Import-Module AzureAD -UseWindowsPowerShell
Get-InstalledModule

#To connect to Az AD
Connect-AzureAD -tenantid c20a49b8-2914-4624-a197-1e882bd3abf4


#Creating New User
$UserName="UserAC"
$UserPrincipalName="UserAC@raitisneitalsgmail.onmicrosoft.com"
$Password="Azure@123"
$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

New-AzADUser -DisplayName $UserName -Password $PasswordSecure -UserPrincipalName $UserPrincipalName -MailNickName $UserName


#User details
$UserPrincipalName="UserAC@raitisneitalsgmail.onmicrosoft.com"
$User=Get-AzADUser -ObjectId $UserPrincipalName


#Assign RBAC role to the user
New-AzResourceGroup -Name $ResourceGroupName -Location "northeurope"

$UserObjectID=$User.Id

$ResourceGroupName = "powershell-grp"
$Subcription=Get-AzSubscription -SubscriptionName "Pay-As-You-Go"
$scope="/subscriptions/$Subcription/resourcegroups/$ResourceGroupName"
$RoleDefinition="Reader"

New-AzRoleAssignment -ObjectId $UserObjectID -RoleDefinitionName $RoleDefinition `
-Scope $scope


#Delete Azure AD User
$UserPrincipalName="UserAC@raitisneitalsgmail.onmicrosoft.com"
$User=Get-AzADUser -ObjectId $UserPrincipalName
$UserObjectID=$User.Id

Remove-AzADUser -ObjectId $UserObjectID