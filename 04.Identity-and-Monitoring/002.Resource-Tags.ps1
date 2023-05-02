#Working with Azure Tags

#Function to Get Resource ID
function Get-ResourceId
{
    param([String] $ResourceName)
    
    $Resource=Get-AzResource -Name $ResourceName
    return $Resource.Id
}

#Tags
$Tags = @{
    "Env" = "Prod";
    "Tier" ="1"
}

#Resource for example
$ResourceName="NetworkWatcher_northeurope"

# Creating New Tag
New-AzTag -Tag $Tags -ResourceId (Get-ResourceId $ResourceName)

#Get Tag Names and Values assigned
$TagsAssigned=Get-AzTag -ResourceId (Get-ResourceId $ResourceName)

#Get Tag Names or Keys
$Keys=$TagsAssigned.Properties.TagsProperty.Keys

#Get Tag Values
foreach($Key in $Keys)
{
    $TagsAssigned.Properties.TagsProperty.Item($Key)
}

#Get Resources with Tags
$resources = Get-AzResource -TagName "Env" -TagValue "Prod" 
$resources_formated = Get-AzResource -TagName "Env" -TagValue "Prod" | Format-table

$i=0
foreach ($r in $resources) {
    $r.Name
    $i++
}
'Resources with tags Env:Prod: ' +$i