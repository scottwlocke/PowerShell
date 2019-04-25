function get-CIMRegValue{             
[CmdletBinding(DefaultParameterSetName="UseComputer")]             
            
param (             
 [parameter(Mandatory=$true)]            
 [ValidateSet("HKCR", "HKCU", "HKLM", "HKUS", "HKCC")]            
 [string]$hive,            
            
 [parameter(Mandatory=$true)]            
 [string]$key,            
            
 [parameter(Mandatory=$true)]            
 [string]$value,            
            
 [parameter(Mandatory=$true)]            
 [string]            
 [Validateset("DWORD", "EXPANDSZ", "MULTISZ", "QWORD", "SZ")]            
 $type,            
            
  [parameter(ValueFromPipeline=$true,            
   ValueFromPipelineByPropertyName=$true)]            
 [parameter(ParameterSetName="UseComputer")]             
 [string]$computer="$env:COMPUTERNAME",            
             
 [parameter(ValueFromPipeline=$true,            
   ValueFromPipelineByPropertyName=$true)]            
 [parameter(ParameterSetName="UseCIMSession")]             
 [Microsoft.Management.Infrastructure.CimSession]$cimsession            
             
)             
BEGIN{}#begin             
PROCESS{            
            
switch ($hive){            
"HKCR" { [uint32]$hdkey = 2147483648} #HKEY_CLASSES_ROOT            
"HKCU" { [uint32]$hdkey = 2147483649} #HKEY_CURRENT_USER            
"HKLM" { [uint32]$hdkey = 2147483650} #HKEY_LOCAL_MACHINE            
"HKUS" { [uint32]$hdkey = 2147483651} #HKEY_USERS            
"HKCC" { [uint32]$hdkey = 2147483653} #HKEY_CURRENT_CONFIG            
}            
            
switch ($type) {            
"DWORD"     {$methodname = "GetDwordValue"}            
"EXPANDSZ"  {$methodname = "GetExpandedStringValue"}            
"MULTISZ"   {$methodname = "GetMultiStringValue"}            
"QWORD"     {$methodname = "GetQwordValue"}            
"SZ"        {$methodname = "GetStringValue"}            
}            
$arglist = @{hDefKey = $hdkey; sSubKeyName = $key; sValueName = $value}            
            
switch ($psCmdlet.ParameterSetName) {            
 "UseComputer"    {$result = Invoke-CimMethod -Namespace "root\cimv2" -ClassName StdRegProv -MethodName $methodname  -Arguments $arglist -ComputerName $computer}            
 "UseCIMSession"  {$result = Invoke-CimMethod -Namespace "root\cimv2" -ClassName StdRegProv -MethodName $methodname  -Arguments $arglist -CimSession $cimsession }            
 default {Write-Host "Error!!! Should not be here" }            
}            
            
switch ($type) {            
"DWORD"     {$result | select -ExpandProperty uValue}            
"EXPANDSZ"  {$result | select -ExpandProperty sValue}            
"MULTISZ"   {$result | select -ExpandProperty sValue}            
"QWORD"     {$result | select -ExpandProperty uValue}            
"SZ"        {$result | select -ExpandProperty sValue}            
}            
             
}#process             
END{}#end            
            
<# 
.SYNOPSIS
Displays a registry value

.DESCRIPTION
Displays a registry value using WSMAN or DCOM 
to access remote machines 

.PARAMETER  hive
Hive Name. One of "HKCR", "HKCU", "HKLM", "HKUS" or "HKCC"
The name is validated against the set

.PARAMETER  key
The registry key - without the hive name e.g.
"SYSTEM\CurrentControlSet\Services\BITS"

.PARAMETER value
The specific registry value to return for the 
given key

.PARAMETER  type
The type of registry value to return.
Must be one of
"DWORD", "EXPANDSZ", "MULTISZ", "QWORD", "SZ"

.PARAMETER  computer
Name of a remote computer. Connectivity will be by WSMAN.

.PARAMETER  cimsession
An object representing a cimsession. Connectivity is controlled 
by the CIM session and can be WSMAN or DCOM

.EXAMPLE                                                                                       
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value DelayedAutoStart -type DWORD

.EXAMPLE
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value ObjectName -type SZ  

.EXAMPLE
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value DependOnService -type MULTISZ 

.EXAMPLE
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value ImagePath -type EXPANDSZ

.EXAMPLE
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value DelayedAutoStart -type DWORD -computer "."

.EXAMPLE
$cs = New-CimSession -ComputerName Win7test  
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value DelayedAutoStart -type DWORD -cimsession $cs   

.EXAMPLE
$opt = New-CimSessionOption -Protocol Dcom                                                                                                          
$csd = New-CimSession -ComputerName server02 -SessionOption $opt                                                                                    
get-CIMRegValue -hive HKLM -key "SYSTEM\CurrentControlSet\services\BITS" -value DelayedAutoStart -type DWORD -cimsession $csd

.NOTES


.LINK

#>            
            
}