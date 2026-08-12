# Link the komorebi window-manager configs into ~/.config.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

New-DotfilesLink -Path "$env:USERPROFILE\.config\komorebi.json" `
    -Target "$PSScriptRoot\.config\komorebi\.komorebi.json" | Out-Null
New-DotfilesLink -Path "$env:USERPROFILE\.config\komorebi.bar.json" `
    -Target "$PSScriptRoot\.config\komorebi\.komorebi.bar.json" | Out-Null
