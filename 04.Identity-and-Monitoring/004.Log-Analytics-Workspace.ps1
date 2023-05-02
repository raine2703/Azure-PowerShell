#Creating Log Analytics Workspace and Connecting VM to it. 
#This is legacy solution. Agents and Data collection rules is the new way.

$WorkspaceName="vmrandomws2703"
$ResourceGroupName="RG8"
$Location="North Europe"


#Creating LAW
$LogAnalyticsWorkspace=New-AzOperationalInsightsWorkspace -Location $Location `
-Name $WorkspaceName -ResourceGroupName $ResourceGroupName


#Adding from windows event log
New-AzOperationalInsightsWindowsEventDataSource -ResourceGroupName $ResourceGroupName `
-WorkspaceName $WorkspaceName -EventLogName "Application" -CollectErrors `
-CollectWarnings -CollectInformation -Name "Application Event Logs"


#Adding VM to LAW with LAW ID and KEY
$LogAnalyticsWorkspace=Get-AzOperationalInsightsWorkspace -Name $WorkspaceName `
-ResourceGroupName $ResourceGroupName

$WorkspaceID=$LogAnalyticsWorkspace.CustomerId
$WorkspaceKey=(Get-AzOperationalInsightsWorkspaceSharedKeys `
-ResourceGroupName $ResourceGroupName -Name $WorkspaceName).PrimarySharedKey

$VMNames="appvm"
$PublicSettings=@{"workspaceId" = $WorkspaceID}
$ProtectedSettings=@{"workspaceKey" = $WorkspaceKey}


#If multiple VMs foreach can be used
foreach($VM in $VMNames)
{
    Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
    -ResourceGroupName $ResourceGroupName -VMName $VM `
    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
    -ExtensionType "MicrosoftMonitoringAgent" `
    -TypeHandlerVersion 1.0 `
    -Location $Location `
    -Settings $PublicSettings `
    -ProtectedSettings $ProtectedSettings
}