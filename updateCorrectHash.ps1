# This script is highly specific. A hash error with Curl was causing Window's update to fail. There were multiple components to this script that I can not include here, but this script was my portion of the fix. It looked through a folder containing all known
# versions of curl, checks their hash, and then compares that hash to the expected hash in the CBS.log folder. It would then replaced the existing curl.exe's in the repair folder to the correct version. 

# Define the path to your log file
$logFilePath = "C:\Windows\Logs\CBS\CBS.log"

# Define the regex patterns to match the expected and actual values
$expectedPattern = "Expected: {l:32 ml:33 b:([a-fA-F0-9]+)}"
$actualPattern = "Actual: {l:32 b:([a-fA-F0-9]+)}"

# Read the log file line by line
$logContent = Get-Content -Path $logFilePath

# Initialize a variable to store the first expected value
$expectedValue1 = $null

# Initialize a variable to store the first actual value
$actualValue1 = $null

# Iterate through each line and search for the first expected and actual values
foreach ($line in $logContent) {
    if ($line -match $expectedPattern) {
        $expectedValue1 = $matches[1]
    }
    elseif ($line -match $actualPattern) {
        $actualValue1 = $matches[1]
    }

    # Exit the loop if both expected and actual values are found
    if ($expectedValue1 -and $actualValue1) {
        break
    }
}

# Initialize a variable to store the second expected value
$expectedValue2 = $null

# Initialize a variable to store the second actual value
$actualValue2 = $null

# Initialize a variable to track if the second expected value is found
$foundSecondExpected = $false

# Iterate through each line again to search for the second expected and actual values
foreach ($line in $logContent) {
    if ($line -match $expectedPattern) {
        $expectedValue2 = $matches[1]

        # Check if the second expected value is different from the first one
        if ($expectedValue2 -ne $expectedValue1) {
            $foundSecondExpected = $true
        }
    }
    elseif ($line -match $actualPattern) {
        $actualValue2 = $matches[1]

        # Exit the loop if both expected and actual values are found
        if ($foundSecondExpected -and $actualValue2) {
            break
        }
    }
}

# Output the extracted expected and actual values
if ($expectedValue1) {
    Write-Output "Expected value 1: $expectedValue1"
} else {
    Write-Output "Expected value 1 not found in the log file."
}

if ($actualValue1) {
    Write-Output "Actual value 1: $actualValue1"
} else {
    Write-Output "Actual value 1 not found in the log file."
}

if ($foundSecondExpected -and $expectedValue2) {
    Write-Output "Expected value 2: $expectedValue2"
} else {
    Write-Output "Expected value 2 not found in the log file or is identical to expected value 1."
}

if ($actualValue2) {
    Write-Output "Actual value 2: $actualValue2"
} else {
    Write-Output "Actual value 2 not found in the log file."
}

$curlCaptureFolder = "C:\CurlRepair\CurlCapture"

# Loop through each folder in the "curlcapture" directory
foreach ($folder in Get-ChildItem -Path $curlCaptureFolder -Directory) {
    # Loop through each "curl.exe" file in the current folder
    foreach ($file in Get-ChildItem -Path $folder.FullName -Filter "curl.exe" -File) {
        # Get the hash of the current "curl.exe" file
        $actualHash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash

        # Compare the hash with the expected values
        if ($actualHash -eq $expectedValue1 -or $actualHash -eq $expectedValue2) {
            Write-Output "Match found: $($file.FullName)"
        }
    }
}

# Define the target directory for repaired "curl.exe" files
$repairDirectory = "C:\CurlRepair"

# Define the paths to the System32 and SysWOW64 directories
$system32Directory = Join-Path $repairDirectory "System32"
$sysWOW64Directory = Join-Path $repairDirectory "SysWOW64"

# Get the hash of the existing "curl.exe" file in System32
$system32Hash = (Get-FileHash -Path "$system32Directory\curl.exe" -Algorithm SHA256).Hash

# Get the hash of the existing "curl.exe" file in SysWOW64
$sysWOW64Hash = (Get-FileHash -Path "$sysWOW64Directory\curl.exe" -Algorithm SHA256).Hash

# Rename the existing "curl.exe" files in System32 and SysWOW64 to "curl.old"
Rename-Item -Path "$system32Directory\curl.exe" -NewName "curl.old" -Force
Rename-Item -Path "$sysWOW64Directory\curl.exe" -NewName "curl.old" -Force

# Initialize variables to store the paths of the new "curl.exe" files
$newCurlFile1 = $null
$newCurlFile2 = $null

# Loop through each folder in the "curlcapture" directory
foreach ($folder in Get-ChildItem -Path $curlCaptureFolder -Directory) {
    # Loop through each "curl.exe" file in the current folder
    foreach ($file in Get-ChildItem -Path $folder.FullName -Filter "curl.exe" -File) {
        # Get the hash of the current "curl.exe" file
        $fileHash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash

        # Compare the hash with the expected values
        if ($fileHash -eq $expectedValue1) {
            # Set the path of the new "curl.exe" file for System32
            $newCurlFile1 = $file.FullName
        }
        elseif ($fileHash -eq $expectedValue2) {
            # Set the path of the new "curl.exe" file for SysWOW64
            $newCurlFile2 = $file.FullName
        }
    }
}

# Copy the new "curl.exe" files to the appropriate directories
if ($newCurlFile1) {
    Copy-Item -Path $newCurlFile1 -Destination (Join-Path $system32Directory "curl.exe") -Force
    Write-Output "File copied and renamed: $($newCurlFile1) -> $($system32Directory)\curl.exe"
}
if ($newCurlFile2) {
    Copy-Item -Path $newCurlFile2 -Destination (Join-Path $sysWOW64Directory "curl.exe") -Force
    Write-Output "File copied and renamed: $($newCurlFile2) -> $($sysWOW64Directory)\curl.exe"
}
