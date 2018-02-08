<#
.SYNOPSIS
  Grabs FQDNs
.DESCRIPTION
  Grabs FQDN from WIDA servers for reinstalls or new server deployments
.INPUTS
  All internal from AD. 
.OUTPUTS
  None
.NOTES
  Version:    	    1.0
  Author:     	    Jimmy Taylor
  Creation Date:    2018.02.03
  Purpose/Change:   Initial script development

#>

# Regular expression filter variable that looks for the beginning value to be
# any 8-character value with upper and/or lowercase letters, and the numbers
# 0-9, with "-legacy-prod.drc-centraloffice.com" attached
# Example: 11y2BN12-legacy-prod.drc-centraloffice.com
$regex = [regex] "([a-zA-Z0-9]{8})(-legacy-prod.drc-centraloffice.com)"

# These two variables are used to remove the HTML tags from the line 
$replace0 = "<label class=`"control-label`"><strong>TSM Server Domain:</strong>"
$replace1 = "</label>"

# Get each WIDA caching/response server from AD and store as array in $widaComputers
$widaComputers = Get-ADComputer -Filter {Name -like "WIDAServer*"} -SearchBase "OU=TestingServers,OU=Servers,dc=contoso,dc=org"

# For each WIDA server
foreach ($widaComputer in $widaComputers) {
  
  #Display server we're currently working on
  $widaComputer.name

  # Grab the webpage and store it in a variable
  $web = Invoke-WebRequest -Uri "http://$($widaComputer.name).contoso.org:8080"

  # Input the contents of the web, creating an object from the content base on
  # line breaks in the HTML. Using $regex, filter the content looking for an object
  # that matches the regular expression, delete the values of $replace0 
  # and $replace1, delete empty space created, and then display FQDN value
  (($web.Content.ToString() -split '\n' -replace $replace0,"" -replace $replace1,"" | Select-String $regex) | Out-String).Trim()
} 

# Instead of getting all values, this section is used for just getting value from a single server.
<#
# Grab the webpage and store it in a variable
$web = Invoke-WebRequest -Uri "http://widaserver01.contoso.org:8080"

# Input the contents of the web, creating an object from the content base on
# line breaks in the HTML. Using $regex, filter the content looking for an object
# that matches the regular expression, delete the values of $replace0 
# and $replace1, delete empty space created, and then display FQDN value
(($web.Content.ToString() -split '\n' -replace $replace0,"" -replace $replace1,"" | Select-String $regex) | Out-String).Trim()
#>