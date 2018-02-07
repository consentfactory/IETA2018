<#
createDRCApplicationUsers.ps1
Created 20171220
Created by Jimmy Taylor

.SYNOPSIS
Script that creates unique DRC application for the user account assigned
to each specfiic school.

.DESCRIPTION
The DRC application requires that each device at each specific school be
configured with unique IDs for reporting to central servers. 

CreateDRCApplicationUsers.ps1 ingests the school name and school ID from
the CSV, then builds the SCCM application, deployment type, and the 
application deployment to specific user collections. The script then 
distributes the content to a distribution point group, thereby completing
the task for deploying the application to specific users for specific
schools.

The design of this deployment requires testing user accounts be part of
school-specific SCCM collections.

Requires SCCM 1706+.

#>

# Import CSV File. CSV file should have "location" and "id" headers
$schools = Import-CSV -Path Filesystem::\\server\someplace$\locations.csv

# Loop through the CSV for each school
foreach ($school in $schools) {
    # Set WhatifPreference to $false if not testing
    $WhatIfPreference = $true
    # Setting to verbose when testing. Comment out when in production.
    $VerbosePreference = "Continue"
   
    # CSV Variables
    $schoolLocation = $school.location
    $schoolID = $school.id
    $schoolUserCollection = "WIDA $($schoolLocation) User"
    
    # General Variables
    $name = "DRC WIDA Secure Browser 8.0 for $($schoolLocation)"
   
    # Application Variables
    $appName = $name
    $appDescription = "2017-18 DRC WIDA Test Client for $($schoolLocation)"
    $appVersion = "8.0.0.171"
    
    # Software Center-Specific Variables
    $scDescription = "2017-18 DRC WIDA Test Client for $($schoolLocation)"
    $sclinkText = "DRC Insight - Secure Browser Test Application"
    $scIconFile = "\\sccmPrimaryServer.contoso.org\sources\Apps\DRC\8.0\DRCInsight_130.ico"
    $publisher = "Data Recognition Corporation"
    $releaseDate = "2017.06.27"
   
    # Deployment Type-Specific Variables
    $dtName = "$($name) Deployment"
    $dtMsiFile = "\\sccmPrimaryServer.contoso.org\Sources\Apps\DRC\8.0\drc_insight_setup.msi"
    $dtInstallerConfig = "msiexec /i `"drc_insight_setup.msi`" OU_IDS=`"$($schoolID)`" /qn"
    $dtUninstallerConfig = "msiexec /x `"drc_insight_setup.msi`" /qn"
    $dtComments = "Created $(Get-Date -format yyyyMMdd.HHmm) by $($env:UserName)"
    $dtProductCode = "A56BB305-2C33-4F21-96D8-B0C8773DF48D"
    
    # Content Distribution Variables
    $cdAppName = $appName
    $cdDistPtGroup = "All DPs"
    
    # Application Deployment Variables
    $dCollection = "WIDA $($schoolLocation) User"
    $dAppName = $appName
    $dAvailDateTime = Get-Date
    $dComment = $appDescription
    
    # Create the Application
    New-CMApplication `
        -Name $appName `
        -Description $appDescription `
        -LinkText $linkText `
        -LocalizedApplicationDescription "$appDescription localizedAppDesc" `
        -LocalizedApplicationName "$name localizedAppName" `
        -Manufacturer $publisher `
        -ReleaseDate $releaseDate `
        -IconLocationFile $scIconFile `
        -SoftwareVersion $appVersion `
    
    # Create the deployment type for the SCCM application to use
    Add-CMMsiDeploymentType `
        -ApplicationName $appName `
        -InstallCommand $dtInstallerConfig `
        -UninstallCommand $dtUninstallerConfig `
        -DeploymentTypeName $dtName `
        -InstallationFileLocation $dtMsiFile `
        -Comment $dtComments `
        -EnableBranchCache `
        -InstallationProgramVisibility Hidden `
        -InstallationBehaviorType InstallForUser `
        -ProductCode $dtProductCode `
        -Force
    
    # Create an application deployment to the user collection
    New-CMApplicationDeployment `
        -ApplicationName $appName `
        -CollectionName $dCollection `
        -Comment $dComment `
        -AvailableDateTime $dAvailDateTime `
        -DistributionPointGroupName $cdDistPtGroup `
        -DeployAction Install `
        -DeployPurpose Required `
        -UserNotification HideAll `
        -OverrideServiceWindow $true `
        -DistributeContent
    <#
    Uncomment this section when testing is complete

    # Distributes the content to the distribution point group
    Start-CMContentDistribution `
        -ApplicationName $appName `
        -DistributionPointGroupName $cdDistPtGroup
        
    #>
}
