#Auditing SQL Database. Logs sent to Log analytics workspace.

$ResourceGroupName="RG7"
$DatabaseName="db01"
$ServerName="dbserver5f9f51"
$WorkspaceName="db-workspace2"

$LogAnalyticsWorkspace=New-AzOperationalInsightsWorkspace -Location $Location `
-Name $WorkspaceName -ResourceGroupName $ResourceGroupName

# We can then stream the audit logs to the Log Analytics workspace

Set-AzSqlDatabaseAudit -ResourceGroupName $ResourceGroupName -ServerName $ServerName `
-DatabaseName $DatabaseName -LogAnalyticsTargetState Enabled `
-WorkspaceResourceId $LogAnalyticsWorkspace.ResourceId