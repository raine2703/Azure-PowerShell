#Creating Azure SQL Server


$ResourceGroupName="RG7"
$Location="North Europe"
#New-Guid generates random nuber. Converting it to String and appending first 6 characters for unique Servername
$ServerName="dbserver" + (New-Guid).ToString().Substring(1,6)
$AdminUser="rn2703"
$AdminPassword="anSiubij2@1434s"


#Credentials for Server
$PasswordSecure=ConvertTo-SecureString -String $AdminPassword -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $AdminUser,$PasswordSecure


#Creating SQL Server
New-AzResourceGroup -Name $ResourceGroupName -Location $Location
New-AzSQLServer -ResourceGroupName $ResourceGroupName -ServerName $ServerName `
-Location $Location -SqlAdministratorCredentials $Credential


#Deploying Database
$DatabaseName="db03"
New-AzSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName `
-RequestedServiceObjectiveName "S0" -ServerName $ServerName


#Allowing connection from my IP
$IPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content

New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName -FirewallRuleName "Allow-Client" `
-StartIpAddress $IPAddress.Content -EndIpAddress $IPAddress.Content


#Different DB Pricing tiers available in region
Get-AzSqlServerServiceObjective -Location $Location



#Seeding SQL Database
$ScriptFile="C:\Users\raitisn\Desktop\Azure-PowerShell\02.Web-App-and-SQL-Database\data.sql"
Get-AzSqlServer -ResourceGroupName $ResourceGroupName | format-table

#Install-Module -Name SqlServer

#Running SQL comands to Azure SQL DB
Invoke-SqlCmd -ServerInstance "dbserver5f9f51.database.windows.net" -Database "db03" `
-Username $AdminUser -Password $AdminPassword -InputFile $ScriptFile