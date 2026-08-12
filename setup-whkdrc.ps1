# Link the whkd hotkey config into ~/.config.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

New-DotfilesLink -Path "$env:USERPROFILE\.config\whkdrc" -Target "$PSScriptRoot\.config\whkdrc" | Out-Null
