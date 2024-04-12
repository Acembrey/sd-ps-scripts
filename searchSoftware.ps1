do {
    $labPaths = Get-Content ".\labPaths.txt" 
    $keyword = Read-Host "What are you looking for?" 
    
    $index = 0 
    $array = @() 

    foreach($lab in $labPaths){
        $matches = Get-ChildItem -Recurse -Depth 1 $lab | Where-Object { $_.FullName -like "*$keyword*"} 
        
        foreach($match in $matches){
            $output = "$index. $($match.FullName)" 
            $array += $match.FullName  
            Write-Host $output
            $index++ 
        }
    }

    $searchAgain = Read-Host "Would you like to search again? (Y/N)"

    if($searchAgain -eq "N"){
        exit
    }
} while ($searchAgain -eq "Y")
