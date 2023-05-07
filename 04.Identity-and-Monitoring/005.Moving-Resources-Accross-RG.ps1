#Note! Resources won't be moved to another location. Logical grouping will be changed by changing RG, but resources wont be moved.

#Bulding setup - Creating Azure Web App

$SourceResourceGroupName="RG3"
$SourceLocation="North Europe"
$AppServicePlanName="AppServicePlan"
$WebAppName="rnwebpage2703x2"


#Creating App Service Plan
New-AzResourceGroup -name $SourceResourceGroupName -Location $SourceLocation

New-AzAppServicePlan -ResourceGroupName $SourceResourceGroupName `
-Location $SourceLocation -Tier "B1" -NumberofWorkers 1 -Name $AppServicePlanName


#Creating Azure Web App
New-AzWebApp -ResourceGroupName $SourceResourceGroupName -Name $WebAppName `
-Location $SourceLocation -AppServicePlan $AppServicePlanName


#Creating another RG
$DestResourceGroupName="RG4"
$DestLocation="West Europe"

New-AzResourceGroup -name $DestResourceGroupName -Location $DestLocation


#Moving Resources
function Get-ResourceGroupName {
    param (
        [String] $ResourceName
    )

    $Resource=Get-AzResource -Name $ResourceName
    return $Resource.ResourceGroupName
    
}


function Get-ResourceGroupID {
    param (
        [String] $ResourceGroupName
    )

    $ResourceGroup=Get-AzResourceGroup -Name $ResourceGroupName
    return $ResourceGroup.ResourceId
}

function Get-ResourceId {
    param (
        [String] $ResourceName
    )

    $Resource=Get-AzResource -Name $ResourceName
    return $Resource.ResourceId
    
}

$ResourceName="rnwebpage2703x2"
$DestResourceGroupName="RG4"

$SourceResourceGroupName=(Get-ResourceGroupName $ResourceName)
$SourceResourceGroupId=(Get-ResourceGroupID $SourceResourceGroupName)
$DestinationResourceGroupId=(Get-ResourceGroupID $DestResourceGroupName)
$ResourceId=(Get-ResourceId $ResourceName)

#Before moving its usefull to check if it's possible
Invoke-AzResourceAction -Action validateMoveResources `
-ResourceId $SourceResourceGroupId `
-Parameters @{resources=@($ResourceId);targetResourceGroup=$DestinationResourceGroupId} `
-Force

#Moving resources
Move-AzResource -DestinationResourceGroupName $DestResourceGroupName `
-ResourceId $ResourceId