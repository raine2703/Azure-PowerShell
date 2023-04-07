#Get-Gelp
Get-Help New-AzResourceGroup -Full

#Debug in case of errors
$RG=New-AzResourceGroup -Name $ResourceGroupName -Location $Location -debug

#String Operations with Methods
$RandomName="ABC123Test2"
$RandomName.Contains("BC")
$RandomName.EndsWith("2")
