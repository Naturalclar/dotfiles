# Link the Neovim config into %LOCALAPPDATA%.
. "$PSScriptRoot\powershell\DotfilesSetup.ps1"

New-DotfilesLink -Path "$env:USERPROFILE\AppData\Local\nvim" -Target "$PSScriptRoot\.config\nvim" | Out-Null
