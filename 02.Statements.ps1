# If, else, for, for each statements

$NumberOfVideos = 5

if($NumberOfVideos -ge 20) {
    "Greater or equal 20"
} else {
    "Less than 20"
}


#While statement
$i=1
while ($i -le 10) {
    $i
    ++$i
 }

 
#for statement
for($i=1; $i -le 10; ++$i){
    $i
}


#for each
$coursevideos = 'abc','def','ghj'

foreach ($x in $coursevideos) {
    $x + ' text'
}


$CourseList=@(
    [PSCustomObject]@{
        ID = 1
        Rating = 777
        Name = 'Azure Admin'
    },
    [PSCustomObject]@{
        ID = 2
        Rating = 999
        Name = 'Azure Dev'
    },
    [PSCustomObject]@{
        ID = 3
        Rating = 888
        Name = 'Azure Sec'
    }
)

foreach ($x in $CourseList) {
    $x.ID
    $x.Rating
    $x.Name
}