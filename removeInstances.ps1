#Used when I was remediating machines, sometimes there were multiple instances of a file, like a .jar, that was used by a program. Sometimes these files were located in backups, which contained project info. Instead of wiping, would only delete vulnerable files.
$path = "\Directory\to\Clean\"

$filePurge = (Get-ChildItem $path -Recurse *filter file name*)

foreach ($file in $filePurge) {
  Write-Host $file
  Remove-Item -Path $file.FullName
  Write-Host "All files have been removed.
}
