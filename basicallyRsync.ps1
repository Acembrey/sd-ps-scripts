# Define env for modularity
$user = $env:USERNAME

# Define paths
$sourceFolder = "\path\to\remote\folder"
$destinationFolder = "C:\Users\$user\Desktop\"

# Check if source folder exists
if (-not (Test-Path $sourceFolder)) {
    Write-Host "Source folder '$sourceFolder' does not exist."
    exit
}

# Check if destination folder exists, if not, create it
if (-not (Test-Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory -Force
}

$filesCopiedOrUpdated = $false

# Function to copy files and directories recursively
function Copy-FilesRecursively {
    param (
        [string]$sourcePath,
        [string]$destinationPath
    )

    # Get all items from source path
    $items = Get-ChildItem -Path $sourcePath

    foreach ($item in $items) {
        $newDestinationPath = Join-Path -Path $destinationPath -ChildPath $item.Name

        if ($item.PSIsContainer) {
            # Check if destination directory exists, if not, create it
            if (-not (Test-Path $newDestinationPath)) {
                New-Item -Path $newDestinationPath -ItemType Directory -Force
            }

            # Recursively copy directories
            Copy-FilesRecursively -sourcePath $item.FullName -destinationPath $newDestinationPath
        } else {
            # Check if destination directory exists, if not, create it
            $destinationDirectory = Split-Path $newDestinationPath
            if (-not (Test-Path $destinationDirectory)) {
                New-Item -Path $destinationDirectory -ItemType Directory -Force
            }

            # Check if file already exists in destination folder
            if (Test-Path $newDestinationPath) {
                $sourceFileDate = $item.LastWriteTime
                $destinationFileDate = (Get-Item $newDestinationPath).LastWriteTime

                # Compare modification dates
                if ($sourceFileDate -gt $destinationFileDate) {
                    # Remove the older file from destination folder
                    Remove-Item -Path $newDestinationPath -Force
                    Write-Host "Removed older file '$newDestinationPath'."

                    # Copy the newer file to destination folder
                    Copy-Item -Path $item.FullName -Destination $newDestinationPath
                    Write-Host "Copied newer file '$item' to '$newDestinationPath'."
                    $filesCopiedOrUpdated = $true
                }
            } else {
                # Copy file to destination folder
                Copy-Item -Path $item.FullName -Destination $newDestinationPath
                Write-Host "Copied '$item' to '$newDestinationPath'."
                $filesCopiedOrUpdated = $true
            }
        }
    }
}

# Start recursive copying
Copy-FilesRecursively -sourcePath $sourceFolder -destinationPath $destinationFolder

# Check if any files were copied or updated
if (-not $filesCopiedOrUpdated) {
    Write-Host "No files needed to be copied or updated."
} else {
    Write-Host "Script execution completed."
}
