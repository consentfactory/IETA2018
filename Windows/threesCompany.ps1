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