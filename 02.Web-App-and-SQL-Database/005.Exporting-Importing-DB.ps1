#Exporting Azure SQL DB to Azure Storage. 
#Creating new Azure SQL server with Database. 
#Importing Exported data from Storage account to new DB.

<#

Exporting Azure SQL database to Azure Storage Account Container.

#>


$ResourceGroupName = "RG7"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$Location="North Europe"
$ContainerName="db3backup"
$AccountName="rnstorage5231x2"

#Creating Storage Account
$StorageAccount =New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
-Name $AccountName -Location $Location -Kind $AccountKind -SkuName $AccountSKU

$Container=$null

#Creating Container Where DB will be exported
$Container=New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context `
-Permission Blob

#Source DB details
$SourceDatabaseName ="db03"
$SourceDatabaseServer="dbserver5f9f51"
$UserName="rn2703"
$Password="anSiubij2@1434s"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

#Getting location name for backup
$blobUri=$Container.CloudBlobContainer.Uri.AbsoluteUri + "/sqlbackup.bacpac"

$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$StorageAccountKeyValue=$StorageAccountKey.Value

#Exporting Database to Azure Storage Account Container
# "Allow Azure Resources to access this server" must be enables at SQL Server Networking Settings!!!
$DatabaseExport=New-AzSqlDatabaseExport -ResourceGroupName $ResourceGroupName `
-ServerName $SourceDatabaseServer -DatabaseName $SourceDatabaseName `
-AdministratorLogin $UserName -AdministratorLoginPassword $PasswordSecure `
-StorageKeyType StorageAccessKey -StorageKey $StorageAccountKeyValue -StorageUri $blobUri

#Displays Database export/import status in %. 
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink `
$DatabaseExport.OperationStatusLink

<#

Importing Exported data to new Azure SQL Server and Database!

#>

$ResourceGroupName="RG7"
$TargetLocation="West Europe"
$TargetServerName="newserver" + (New-Guid).ToString().Substring(1,6)
$TargetAdminUser="rn2703"
$TargetAdminPassword="anSiubij2@1434s"
$TargetDatabaseName="restored-db3"

$TargetPasswordSecure=ConvertTo-SecureString -String $TargetAdminPassword -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $TargetAdminUser,$TargetPasswordSecure


#Creating new SQL Server
New-AzSQLServer -ResourceGroupName $ResourceGroupName -ServerName $TargetServerName `
-Location $TargetLocation -SqlAdministratorCredentials $Credential

#Creating new SQL database
New-AzSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $TargetDatabaseName `
-RequestedServiceObjectiveName "S0" -ServerName $TargetServerName

$IPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

#Allowing my PC to connect to new SQL Server
New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName `
-ServerName $TargetServerName -FirewallRuleName "Allow-Client" `
-StartIpAddress $IPAddress.Content -EndIpAddress $IPAddress.Content


#Importing exported DB to newly created SQL Server and Database
# "Allow Azure Resources to access this server" must be enables at new SQL Server Networking Settings!!!
$DatabaseImport=New-AzSqlDatabaseImport -DatabaseName $TargetDatabaseName `
-ServiceObjectiveName "S3" -Edition "Standard" -DatabaseMaxSizeBytes 268435456000 `
-AdministratorLogin $TargetAdminUser -AdministratorLoginPassword $TargetPasswordSecure `
-ServerName $TargetServerName -ResourceGroupName $ResourceGroupName `
-StorageKeyType StorageAccessKey -StorageKey $StorageAccountKeyValue -StorageUri $blobUri

#Displays Database export/import status in %. 
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink `
$DatabaseImport.OperationStatusLink