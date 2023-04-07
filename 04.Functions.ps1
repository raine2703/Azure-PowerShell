#Functions

function get-appversionx {
    $PSVersionTable
}

function sumofnumbers([int]$x, [int]$y) {
    'Sum of numbers is ' + ($x+$y)
}
sumofnumbers 5 9


function Get-Course
{
    param(
        [Object[]] $CourseList2x
    )

    foreach($x in $CourseList2x)
{
    $x.Id
    $x.Name
    $x.Rating
}
}

$CourseList=@(
    [PSCustomObject]@{
        Id = 1
        Name ='AZ-104 Azure Administrator'
        Rating = 4.7
    },
    [PSCustomObject]@{
        Id = 2
        Name ='AZ-305 Azure Architect Design'
        Rating = 4.8
    },
    [PSCustomObject]@{
        Id = 3
        Name ='AZ-500 Azure Security'
        Rating = 4.9
    }
)


Get-Course $CourseList