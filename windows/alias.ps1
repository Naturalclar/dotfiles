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
Function gpc {
    gh pr create
}

# Add alias for ghq + peco
Function ws {
    Set-Location $(ghq list --full-path | peco)
}

# Add alias for ghq clone
# TODO: get bare clone of repository
Function get {
    ghq get $args
}

# Add alias for nvim
# TODO: check if nvim exists before setting this alias
Set-Alias -Name vim -Value nvim

# Add alias for terraform
Set-Alias -Name tf -Value terraform

# Add alias for lazygit
Set-Alias -Name lg -Value lazygit

# Set envs for komorebi

$Env:KOMOREBI_CONFIG_HOME = "$Env:USERPROFILE\.config"

# Add aliases for pnpm commands
Set-Alias -Name p -Value pnpm
Set-Alias -Name pb -Value "pnpm build"
Set-Alias -Name ph -Value "pnpm start"
Set-Alias -Name pi -Value "pnpm install"
Set-Alias -Name add -Value "pnpm add"
Set-Alias -Name addd -Value "pnpm add -D"
Set-Alias -Name addg -Value "pnpm global add"
Set-Alias -Name lint -Value "pnpm lint"
Set-Alias -Name format -Value "pnpm format"
Set-Alias -Name tc -Value "pnpm type-check"
Set-Alias -Name type-check -Value "pnpm type-check"
Set-Alias -Name ptc -Value "pnpm type:check"

# Add aliases for npx commands
Set-Alias -Name upset -Value "npx git-upstream --set"

# Add aliases for ghq commands
Set-Alias -Name get -Value "ghq get"
Set-Alias -Name getb -Value "ghq get --bare"

# Add additional git aliases
Set-Alias -Name gbr -Value "git branch"
Set-Alias -Name gbranch -Value "git branch"
Set-Alias -Name gcom -Value "git switch master"
Set-Alias -Name gcp -Value "git cherry-pick"
Set-Alias -Name gdm -Value "git branch --merged|egrep -v '\*|develop|master|release'|xargs git branch -d"
Set-Alias -Name glog -Value "git log"
Set-Alias -Name gpcbf -Value "git push origin $(get_current_branch) --force-with-lease"
Set-Alias -Name gpom -Value "git push origin -u master"
Set-Alias -Name gpl -Value "git pull"
Set-Alias -Name gplcb -Value "git pull origin $(get_current_branch)"
Set-Alias -Name gpsub -Value "git submodule update --init --recursive"
Set-Alias -Name gptag -Value "git push origin --tags"
Set-Alias -Name gpum -Value "git pull upstream master"
Set-Alias -Name gr -Value "gcod && gpull"
Set-Alias -Name grh -Value "git restore --worktree"
Set-Alias -Name grb -Value "git rebase"
Set-Alias -Name gsd -Value "git switch develop"
Set-Alias -Name gsm -Value "git switch master"
Set-Alias -Name gw -Value "git worktree"
Set-Alias -Name gitsync -Value "git remote set-head origin --auto"
Set-Alias -Name bl -Value "git branch"
Set-Alias -Name branch -Value "git branch"
Set-Alias -Name pull -Value "git pull"
Set-Alias -Name up -Value "git pull upstream master"
Set-Alias -Name get_default_branch_fast -Value "git symbolic-ref refs/remotes/origin/HEAD --short | sed 's/origin\///'"
