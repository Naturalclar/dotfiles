# create symbolic link for nvim config directory

$configDir = "$env:USERPROFILE\.wezterm.lua"

New-Item -ItemType SymbolicLink -Path $configDir -Value $PSScriptRoot\.wezterm.lua

