#Changing SQL Database Service tier

#Check available Service tiers for databases
Get-AzSqlServerServiceObjective -Location $Location

#Server And Database is created before
$DatabaseName="db03"
$ServerName="dbserver8efd0a"
$ResourceGroupName="RG7"

# Get what is the current service level objective
$SQLDatabase=Get-AzSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName

'Current Service Level Objective is ' + $SQLDatabase.RequestedServiceObjectiveName

$NewServiceLevelObjective="Basic"

Set-AzSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName -RequestedServiceObjectiveName $NewServiceLevelObjective

# Get the new service level objective
$SQLDatabase=Get-AzSqlDatabase -DatabaseName $DatabaseName -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName

'Current Service Level Objective is ' + $SQLDatabase.RequestedServiceObjectiveName