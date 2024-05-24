# create symbolic link for komorebi config file

$configDir = "$env:USERPROFILE\.komorebi.json"

New-Item -ItemType SymbolicLink -Path $configDir -Value $PSScriptRoot\.komorebi.json

