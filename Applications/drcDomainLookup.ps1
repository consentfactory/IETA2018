$widaComputers = Get-ADComputer -Filter {Name -like "WIDAServer*"} -SearchBase "OU=TestingServers,OU=Servers,dc=contoso,dc=org"

foreach ($widaComputer in $widaComputers) {
    $widaComputer.name
    $web = Invoke-WebRequest -Uri "http://$($widaComputer.name).contoso.org:8080"
    $regex = [regex] "([a-zA-Z0-9]{8})(-legacy-prod.drc-centraloffice.com)"
    $replace0 = "<label class=`"control-label`"><strong>TSM Server Domain:</strong>"
    $replace1 = "</label>"
    (($web.Content.ToString() -split '\n' -replace $replace0,"" -replace $replace1,"" | Select-String $regex) | Out-String).Trim()
} 

<#
    $web = Invoke-WebRequest -Uri "http://widaserver01.contoso.org:8080"
    $regex = [regex] "([a-zA-Z0-9]{8})(-legacy-prod.drc-centraloffice.com)"
    $replace0 = "<label class=`"control-label`"><strong>TSM Server Domain:</strong>"
    $replace1 = "</label>"
    (($web.Content.ToString() -split '\n' -replace $replace0,"" -replace $replace1,"" | Select-String $regex) | Out-String).Trim()
#>