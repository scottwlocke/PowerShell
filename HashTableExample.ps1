
$hash = $null
# Create an empty Hash Table to store values
$hash = @{}

$processes = get-process | Sort-Object -Property name -Unique
# Add process name and PID to table
foreach ($process in $processes) { $hash.add($process.name, $process.id)}

# Useful for when a lot of paramters need to be used and readability suffers
# Run msiexec as an admin minimized, wait for completion specify working dir
# Pass ArguementLIst parameters to the MSI specified
$InstallerArgs = @{
    FilePath = 'msiexec.exe'
    ArgumentList = @(
        '/i',
        'C:\Files\Installer.msi',
        "/qb!",
        "/norestart",
        "/l*v",
        '"C:\Temp\Application_install_log.log"'
    )
    Wait = $True
    WorkingDirectory = "C:\Temp"
    WindowStyle = "Minimized"
    Verb = "RunAs"
}
Start-Process @InstallerArgs