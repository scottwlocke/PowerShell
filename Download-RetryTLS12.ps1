# Downloading a file, retrying if TLS 1.2 is required

Try {
    Invoke-WebRequest -Uri 'https://somewebsite.com/somfile.zip' -OutFile $env:userprofile\Downloads\somefile.zip
}
Catch [System.Net.WebException] {
    # SecurityProtocol for the local PowerShell session will be updated to access TLS 1.2 and try download again.
    $secProtocol = [Net.ServicePointManager]::SecurityProtocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://somewebsite.com/somfile.zip' -OutFile $env:userprofile\Downloads\somefile.zip
    # Be nice set it back to waht it was before we changed it
    [Net.ServicePointManager]::SecurityProtocol = $secProtocol
}
