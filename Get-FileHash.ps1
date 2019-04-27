<#
.SYNOPSIS Create MD5, SHA1, SHA256 or SHA512 hashes for one or more files.

.DESCRIPTION Outputs the hash and filename

.PARAMETER Path Specifies the path to one or more files. Wildcards are permitted.

.PARAMETER HashType The hash type to compute; either MD5, SHA1, SHA256 or SHA512.
The default is MD5.

.OUTPUTS Object with file paths and hash values

.EXAMPLE PS C:\> Get-FileHash C:\Windows\Notepad.exe
Outputs the MD5 hash for the specified file.

.EXAMPLE
PS C:\> Get-ChildItem C:\Scripts\*.ps1 | Get-FileHash
Outputs the MD5 hash for the specified files.
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $TRUE, ValueFromPipeline = $TRUE)]
    [String[]] $Path,
    [Parameter(Position = 1)]
    [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA512')]
    [String] $HashType = "MD5"
)

begin {
    $ProviderType = $HashType + "CryptoServiceProvider"
    $Provider = new-object System.Security.Cryptography.$ProviderType
}

process {
    $file = get-item -path $Path
    if ($file -isnot [System.IO.FileInfo]) {
        write-error "'$($file)' is not a file."
        return
    }
    $hashstring = new-object System.Text.StringBuilder
    $stream = $file.OpenRead()
    if ($stream) {
        foreach ($byte in $Provider.ComputeHash($stream)) {
            [Void] $hashstring.Append($byte.ToString("X2"))
        }
        $stream.Close()
    }
    "" | select-object @{Name = "Path"; Expression = { $file.FullName } },
    @{Name         = "$($Provider.GetType().BaseType.Name) Hash";
        Expression = { $hashstring.ToString() }
    }
}