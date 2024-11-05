# create symbolic link for komorebi config file

$whkdrcDir = "$env:USERPROFILE\.config\whkdrc"


New-Item -ItemType SymbolicLink -Path $whkdrcDir -Value $PSScriptRoot\.config\whkdrc
