# create symbolic link for wezterm config file

$configDir = "$env:USERPROFILE\.wezterm.lua"

New-Item -ItemType SymbolicLink -Path $configDir -Value $PSScriptRoot\.wezterm.lua

