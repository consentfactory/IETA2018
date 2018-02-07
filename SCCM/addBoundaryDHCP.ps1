$dhcpServers = Get-DhcpServerInDC | ForEach-Object {($_.dnsname | Format-Wide | Out-String).trim()}
foreach ($dhcpServer in $dhcpServers) {
    Write-Host "*"
    Write-Host "*"
    Write-Host $dhcpServer
    $scope = Get-DhcpServerv4Scope -ComputerName $dhcpServer | where {$_.ScopeId -like "192.*.99.0*"}
    New-CMBoundary -Name $($scope.Name) -Type IPRange -Value "$($scope.StartRange)-$($scope.EndRange)" -Verbose
    Write-Host "*"
    Write-Host "*"
}