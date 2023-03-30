
# Write a funtion that retrieves the installed TLS protocols on a system
$t = [System.Net.ServicePointManager]::SecurityProtocol 



# Retrieve Installed Protocols
([System.Enum]::GetNames([System.Net.SecurityProtocolType]))

<#  Example Output

SystemDefault
Ssl3
Tls
Tls11
Tls12
Tls13

#>