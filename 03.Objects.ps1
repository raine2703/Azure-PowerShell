#Creating custom Objects

$Course=[PSCustomObject]@{
    ID = 1
    Rating = 3.4
    Name = 'Azure administrator'
}
$Course

'The course id is ' + $Course.id


#Custom object list
$CourseList=@(
    [PSCustomObject]@{
        ID = 1
        Rating = 3.4
        Name = 'Azure Admin'
    },
    [PSCustomObject]@{
        ID = 2
        Rating = 3.4
        Name = 'Azure Dev'
    },
    [PSCustomObject]@{
        ID = 3
        Rating = 3.4
        Name = 'Azure Sec'
    }
)

$CourseList
$CourseList[0].name


#Continuing working with Objects

$Mobiles=@(
    [PSCustomObject]@{
        Brand = "Samsung"
        Model = "S22"
        Storage=@("128","256","512")
        DefaultApps=@(
            @{
                Name="Google Maps"
                Status="Installed"
            },
            @{
                Name="FireFox"
                Stats="Disabled"
            }
        )
    },
    [PSCustomObject]@{
        Brand = "Samsung"
        Model = "S23"
        Storage=@("8","16","32")
        DefaultApps=@(
            @{
                Name="Google Maps"
                Status="Installed"
            },
            @{
                Name="FireFox"
                Status="Disabled"
            }
        )
    }
)
$Mobiles
$mobiles[0]
$Mobiles[0].Storage[1]
$Mobiles[0].DefaultApps[0]
$Mobiles[0].DefaultApps.Item(0)
$mobiles.DefaultApps

foreach($x in $Mobiles[0]) {
    $x.Brand
    $x.Model
    $x.Storage
    $x.DefaultApps
}

foreach($y in $Mobiles.DefaultApps) {
    $y.name + ' is ' + $y.Status
    }

$Mobiles | Where-Object {$_.Model -eq "S23"}

$Mobiles | Where-Object {$_.Model -eq "S23"} | Select-Object -Property Model,Storage
$Mobiles | Where-Object {$_.Model -eq "S23"} | Select-Object -Property DefaultApps
