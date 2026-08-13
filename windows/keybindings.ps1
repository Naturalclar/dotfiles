# NOTE: mirrors the bindkey lines in .zsh/ and fish_user_key_bindings in fish.
# zsh is the source of truth -- see README.md.
#
# Ctrl+F is deliberately absent: it opens a tmux session on the Unix side, and
# there is no tmux here.

if (-not (Get-Module PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
}
if (-not (Get-Module PSReadLine)) { return }

# zsh runs `set -o vi` and fish pins fish_vi_key_bindings; match them.
Set-PSReadLineOption -EditMode Vi

# Bind in both vi modes, as the fish side does, so these work whether or not
# you are in insert mode. Without -ViMode only insert gets the binding.
function Set-Binding {
    param(
        [Parameter(Mandatory)][string]$Chord,
        [Parameter(Mandatory)][scriptblock]$Action,
        [Parameter(Mandatory)][string]$Description
    )

    foreach ($mode in 'Insert', 'Command') {
        Set-PSReadLineKeyHandler -Chord $Chord -ScriptBlock $Action `
            -Description $Description -ViMode $mode
    }
}

# Replace the line with a command picked out of history.
Set-Binding -Chord 'Ctrl+r' -Description 'search history' -Action {
    $picked = Select-HistoryLine
    if ($picked) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($picked)
    }
}
# zsh had history on Ctrl+Z first; keep it there too.
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -ViMode Insert -Description 'search history' -ScriptBlock {
    $picked = Select-HistoryLine
    if ($picked) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($picked)
    }
}

# These change directory, so redraw the prompt afterwards rather than leaving
# the old one on screen.
Set-Binding -Chord 'Ctrl+w' -Description 'ghq repo (peco)' -Action {
    ws
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-Binding -Chord 'Ctrl+a' -Description 'ghq repo (fzf)' -Action {
    wf
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-Binding -Chord 'Ctrl+b' -Description 'git worktree' -Action {
    switch-worktree
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

# Runs a command rather than moving, so let it print above a fresh prompt.
Set-Binding -Chord 'Ctrl+n' -Description 'package.json script' -Action {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    run-script
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
