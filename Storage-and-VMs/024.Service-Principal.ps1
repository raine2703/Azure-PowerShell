#Creating Service principal and Assigning/Removing roles for it.
#As Service principal secret value is displayed only once when created saving it in Key Vault for reusability.


#Turn off autosaving Azure credentials. Your login information will be forgotten the next time you open a PowerShell window
Disable-AzContextAutosave


#Connecting with my Admin account
Connect-AzAccount

#Creating Service principal
$ServicePrincipalName="random-principal"
$ServicePrincipal=New-AzADServicePrincipal -DisplayName $ServicePrincipalName

#Getting service principal secret value
$ServicePrincipalId=$ServicePrincipal.Id
$ServicePrincipalSecret=$ServicePrincipal.PasswordCredentials.SecretText


        #Saving Service principal name in Key Vault!
        $KeyVaultName="rkv2703x" #asuming its created
        $SecretValue = ConvertTo-SecureString $ServicePrincipalSecret -AsPlainText -Force

        #Storing
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ServicePrincipalName `
        -SecretValue $SecretValue

        #Getting AppSecret from key vault, also defining other log in variables for new Service principal. 
        #Will use then after log off from admin account.
        $Appid=$ServicePrincipal.AppId
        $AppSecret=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $ServicePrincipalName `
        -AsPlainText
        $Securesecret=$Appsecret | ConvertTo-SecureString -AsPlainText -force
        $Credential=New-Object -TypeName System.Management.Automation.PSCredential `
        -ArgumentList $Appid, $Securesecret
        $TenandID="c20a49b8-2914-4624-a197-1e882bd3abf4"


#Defining Scope and Role
$Subcription=Get-AzSubscription -SubscriptionName "Pay-As-You-Go"
$scope="/subscriptions/$Subcription"
$RoleDefinition="Contributor"

#Assigning Role to Service principal
New-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionName $RoleDefinition `
-Scope $scope

#Disconect from Azure Admin account
Disconnect-AzAccount



#Conecting to Azure as new Service principal. Variables defined previousely working as Admin!
Connect-AzAccount -ServicePrincipal -Credential $Credential -Tenant $TenandID 

New-AzResourceGroup -Name "demo-grp" -Location "North Europe"

Disconnect-AzAccount



#Removing and Assigning roles to service principal

#Connecting with my Admin account
Connect-AzAccount

$ResourceGroupName = "demo-grp" #Asuming its created

$ServicePrincipal =Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
$ServicePrincipalId=$ServicePrincipal.Id

#Adding Contributor role to RG level
$Subcription=Get-AzSubscription -SubscriptionName "Pay-As-You-Go"
$scope="/subscriptions/$Subcription/resourcegroups/$ResourceGroupName"
$RoleDefinition="Contributor"

New-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionName $RoleDefinition `
-Scope $scope

#Removing Contributor role at Subscription level
$scope="/subscriptions/$Subcription"
$RoleDefinition="Contributor"

Remove-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionName $RoleDefinition `
-Scope $scope

#Disconecting as Azure admin
Disable-AzContextAutosave
Disconnect-AzAccount