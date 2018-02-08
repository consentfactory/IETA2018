<#
.SYNOPSIS
  Plays "Three's Company" theme song in IE.
.DESCRIPTION
  Runs "Three's Company" theme song in Internet Explorer.
  Used as prank. 
  Run this as scheduled task on co-workers computer with 'System' account.
  Then watch as "Come on knock on the door" commences. XD
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2018.02.08
  Purpose/Change:   Added comments
#>

# Run script as scheduled task in the background

# Create new object that is Internet Explorer
$ie = new-object -com "InternetExplorer.Application"

# Tell IE where to go
$ie.navigate("https://www.youtube.com/watch?v=-UNNkGvDp7g")

# Time for video to play
Start-Sleep -Seconds 30

# Lazily kill Process, assuming nothing else is using IE
# I really hope you're not using IE for anything import
Get-Process iexplore | Stop-Process