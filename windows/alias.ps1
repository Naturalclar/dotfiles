# Add Alias for which
Set-Alias -Name which -Value Get-Command

# Add Alias for touch
Set-Alias -Name touch -Value New-Item

# Add Alias for open
Set-Alias -Name open -Value Invoke-Item

# Add Alias to run PowerShell
Set-Alias -Name psh -Value pwsh

# Add Alias for git commands
Set-Alias -Name g -Value git
Function gst {
    git status    
}
Function gaa {
    git add --all
}
Function gcmm {
    git commit -m $args
}
Function gpull {
    git pull origin $args
}
Function get_current_branch {
    git branch --show-current
}
Function gpcb {
    git push origin $(get_current_branch) $args
}
Function gsc {
    git switch -c $args
}
Function gco {
    git switch $args
}
Function get_default_branch {
    git remote show origin | Select-String "HEAD branch" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }
}
Function gcod {
    # git switch to default branch
    git switch $(get_default_branch)
}
Function gsu {
    # git stash
    git stash -u
}
Function gdiff {
    # git diff
    git diff $args
}

# Add Alias for gh cli commands
Function ghview {
    # Open the current repository or specified repository in browser
    gh repo view -w $args
}

# Add alias for ghq + peco
Function ws {
    Set-Location $(ghq list --full-path | peco)
}

# Add alias for ghq clone
Function get {
    ghq get $args
}

# Add alias for nvim
Set-Alias -Name vim -Value nvim

# Add alias for terraform
Set-Alias -Name tf -Value terraform