# Link the WezTerm config into the home directory.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

New-DotfilesLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "$PSScriptRoot\.wezterm.lua" | Out-Null
