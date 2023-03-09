#Creating custom object

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
