#Basics

$PSVersionTable

Get-InstalledModule

Get-ComputerInfo

(Get-ComputerInfo).OsInstallDate

Get-Service -Name "d*"

Get-Service -Displayname "*network*"

#Variables
$x = 5
$y = 6
$z=$x+$y
$z
$CourseName="Azure PowerShell"
"Value of x is $x"
'The value of x is ' + $x + ' Text continues'
$x.GetType()
$CourseName.GetType()

#Arrays
$coursevideos = 'abc','def','ghj'
$coursevideos

$coursenumbers = 123,456,789
$coursenumbers

#Arrays
$coursevideos_1=@(
    'abc'
    'cad'
    'asdx'
)
$coursevideos_1
$coursevideos_1[0]

#Updating array value
$coursevideos_1[0] = 'changed'
$coursevideos_1

#Key vaulue stores or Hash tables

<#Set 
of 
coments#>

$ServerNames=@{
    Dev='server01'
    Prod='server02'
    Test='server03'
}
$ServerNames
$ServerNames['Dev']
$ServerNames.Dev
$ServerNames.add('QA','server04')