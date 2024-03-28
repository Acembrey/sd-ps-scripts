# Get total size of a directory and all its contents, and optionally copy it to a destination
function Get-DirectorySize {
    param (
        [string]$path,
        [string]$localDestination = "C:\Deploy"
    )

    # Prompt the user to enter a computer name for remote destination
    $remoteComp = Read-Host -Prompt "Enter the computer name for the remote destination"
    Write-Host "Entered computer name for remote destination: $remoteComp"

    # Construct remote destination path
    $remoteDestination = "\\$remoteComp\C$\Deploy"
    Write-Host "Remote destination path: $remoteDestination"

    # Get all files and subdirectories recursively
    $items = Get-ChildItem -Path $path -Recurse

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

    Write-Host "Total size of the directory is approximately $totalSizeFormatted."

    # Prompt the user for confirmation
    $confirmationMessage = "Do you want to copy this directory to your local machine and then to the remote machine? (Y/N)"
    $userResponse = Read-Host -Prompt $confirmationMessage

    if ($userResponse -eq "Y" -or $userResponse -eq "y") {
        Write-Host "Starting the copy process..."

        # Copy the directory to the local machine if confirmed
        Write-Progress -Activity "Copying Directory" -Status "Copying files to local machine..." -PercentComplete 0

        # Create local destination directory
        $localDirectory = Join-Path $localDestination (Split-Path -Leaf $path)
        New-Item -Path $localDirectory -ItemType Directory -Force | Out-Null

        Write-Host "Local directory created: $localDirectory"

        $fileCount = 0

        foreach ($item in $items) {
            $relativePath = $item.FullName.Replace($path, "").TrimStart("\")
            $localPath = Join-Path $localDirectory $relativePath

            if ($item.PSIsContainer) {
                New-Item -Path $localPath -ItemType Directory -Force | Out-Null
            }
            else {
                Copy-Item -Path $item.FullName -Destination $localPath -Force
                $fileCount++
                $percentComplete = ($fileCount / $items.Count) * 100
                Write-Progress -Activity "Copying Directory" -Status "Copying files to local machine..." -PercentComplete $percentComplete
            }
        }

        # Copy the directory from local machine to remote machine
        Write-Progress -Activity "Copying Directory" -Status "Copying files to remote machine..." -PercentComplete 0

        # Create remote destination directory
        $remoteDirectory = Join-Path $remoteDestination (Split-Path -Leaf $path)
        New-Item -Path $remoteDirectory -ItemType Directory -Force | Out-Null

        Write-Host "Remote directory created: $remoteDirectory"

        $fileCount = 0

        foreach ($item in $items) {
            $relativePath = $item.FullName.Replace($path, "").TrimStart("\")
            $remotePath = Join-Path $remoteDirectory $relativePath

            if ($item.PSIsContainer) {
                New-Item -Path $remotePath -ItemType Directory -Force | Out-Null
            }
            else {
                Copy-Item -Path $item.FullName -Destination $remotePath -Force
                $fileCount++
                $percentComplete = ($fileCount / $items.Count) * 100
                Write-Progress -Activity "Copying Directory" -Status "Copying files to remote machine..." -PercentComplete $percentComplete
            }
        }

        Write-Host "Starting cleanup process..."

        Write-Progress -Activity "Cleaning Up" -Status "Removing local directory..." -PercentComplete 0

        # Remove local directory and its contents
        Remove-Item -Path $localDestination -Recurse -Force

        Write-Progress -Activity "Cleaning Up" -Status "Local directory removed." -Completed

        Write-Host "Local directory and its contents removed."

        Write-Host "Directory copied to: $remoteDirectory"
    }
    else {
        Write-Host "Copy operation canceled."
    }

    [PSCustomObject]@{
        "TotalSize" = $totalSizeFormatted
        "RemoteDestinationPath" = $remoteDirectory
    }
}


$targetDirectory = Read-Host "Please enter the path to directory/file to be copied"
$result = Get-DirectorySize -path $targetDirectory
$result