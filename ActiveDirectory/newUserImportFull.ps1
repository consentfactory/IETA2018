<#
.SYNOPSIS
  Creates Users from CSV File
.DESCRIPTION
  Creates Users from CSV File based on locations.
  Early version. Probably could be better, but haven't worked on this in awhile. 
.INPUTS
  None
.OUTPUTS
  Log file stored as transcript at C:\adimport\userImport-(date).log
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2015.03.17
  Purpose/Change:   Changed format of documentation
#>

# Start Transcript of userImport Script
$logFile = Get-Date -Format yyyyMMdd-HHmm
Start-Transcript -path C:\adimport\userImport-$logfile.log

# Set up some global variables
$esOU = "OU=Students,OU=ES,OU=User Accounts,DC=contoso,DC=org"
$msOU = "OU=Students,OU=MS,OU=User Accounts,DC=contoso,DC=org"
$hsOU = "OU=Students,OU=HS,OU=User Accounts,DC=contoso,DC=org"
$schoolDomain = "@contoso.org"


# Import Users
$usersCSV = Import-Csv "C:\adimport\accountsTest1.csv" | Select-Object `
                @{name='name';expression={$_.'ID'}}, `
                @{name='samAccountName';expression={$_.'ID'}}, `
                @{name='displayName';expression={$_.'Name:First'+' '+$_.'Name:Last'}}, `
                @{name='givenName';expression={$_.'Name:First'}}, `
                @{name='surName';expression={$_.'Name:Last'}}, `
                @{name='description';expression={$_.'Enrollment Status'}}, `
                @{name='office';expression={$_.'Grade Level'}}

# For the accounts in $userCSV
ForEach ($user in $usersCSV)
{
    # Check and see if account exists
    $userexists = $(try {Get-ADUser $user.samAccountName} catch {$null})  
    If ($userexists -eq $null) {

        # Create integer grade level for comparing
        if ($user.office -eq "KG" -or $user.office -eq "PK" -or $user.office -eq "") {} 
        else {
            [int]$grade = [convert]::ToInt32($user.office)
        }

        # If account does not exist, create the accounts

        # If Grade level is  PK, KG, or blank, do nothing; originally created accounts, but disabled this
        if ($user.office -eq "KG" -or $user.office -eq "PK" -or $user.office -eq "") {
            <#New-ADUser `
            -Name $user.name `
            -SamAccountName $user.samAccountName `
            -UserPrincipalName "$($user.name)$($schoolDomain)" `
            -DisplayName $user.displayName `
            -Surname $user.surName `
            -GivenName $user.givenName `
            -Description $user.description `
            -Office $user.office `
            -Enabled $True `
            -AccountPassword $(ConvertTo-SecureString $user.name -AsPlainText -Force) `
            -Path $esOU `
            -PassThru #| Out-Null
            #>
        }
        # Accounts for Elementary School
        elseif ($grade -lt 6) {
            New-ADUser `
            -Name $user.name `
            -SamAccountName $user.samAccountName `
            -UserPrincipalName "$($user.name)$($schoolDomain)" `
            -DisplayName $user.displayName `
            -Surname $user.surName `
            -GivenName $user.givenName `
            -Description $user.description `
            -Office $user.office `
            -Enabled $True `
            -AccountPassword $(ConvertTo-SecureString $user.name -AsPlainText -Force) `
            -Path $esOU `
            -PassThru #| Out-File C:\adimport\adimport.log
        }
        # Accounts for Middle School
        elseif ($grade -ge 6 -and $grade -lt 9) {
            New-ADUser `
            -Name $user.name `
            -SamAccountName $user.samAccountName `
            -UserPrincipalName "$($user.name)$($schoolDomain)" `
            -DisplayName $user.displayName `
            -Surname $user.surName `
            -GivenName $user.givenName `
            -Description $user.description `
            -Office $user.office `
            -Path $msOU `
            -Enabled $True `
            -AccountPassword $(ConvertTo-SecureString $user.name -AsPlainText -Force) `
            -PassThru #| Out-File C:\adimport\adimport.log
        }
        # Accounts for High School
        elseif ($grade -ge 9) {
            New-ADUser `
            -Name $user.name `
            -SamAccountName $user.samAccountName `
            -UserPrincipalName "$($user.name)$($schoolDomain)" `
            -DisplayName $user.displayName `
            -Surname $user.surName `
            -GivenName $user.givenName `
            -Description $user.description `
            -Office $user.office `
            -Enabled $True `
            -AccountPassword $(ConvertTo-SecureString $user.name -AsPlainText -Force) `
            -Path $hsOU `
            -PassThru #| Out-File C:\adimport\adimport.log
        }
       }
    else {
        # If account does exist, modify the account
        
        # Change name of account name in AD if necessary
        $userName = (Get-ADUser $($user.samAccountName)).name
        $userDN = (Get-ADUser $($user.samAccountName)).distinguishedName
        if ($userName -ne $user.samAccountName) {
            Rename-ADObject -identity $userDN -Newname $user.samAccountName
        }

        # Change other properties
        Set-ADUser -Identity $user.samAccountName -Description $user.description -Office $user.office

        # Create integer grade level for comparing
        if ($user.office -eq "KG" -or $user.office -eq "PK" -or $user.office -eq "") {
        } else {
            [int]$grade = [convert]::ToInt32($user.office)
        }

        # Move accounts to correct OUs if necessary

        # Get Current OU Path
        # This part could be a problem in the future if the account names are longer than 10 characters
        $ouPath = Get-ADUser $user.samAccountName | select -expand DistinguishedName
        $ou = $ouPath.substring(10)

        # Accounts for Elementary School
        if ($user.office -eq "KG" -or $user.office -eq "PK" -or $user.office -eq "") {
            #Set-ADUser -Identity $user.samAccountName -Enabled $false
            #if ($ou -ne $esOU) {
            #    Get-ADUser $user.samAccountName | Move-ADObject -TargetPath $esOU | Out-Null
            #}
        }
        elseif ($grade -lt 6) {
            if ($ou -ne $esOU) {
                Get-ADUser $user.samAccountName | Move-ADObject -TargetPath $esOU
            }
        }
        # Accounts for Middle School
        elseif ($grade -ge 6 -and $grade -lt 9) {
            if ($ou -ne $msOU) {
                Get-ADUser $user.samAccountName | Move-ADObject -TargetPath $msOU
            }
        }
        # Accounts for High School
        elseif ($grade -ge 9) {
            if ($ou -ne $hsOU) {
                Get-ADUser $user.samAccountName | Move-ADObject -TargetPath $hsOU
            }
        }
    }
}

# Delete Transcript Files Older Than 30 Days
$now = Get-Date
$days = "30"
$logFolder = "C:\adimport"
$lastWrite = $now.AddDays(-$days)
$logs = Get-ChildItem $logFolder -include "*.log" -Recurse | Where {$_.LastWriteTime -le "$lastWrite"}

foreach ($log in $logs) {
    if ($log -ne $null)
        {
        Remove-Item $log.FullName | Out-Null
        }
}

Stop-Transcript