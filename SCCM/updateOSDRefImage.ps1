<#
.SYNOPSIS
  Updates OSD task sequences with new reference image
.DESCRIPTION
  Script will update the OSD images for task sequences of the category
  "Production" using the input values below. 
.INPUTS
  $refImagePkg - Package ID of the new reference image
  $reImageIndex - Index of the image to applied (usually "1", so no need to change)
.OUTPUTS
  None.
.NOTES
  Version:        1.0
  Author:         Jimmy Taylor
  Creation Date:  2018-01-22
  Purpose/Change: Initial script development
#>

# Get the reference image package object
$refImagePkg = Get-CMOperatingSystemImage -id PRI00099A
# Set the index number of the reference package
$regImageIndex = "1"

# Get each task sequence of the category "Production" and update the reference image
Get-CMTaskSequence | where {$_.category -eq "Production"} | foreach {
    Set-CMTaskSequenceStepApplyOperatingSystem -TaskSequenceId $_.PackageID -ImagePackage $refImagePkg -ImagePackageIndex $regImageIndex -WhatIf
}