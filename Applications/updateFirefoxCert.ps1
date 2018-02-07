<#
.SYNOPSIS
    Replaces Firefox certificate DB in each profile user profile
.DESCRIPTION
    #This script checks for a text file's existence, and if does not exist,
    copies the cert8.db file to each profile for each user on the computer.
    If file exists, script notes that it's not needed and moves on.
.INPUTS
    None
.OUTPUTS
    C:\Windows\CCM\Logs\firefoxUpdated2.txt
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2017.01.18
  Purpose/Change:   Initial script development
 
#>

$date = Get-Date
$fileCheck = 'C:\Windows\CCM\Logs\firefoxUpdated2.txt'
#Test for file's existence
if (Test-Path $fileCheck) {
    #If file exists, notes that update is not needed.
    $fileUpdate = "No certificate update needed -- $($date)" 
    $fileUpdate | Add-Content 'C:\Windows\CCM\Logs\firefoxUpdated2.txt'
} else {
    #If file does not exist, script looks for each profile in user appdata, renames cert8.db with .old extension, then copies updated cert8.db file
    $profiles = "C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\"
    Get-ChildItem $profiles -Recurse -Include *cert8.db | ForEach-Object {Rename-Item $_ cert8.db.old; Copy-Item -Path "\\server.contoso.org\firefoxCertificates\cert8.db" -Destination $_}
    #If script is successful, script creates file.
    $fileUpdate = "Firefox Certificate Updated -- $($date)"
    $fileUpdate | Set-Content 'C:\Windows\CCM\Logs\firefoxUpdated2.txt'
}