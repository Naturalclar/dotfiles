# create directory for init.vim if it doesn't exist

$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"

if (-not (Test-Path $nvimDir)) {
    New-Item -ItemType Directory -Path $nvimDir
}

# create symbolic link to init.vim

$initVim = "$nvimDir\init.vim"

if (-not (Test-Path $initVim)) {
    New-Item -ItemType SymbolicLink -Path $initVim -Value $PSScriptRoot\.config\nvim\init.vim
}