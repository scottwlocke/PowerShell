
$acl = Get-ACL .\somefile.txt
$acl.SetOwner([System.Security.Principal.NTAccount]"ComputerName\Username")