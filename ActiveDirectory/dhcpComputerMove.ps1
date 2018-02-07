<#
.SYNOPSIS
Script that moves devices from computers container and/or base devices OU 
to their appropriate OU based on IP address.
.DESCRIPTION
dhcpComputerMove.ps1 first creates a CSV table for logging purposes.
Next, script gets DHCP servers from domain controllers, then polls for all 
DHCP scopes. The script then reads each DHCP lease and obtains their hostname,
stripping the domain name. Next, the script checks the hostname to see if
there is a computer object in the Computers container or the Devices OU at
the base of the main OU structure, and what IP address the device currently
has. If the object is in the wrong location, the script moves the object to 
a different location.
.INPUTS
  Internal to script. Grabs DHCP servers from Active Directory
.OUTPUTS
  dhcpComputerMove.csv - table that contains computer objects that have been moved
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2017.02.24
  Purpose/Change:   Added comments
#>

# Create table for later use
$tabName = "List of Computers in Computers CN"
$table = New-Object system.Data.DataTable “$tabName”
$col1 = New-Object system.Data.DataColumn Hostname,([string])
$col2 = New-Object system.Data.DataColumn IPAddress,([string])
$col3 = New-Object system.Data.DataColumn Location,([string])
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)

# Get DHCP servers from DNS
$dhcpServers = (Get-DhcpServerInDC).DNSName

# Go through each DHCP server and look at all leases in all scopes
foreach ($dhcpServer in $dhcpServers) {
    $DHCPLeases = Get-DhcpServerv4Scope -ComputerName $dhcpServer | Get-DhcpServerv4Lease -AllLeases -ComputerName $dhcpServer
  
    # For each lease, clean up hostname
    foreach ($dhcp in $DHCPLeases) {
        $computer = $dhcp.hostname -replace ".contoso.org$",""
        
        # Get AD computer information and determine location in AD
        Try {
            $adComputer = Get-ADComputer $computer -ErrorAction Ignore
            # If device is in wrong location and has IP address for a particular site, move the object
            # Better method: use switch() -- for next update. 
            if ( 
                (($adComputer.DistinguishedName -like "*CN=Computers,DC=contoso,DC=org") -or ($adComputer.DistinguishedName -like "*OU=Devices,OU=contoso,DC=contoso,DC=org")) `
                -and `
                ($dhcp.ipaddress -like "10.10.*")
            ){
                Move-ADObject $adComputer.DistinguishedName `
                    -TargetPath "OU=Devices,OU=Location1,OU=contoso,DC=contoso,DC=org" `
                    -server "addc01.contoso.org" -verbose
                    # Create new row in the CSV table with the hostname, IP, and location info
                    $row=$table.NewRow()
                    $a="Location 1"
                    $row.Hostname=$dhcp.hostname
                    $row.IPAddress=$dhcp.ipaddress
                    $row.Location=$a
                    $table.Rows.Add($row)
            }
            if (
                (($adComputer.DistinguishedName -like "*CN=Computers,DC=contoso,DC=org") -or ($adComputer.DistinguishedName -like "*OU=Devices,OU=contoso,DC=contoso,DC=org")) `
                -and `
                ($dhcp.ipaddress -like "10.10.*")
            ){
                Move-ADObject $adComputer.DistinguishedName `
                    -TargetPath "OU=Devices,OU=Location2,OU=contoso,DC=contoso,DC=org" `
                    -server "addc01.contoso.org" -verbose
                    # Create new row in the CSV table with the hostname, IP, and location info
                    $row=$table.NewRow()
                    $a="Location 2"
                    $row.Hostname=$dhcp.hostname
                    $row.IPAddress=$dhcp.ipaddress
                    $row.Location=$a
                    $table.Rows.Add($row)
            }
        } Catch {
            # Because not DHCP leases will be AD objects, we're ignoring what would otherwise be terminating errors
            if (($_.Exception.Message -like "Cannot find an object with identity*") -or ($_.Exception.Message -like "Cannot validate argument on parameter 'Identity'*")){
                $_.Exception.Message | Out-Null
            }
            else {$_.Exception.Message}
        }
    }
}
# Output the table to a log
$table | export-csv C:\temp\dhcpComputerMove.csv