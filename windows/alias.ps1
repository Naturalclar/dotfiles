# Add Alias for which
Set-Alias -Name which -Value Get-Command

# Add Alias for touch
Set-Alias -Name touch -Value New-Item

# Add Alias to run PowerShell
Set-Alias -Name psh -Value powershell.exe

# Add Alias for git commands
Set-Alias -Name g -Value git
Function gst {
    git status    
}
