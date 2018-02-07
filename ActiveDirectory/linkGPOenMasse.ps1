<#
.SYNOPSIS
  Links a GPO to a an OU
.DESCRIPTION
  Links a group policy object to an OU in Active Directory
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2018.02.03
  Purpose/Change:   Initial script development
#>

# Specify server for Active Directory transactions (improves performance of actions)
$server = "dc01.contoso.org"

# Get all first level OUs within an OU
$ous = Get-ADOrganizationalUnit -SearchBase "OU=School,DC=contoso,DC=org" -Filter * -SearchScope OneLevel

# For each OU in varible $OUs
foreach ($ou in $ous) {
    # Write out the OU object we're working with
    Write-Host $ou.name

    # Link a GPO to the OU object we're currently working with
    New-GPLink -name "Lightspeed Proxy PAC" -Target "OU=Devices,$($ou.DistinguishedName)" -LinkEnabled Yes -Verbose -server $server -whatif

    # Remove GPO link from OU
    #Remove-GPLink -name "Lightspeed Proxy PAC" -Target "OU=Devices,$($ou.DistinguishedName)"
}