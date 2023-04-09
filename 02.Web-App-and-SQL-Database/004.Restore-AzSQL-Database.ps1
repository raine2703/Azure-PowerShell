#Restoring Azure Database on the same Azure SQL server

$ResourceGroupName="RG7"
$ServerName="dbserver5f9f51"
$SourceDatabaseName="db01"
$TargetDatabaseName="restored-db"


#Restore point: Currtent time - 30 minutes
$RestorePointTime=(Get-Date).AddMinutes(-30)

#Getting Database
$Database=Get-AzSqlDatabase -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName -DatabaseName $SourceDatabaseName

#Restoring DB. New DB names "restored-db" will be created.
Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime $RestorePointTime `
-ResourceGroupName $ResourceGroupName -ServerName $Database.ServerName `
-TargetDatabaseName $TargetDatabaseName -ResourceId $Database.ResourceId `
-Edition "Standard" -ServiceObjectiveName "S0"