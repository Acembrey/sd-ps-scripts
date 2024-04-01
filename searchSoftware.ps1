function Search-Directory {
    param (
        [string]$Path,
        [int]$Depth,
        [string]$Keyword
    )
    
    # Get directories at the current level
    $directories = Get-ChildItem -Path $Path -Directory

    # Search for directories containing the keyword
    $matchingDirectories = $directories | Where-Object { $_.Name -like "*$Keyword*" }

    # Output matching directories
    foreach ($dir in $matchingDirectories) {
        Write-Output $dir.FullName
    }

    # Check recursion depth
    if ($Depth -gt 1) {
        # Recursively search subdirectories
        foreach ($dir in $directories) {
            Search-Directory -Path $dir.FullName -Depth ($Depth - 1) -Keyword $Keyword
        }
    }
}

# Prompt user to enter a keyword
$Keyword = Read-Host "Enter the keyword to search for"

# Read paths from the text file
$Labs = Get-Content ".\labs.txt"

# Loop through each path and search for the keyword
foreach ($path in $Labs) {
    Search-Directory -Path $path -Depth 3 -Keyword $Keyword
}
