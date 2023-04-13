Function ConvertFrom-UnixTime ($unixtime) {
    <#

        .DESCRIPTION
            Datetimes from JSON are stored as Unixtime. We need this funtion to convert it back as 'Human' time

        .EXAMPLE
            (ConvertFrom-UnixTime 1550504688).toString()
            Expected Output: "18/02/2019 15:44:48"
    #>
    #TODO Parameter validation of proper unixtime values
    
    if ( ($unixtime -ne -1) -and ($null -ne $unixtime) ) {
        $origin = New-Object -Type DateTime -ArgumenTlist 1970, 1, 1, 0, 0, 0, 0
        $datetime = $origin.AddSeconds($unixtime)
        Return $datetime
    } else {
        return $null
    }
}