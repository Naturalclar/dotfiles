# NOTE: mirrors _prompt_path in .zsh/40-prompt.zsh, which is the source of
# truth, and __prompt_path.fish on the fish side. Inside a git repository show
# <repo>[/<worktree>] plus the path from the repository root, instead of just
# the directory name -- under ~/.ghq/github.com/owner/... a bare leaf tells you
# very little, and with worktrees it is often just the branch name.
function Get-PromptPath {
    try {
        $info = @(git rev-parse --show-toplevel --git-common-dir 2>$null)
        if ($LASTEXITCODE -ne 0 -or $info.Count -ne 2) {
            return $PWD.Path.Replace($HOME, '~')
        }

        # git reports forward slashes on Windows while $PWD uses backslashes,
        # so normalise before taking the path relative to the root.
        $root = $info[0] -replace '\\', '/'
        $here = $PWD.Path -replace '\\', '/'

        # --git-common-dir is relative when called from a subdirectory.
        $common = (Resolve-Path -LiteralPath $info[1]).Path -replace '\\', '/'

        # .git or .bare means a hidden directory inside the repository, so the
        # parent carries the name. Anything else is the bare repository itself
        # (foo.git), whose own name is it, minus the suffix.
        $leaf = Split-Path -Leaf $common
        if ($leaf -in '.git', '.bare') {
            $label = Split-Path -Leaf (Split-Path -Parent $common)
        } else {
            $label = $leaf -replace '\.git$', ''
        }

        # In a linked worktree <root>/.git is a file rather than a directory.
        if (Test-Path -LiteralPath (Join-Path $info[0] '.git') -PathType Leaf) {
            $label = "$label/" + (Split-Path -Leaf $root)
        }

        if ($here.Length -gt $root.Length) {
            $label += $here.Substring($root.Length)
        }
        return $label
    } catch {
        # Never let the prompt break; fall back to what this used to show.
        return (Split-Path -Leaf $PWD.Path)
    }
}

function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation

    $out = ""
    if ($loc.Provider.Name -eq "FileSystem") {
        $out += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
    }
    $out += "PS> "

    $path = Get-PromptPath
    $branch = get_current_branch

    # Red when the working tree is dirty, matching the vcs_info markers in zsh.
    $branchColor = if ($null -ne (git status --porcelain 2>$null)) { "Red" } else { "Green" }

    Write-Host "╭─ " -NoNewline -ForegroundColor "DarkGreen"
    Write-Host "$path " -NoNewline -ForegroundColor "Magenta"
    if ($branch) {
        Write-Host "[$branch] " -ForegroundColor $branchColor
    } else {
        Write-Host ""
    }
    Write-Host "╰─$ " -NoNewline -ForegroundColor "DarkGreen"

    return $out
}
