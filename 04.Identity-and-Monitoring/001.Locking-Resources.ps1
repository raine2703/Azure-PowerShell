#Adding and removing resource locks

#Function to get Resource Type
function Get-ResourceType {
    param([String] $ResourceName)

    $RType=Get-AzResource -Name $ResourceName
    return $RType.ResourceType
}

#Function to get RG name
function Get-ResourceGroup{
    param([String] $ResourceName)

    $RGType=Get-AzResource -Name $ResourceName
    return $RGType.ResourceGroupName
}


#Example resource name
$ResourceName="rkv2703x"


#Checking function results
Get-ResourceType $ResourceName
Get-ResourceGroup $ResourceName


#Admin account required to manage locks
Connect-AzAccount


#Creating new resource lock
New-AzResourceLock -LockLevel ReadOnly -LockName "LockA" `
-ResourceName $ResourceName -ResourceType (Get-ResourceType $ResourceName) `
-ResourceGroupName (Get-ResourceGroup $ResourceName) -Force


#Removing resource lock
$Lock=Get-AzResourceLock -LockName "LockA" `
-ResourceName $ResourceName -ResourceType (Get-ResourceType $ResourceName) `
-ResourceGroupName (Get-ResourceGroup $ResourceName)

if($null -ne $lock)
{
    Remove-AzResourceLock -LockName "LockA" `
    -ResourceName $ResourceName -ResourceType (Get-ResourceType $ResourceName) `
    -ResourceGroupName (Get-ResourceGroup $ResourceName) -Force
}