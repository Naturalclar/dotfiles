# Functions behind the keybindings in keybindings.ps1. Same jobs as the zsh
# widgets in .zsh/73-workspace.zsh, .zsh/74-peco-fzf.zsh and
# .zsh/81-run-script.zsh -- see README.md, zsh is the source of truth.

# Ctrl+A. zsh previews the README with find+bat, which are not here; fzf on
# Windows runs its preview through cmd, so this picks without one. `ws`
# (Ctrl+W, in alias.ps1) is the peco equivalent.
Function wf {
    $repo = ghq list --full-path | fzf --layout=reverse
    if ($repo) { Set-Location $repo }
}

# Ctrl+B. .scripts/switch-worktree is bash and has to be sourced to cd, which
# PowerShell cannot do, so this is the equivalent.
Function switch-worktree {
    $lines = @(git worktree list 2>$null | Select-Object -Skip 1)
    if ($lines.Count -eq 0) {
        Write-Host "No linked worktrees for this repository"
        return
    }

    $entries = foreach ($line in $lines) {
        $fields = $line -split '\s+'
        $path = $fields[0]
        $branch = $fields[2] -replace '^\[|\]$', ''
        $name = Split-Path -Leaf $path
        # "Nothing" when the branch adds nothing beyond the directory name,
        # matching the bash script.
        if ($branch -eq $name) { $branch = 'Nothing' }
        [pscustomobject]@{
            Path  = $path
            Label = '{0,-30} {1}' -f ((Split-Path -Leaf (Split-Path -Parent $path)) + "/$name"), $branch
        }
    }

    $picked = $entries.Label | fzf --layout=reverse --prompt="Select worktree: "
    if (-not $picked) { return }

    $match = $entries | Where-Object { $_.Label -eq $picked } | Select-Object -First 1
    if ($match) { Set-Location $match.Path }
}

# Ctrl+N. Same selector and lockfile precedence as the zsh and fish versions,
# using ConvertFrom-Json rather than jq, which Windows does not ship.
Function run-script {
    if (-not (Test-Path -LiteralPath 'package.json')) {
        Write-Host "No package.json found in current directory"
        return
    }

    $scripts = (Get-Content -Raw 'package.json' | ConvertFrom-Json).scripts
    if (-not $scripts) {
        Write-Host "No scripts found in package.json"
        return
    }

    # ::: as the delimiter, so script names containing a colon still split.
    $entries = $scripts.PSObject.Properties | ForEach-Object { "$($_.Name):::$($_.Value)" }
    $picked = $entries | fzf --layout=reverse --prompt="Run script: "
    if (-not $picked) { return }

    $name = ($picked -split ':::', 2)[0]

    $cmd = 'npm', 'run'
    if (Test-Path -LiteralPath 'yarn.lock') { $cmd = , 'yarn' }
    elseif (Test-Path -LiteralPath 'pnpm-lock.yaml') { $cmd = , 'pnpm' }
    elseif (Test-Path -LiteralPath 'bun.lockb') { $cmd = 'bun', 'run' }

    Write-Host "Running: $($cmd -join ' ') $name"
    & $cmd[0] @($cmd[1..($cmd.Count - 1)]) $name
}

# Ctrl+R / Ctrl+Z. zsh reverses its history, drops duplicates and pipes it to
# peco; PSReadLine keeps its own history file, so read that instead.
Function Select-HistoryLine {
    $path = (Get-PSReadLineOption).HistorySavePath
    if (-not (Test-Path -LiteralPath $path)) { return }

    $lines = [System.Collections.ArrayList]@(Get-Content -LiteralPath $path)
    $lines.Reverse()
    return $lines | Select-Object -Unique | peco
}
