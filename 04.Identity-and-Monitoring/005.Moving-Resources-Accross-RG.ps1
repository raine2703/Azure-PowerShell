#Note! Resources won't be moved to another location. Logical grouping will be changed by changing RG, but resources wont be moved.

#Bulding setup - Creating Azure Web App

$ResourceGroupName="RG3"
$Location="North Europe"
$AppServicePlanName="AppServicePlan"
$WebAppName="rnwebpage2703x2"


#Creating App Service Plan
New-AzResourceGroup -name $ResourceGroupName -Location $Location

New-AzAppServicePlan -ResourceGroupName $ResourceGroupName `
-Location $Location -Tier "B1" -NumberofWorkers 1 -Name $AppServicePlanName

#Creating Azure Web App
New-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName `
-Location $Location -AppServicePlan $AppServicePlanName


#Creating another RG
$ResourceGroupName="RG4"
$Location="West Europe"

New-AzResourceGroup -name $ResourceGroupName -Location $Location


#Logical part and checking
