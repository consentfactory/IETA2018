<#
.SYNOPSIS
    Creates SCCM boundaries based on DHCP scope information
.DESCRIPTION
    Script gets DHCP server listing from AD, captures each scope into a variable,
    and then creates SCCM boundaries based on the scopes.
    ** Requires AD and SCCM modules to be loaded **
.INPUTS
    All internal (to script) inputs.
.OUTPUTS
    None
.NOTES
    Version:    	  1.0
    Author:     	  Jimmy Taylor
    Creation Date:    2018.02.08
    Purpose/Change:   Adding documentation to script
#>

# Get DHCP servers from AD. Could probably remove "| Format-Wide | Out-String" and paratheses since
# ".trim()" should take care of it. Can't do it now as I comment this (not currently in testing environment)
$dhcpServers = Get-DhcpServerInDC | ForEach-Object {($_.dnsname | Format-Wide | Out-String).trim()}

# For each DHCP server in the variable $dhcpServers
foreach ($dhcpServer in $dhcpServers) {
    # Write-Host is just style preference for output
    Write-Host "*"
    Write-Host "*"
    # Display current DHCP server
    Write-Host $dhcpServer
    # Get DHCP scopes
    $scope = Get-DhcpServerv4Scope -ComputerName $dhcpServer | where {$_.ScopeId -like "192.*.99.0*"}
    # Create boundaries based on DHCP scopes
    New-CMBoundary -Name $($scope.Name) -Type IPRange -Value "$($scope.StartRange)-$($scope.EndRange)" -Verbose
    Write-Host "*"
    Write-Host "*"
}