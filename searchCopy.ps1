# drewbert mcgee embrey

$user = $env:USERNAME
$remoteComputer = Read-Host "Please enter remote computer for copy"

function Get-FolderSize {
    param (
        [string]$Path
    )

    # Retrieve all items from the specified path
    $items = Get-ChildItem -Path $Path -Recurse

    # Calculate total size
    $totalSize = ($items | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum

    # Determine the appropriate size unit based on the total size
    if ($totalSize -ge 1GB) {
        $totalSizeFormatted = "{0:N2} GB" -f ($totalSize / 1GB)
    }
    elseif ($totalSize -ge 1MB) {
        $totalSizeFormatted = "{0:N2} MB" -f ($totalSize / 1MB)
    }
    elseif ($totalSize -ge 1KB) {
        $totalSizeFormatted = "{0:N2} KB" -f ($totalSize / 1KB)
    }
    else {
        $totalSizeFormatted = "{0:N2} Bytes" -f $totalSize
    }

    # Output the result
    Write-Output "Total size of $Path : $totalSizeFormatted"
}
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

    $selectNumber = Read-Host "Please input number of selected path"
    $selectNumber = [int]$selectNumber

    if($selectNumber -ge 0 -and $selectNumber -lt $array.Length){
        $selectedPath = $array[$selectNumber]  
        
        $fileSize = Get-FolderSize $selectedPath
        $confirmCopy = Read-Host "The size of the selected file/directory is $fileSize . Continue with copying? (Y/N)"
        
        if($confirmCopy -eq "Y"){
            Copy-Item -Recurse -Path $selectedPath -Destination "C:\Deploy" 
        
            $localPath = "C:\Deploy\$($selectedPath.Split('\')[-1])" 
            $remotePath = "\\$remoteComputer\C$\Users\$user" 
            
            if(Test-Path $remotePath){
                Copy-Item -Recurse -Path $localPath -Destination "$remotePath\Desktop\1286install"
                Get-ChildItem "$remotePath\Desktop\1286install" 
            } else {
                Write-Host "Please ensure that you have logged into to this machine before running this script"
            }
        } elseif (Test-Path $localPath){
            Remove-Item $localPath -Force -Recurse
        }
        
    } else {
        Write-Host "Invalid selection."
    }

    $searchAgain = Read-Host "Would you like to search again? (Y/N)"
    
    if ($searchAgain -eq "Y") {
    } elseif ($searchAgain -eq "N") {
        exit
    } 

} while ($searchAgain -eq "Y")
