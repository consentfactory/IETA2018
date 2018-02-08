<#
.SYNOPSIS
  Demonstrates changing advanced property in NetAdapter
.DESCRIPTION
  Demonstrates changing advanced property in NetAdapter
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:    	    1.0
  Author:     	    <Name>
  Creation Date:    <Date>
  Purpose/Change:   Initial script development
#>

# Examples of getting help for cmdlets. 
help Set-NetAdapterAdvancedProperty -full
help Get-NetAdapterAdvancedProperty -full

# Get properties, methods, and so forth for an advanced property with the network adapter
Get-NetAdapterAdvancedProperty -Name Ethernet -DisplayName "Jumbo Frame" | Get-Member

# Sets jumbo frame property for ethernet network adapter; set to 'whatif' for testing
Set-NetAdapterAdvancedProperty -Name Ethernet -DisplayName "Jumbo Frame" -DisplayValue "{9000}" -WhatIf