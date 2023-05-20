
# Merges multiple PS1 files into a single PSM1 file
# 
# https://evotec.xyz/powershell-single-psm1-file-versus-multi-file-modules/

#TODO Add Public and Private folders
#TODO 

# Another Article to check out
# https://mikefrobbins.com/2018/11/01/powershell-script-module-design-building-tools-to-automate-the-process/
# https://github.com/mikefrobbins/ModuleBuildTools

# https://gist.github.com/Jaykul/176c4aacc477a69b3d0fa86b4229503b
# 
function Merge-Module {
    param (
        [string] $ModuleName,
        [string] $ModulePathSource,
        [string] $ModulePathTarget
    )
    $ScriptFunctions = @( Get-ChildItem -Path $ModulePathSource\*.ps1 -ErrorAction SilentlyContinue -Recurse )
    $ModulePSM = @( Get-ChildItem -Path $ModulePathSource\*.psm1 -ErrorAction SilentlyContinue -Recurse )
    foreach ($FilePath in $ScriptFunctions) {
        $Results = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
        $Functions = $Results.EndBlock.Extent.Text
        $Functions | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
    }
    foreach ($FilePath in $ModulePSM) {
        $Content = Get-Content $FilePath
        $Content | Add-Content -Path "$ModulePathTarget\$ModuleName.psm1"
    }
    Copy-Item -Path "$ModulePathSource\$ModuleName.psd1" "$ModulePathTarget\$ModuleName.psd1"
}