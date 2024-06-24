# create symbolic link for yasb config file

$configDir = "$env:USERPROFILE\.yasb"

New-Item -ItemType SymbolicLink -Path $configDir -Value $PSScriptRoot\.yasb

