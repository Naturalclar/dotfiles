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
    git pull $args
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
    git checkout $args
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

# NOTE: these are functions, not Set-Alias. Set-Alias binds a name to a single
# command, so `Set-Alias pb "pnpm build"` creates an alias for a command called
# "pnpm build" -- which does not exist, and fails the moment you run it. Only
# argument-less aliases (below) can use Set-Alias.
#
# Definitions follow .zsh/*.zsh, which is the source of truth. See docs/shells.md.

# pnpm
Set-Alias -Name p -Value pnpm
Function pb { pnpm build $args }
Function ph { pnpm start $args }
Function pi { pnpm install $args }
Function add { pnpm add $args }
Function addd { pnpm add -D $args }
Function addg { pnpm global add $args }
Function lint { pnpm lint $args }
Function format { pnpm format $args }
Function tc { pnpm type-check $args }
Function ptc { pnpm type:check $args }
# zsh has this one on yarn, not pnpm
Function type-check { yarn type-check $args }

# npx
Function upset { npx git-upstream --set $args }

# ghq -- `get` is defined as a function further up
Function getb { ghq get --bare $args }

# git
Function gbr { git branch $args }
Function gbranch { git branch $args }
Function bl { git branch $args }
Function branch { git branch $args }
Function gcom { git switch master }
Function gsm { git switch master }
Function gsd { git switch develop }
Function gcp { git cherry-pick $args }
Function glog { git log $args }
Function grb { git rebase $args }
Function grh { git restore --worktree $args }
Function gw { git worktree $args }
Function gpl { git pull $args }
Function pull { git pull $args }
Function gpom { git push origin -u master }
Function gptag { git push origin --tags }
Function gpum { git pull upstream master }
Function gpsub { git submodule update --init --recursive }
Function gitsync { git remote set-head origin --auto }
Function gr { gcod && gpull }
Function up { git stash -u && git rebase main && git stash pop }

# The branch has to be resolved when the command runs. Inside a double-quoted
# Set-Alias value $( ) expands once, at profile load, so these used to push to
# whichever branch happened to be checked out when the shell opened.
Function gpcbf { git push origin (get_current_branch) --force-with-lease $args }
Function gplcb { git pull origin (get_current_branch) $args }

# sed, egrep and xargs are not there on Windows, so these differ from the zsh
# definitions in wording while doing the same thing.
Function get_default_branch_fast {
    (git symbolic-ref refs/remotes/origin/HEAD --short) -replace '^origin/', ''
}
Function gdm {
    # delete merged branches
    git branch --merged |
        Where-Object { $_ -notmatch '^\*|develop|master|release' } |
        ForEach-Object { git branch -d $_.Trim() }
}

# Add alias for cygpath
Set-Alias cygpath "$env:USERPROFILE\scoop\apps\git\current\usr\bin\cygpath.exe"
