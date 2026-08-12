# Link the yasb status-bar config into the home directory.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

New-DotfilesLink -Path "$env:USERPROFILE\.yasb" -Target "$PSScriptRoot\.yasb" | Out-Null
