# Link the AutoHotKey scripts into the Startup folder, so they run at login.
#
# Not called by install.ps1: whether these should start automatically is a
# choice, not part of setting the machine up. Run it yourself if you want them.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

$startup = [Environment]::GetFolderPath('Startup')

foreach ($script in Get-ChildItem -Path "$PSScriptRoot\ahk" -Filter *.ahk) {
    New-DotfilesLink -Path (Join-Path $startup $script.Name) -Target $script.FullName | Out-Null
}
