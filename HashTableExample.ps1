
$hash = $null
# Create an empty Hash Table to store values
$hash = @{}

$processes = get-process | Sort-Object -Property name -Unique
# Add process name and PID to table
foreach ($process in $processes) { $hash.add($process.name, $process.id)}