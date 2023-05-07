

### Change Terminal from PowerShell Integrated Console to PowerShell in VSCode to work !!! 


# Create/Remove custom RBAC role and assign it to Service principal. 

Connect-AzAccount

$RoleDefinition="Storage Account Contributor"
$Role=Get-AzRoleDefinition -Name $RoleDefinition

$Role.Id=$null
$Role.Name="Storage And Virtual Machine Contributor"
$Role.Description="Custom Role for Storage accounts and virtual machines"
$Role.Actions.Add("Microsoft.Compute/*/read")
$Role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$Role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")

$ResourceGroupName="powershell-grp"

New-AzResourceGroup -Name $ResourceGroupName -Location "northeurope"

$Subcription=Get-AzSubscription -SubscriptionName "Pay-As-You-GO"
$scope="/subscriptions/$Subcription/resourcegroups/$ResourceGroupName"

$Role.AssignableScopes.Clear()
$Role.AssignableScopes.Add($scope)

New-AzRoleDefinition -Role $Role 


#Assign to Service principal
$CustomRoleDefinition="Storage And Virtual Machine Contributor"
$CustomRole=Get-AzRoleDefinition -Name $CustomRoleDefinition

$ResourceGroupName = "powershell-grp"
$Subcription=Get-AzSubscription -SubscriptionName "Azure Subscription 1"
$scope="/subscriptions/$Subcription/resourcegroups/$ResourceGroupName"


$ServicePrincipalName="powershell"
$ServicePrincipal =Get-AzADServicePrincipal -DisplayName $ServicePrincipalName
$ServicePrincipalId=$ServicePrincipal.Id

New-AzRoleAssignment -ObjectId $ServicePrincipalId -RoleDefinitionId $CustomRole.Id `
-Scope $scope


# Delete the role
$CustomRoleDefinition="Storage And Virtual Machine Contributor"
$CustomRole=Get-AzRoleDefinition -Name $CustomRoleDefinition

#First delete the role assignments
$RoleAssignments=Get-AzRoleAssignment -RoleDefinitionId $CustomRole.Id

foreach($RoleAssignment in $RoleAssignments)
{
    Remove-AzRoleAssignment -ObjectId $RoleAssignment.ObjectId -RoleDefinitionName $CustomRoleDefinition `
    -Scope $RoleAssignment.Scope
}

Remove-AzRoleDefinition -Id $CustomRole.Id -Force