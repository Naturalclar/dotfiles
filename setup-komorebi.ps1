# create symbolic link for komorebi config file

$configDir = "$env:USERPROFILE\.config\komorebi.json"
$barConfigDir = "$env:USERPROFILE\.config\komorebi.bar.json"

New-Item -ItemType SymbolicLink -Path $configDir -Value $PSScriptRoot\.config\komorebi\.komorebi.json
New-Item -ItemType SymbolicLink -Path $barConfigDir -Value $PSScriptRoot\.config\komorebi\.komorebi.bar.json

