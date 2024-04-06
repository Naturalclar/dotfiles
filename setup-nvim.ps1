# create symbolic link for nvim config directory

$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"

New-Item -ItemType SymbolicLink -Path $nvimDir -Value $PSScriptRoot\.config\nvim

