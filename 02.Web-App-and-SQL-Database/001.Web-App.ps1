#Creating Azure Web App


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



#Web App Firewall
$IPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

#Restricting All Access from Internet
Add-AzWebAppAccessRestrictionRule -ResourceGroupName $ResourceGroupName `
-WebAppName $WebAppName -Name "DenyAll" -Priority 400 `
-IpAddress "0.0.0.0/0" -Action Deny

#Converting to valid CIDR format
$WorkstationIPAddress = $IPAddress.Content + "/32"

#Allowing access from my IP. Simple firewall rule with higher priority than deny rule.
Add-AzWebAppAccessRestrictionRule -ResourceGroupName $ResourceGroupName `
-WebAppName $WebAppName -Name "AllowClient" -Priority 300 `
-IpAddress $WorkstationIPAddress -Action Allow



#Staging Slots
#Switching tier to Standard
Set-AzAppServicePlan -Name $AppServicePlanName -ResourceGroupName $ResourceGroupName `
-Tier Standard

#Creating new Staging slot
$SlotName="Development"
New-AzWebAppSlot -Name $WebAppName -ResourceGroupName $ResourceGroupName `
-Slot $SlotName

# rnwebpage2703x2-development.azurewebsites.net will be created in Deployment slots!

#Moving Development page to Production slot!
$TargetSlot="production"
Switch-AzWebAppSlot -Name $WebAppName -ResourceGroupName $ResourceGroupName `
-SourceSlotName $SlotName -DestinationSlotName $TargetSlot



<#

Github Integration

$Properties =@{
    repoUrl="";
    branch="master";
    isManualIntegration="true";
}

Set-AzResource -ResourceGroupName $ResourceGroupName `
-Properties $Properties -ResourceType Microsoft.Web/sites/sourcecontrols `
-ResourceName $WebAppName/web -ApiVersion 2015-08-01 -Force

#>



<#

Enable Web App logging

Set-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName `
-RequestTracingEnabled $True -HttpLoggingEnabled $True `
-DetailedErrorLoggingEnabled $True

#>