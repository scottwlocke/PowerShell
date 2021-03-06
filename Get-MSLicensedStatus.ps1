
# https://docs.microsoft.com/en-us/previous-versions/windows/desktop/sppwmi/softwarelicensingproduct
# There are quite a few properties and methods that could be utilized
Function Get-MSLicensedStatus {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [Alias("Name")]
        [ValidateNotNullorEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    Begin {
        #Fallback option to DCOM if WSMAN not configured
        $Opt = New-CimSessionOption -Protocol Dcom
        #Needed for the Try Catch when making WSMAN and DCOM connections
        $SessionParams = @{
            ErrorAction = 'Stop'
        }
        #Check if a Credential was sent in
        If ($PSBoundParameters['Credential']) {
            $SessionParams.Credential = $Credential
        }

        enum Licensestatus {
            Unlicensed = 0
            Licensed = 1
            OOBGrace = 2
            OOTGrace = 3
            NonGenuineGrace = 4
            Notification = 5
            ExtendedGrace = 6
        }

    }

    Process {
        foreach ($Computer in $ComputerName) {
            $SessionParams.ComputerName = $Computer
            if ((Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue).productversion -match 'Stack: ([3-9]|[1-9][0-9]+)\.[0-9]+') {
                try {
                    Write-Verbose -Message "Attempting to connect to $Computer using the WSMAN protocol."
                    $Session = New-CimSession @SessionParams
                }
                catch {
                    Write-Warning -Message "Unable to connect to $Computer using the WSMAN protocol. Verify your credentials and try again."
                }
            }

            else {
                #Change from a WSMAN connection to DCOM
                $SessionParams.SessionOption = $Opt

                try {
                    Write-Verbose -Message "Attempting to connect to $Computer using the DCOM protocol."
                    $Session = New-CimSession @SessionParams
                }
                catch {
                    Write-Warning -Message "Unable to connect to $Computer using the WSMAN or DCOM protocol. Verify $Computer is online and try again."
                }
            }
            # Pull license information from CIMSession
            Get-CimInstance -CimSession $Session -ClassName SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" | Select-Object Name, ApplicationId, @{N = 'LicenseStatus'; E = {[LicenseStatus]$_.LicenseStatus} }
            Remove-CimSession -CimSession $Session -ErrorAction SilentlyContinue
            #Clear Decom Flag
            $SessionParams.Remove('SessionOption')
        }
    }
}
