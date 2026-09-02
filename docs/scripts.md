# Scripts

`.scripts/` is symlinked into `$HOME` by `make` and added to `PATH` by `.zsh/30-runtimes.zsh`.

| Script | Description |
| --- | --- |
| `pmux` | Pick a ghq-managed repo via fzf (with README preview) and open/attach a tmux session for it. Bound to `F1` in tmux. |
| `tmux-window-fzf` | Fuzzy-select a tmux window across all sessions (with pane preview) and switch to it. Bound to `F4` and `prefix + w` in tmux. |
| `tmux-cheatsheet` | Show the prefix-less keybinds in a popup, generated from `tmux list-keys`. Bound to `F6` in tmux. |
| `tmux-send-all` | Send a command to tmux panes in the current session, targeting (`-t`) or excluding (`-i`) specific panes. |
| `tmux-cleanup-windows.sh` | Close all tmux windows except the active one and windows 0–2. |
| `tmux-pane-name` | Rename the current tmux window to the current git branch (or a given name). |
| `tmux-pane-highlight` | Set a colored border + status emoji on the current pane/window; used to signal Claude Code state from hooks. `off` clears it. |
| `tmux-claude-elapsed` | Format the time elapsed since a `@claude_at` timestamp (`45s`, `12m`, `1h03m`) for the status line; the other half of `tmux-pane-highlight`. |
| `tssh` | List Tailscale hosts and ssh into the selected one (fzf picker, `tailscale ssh` for Linux targets, plain ssh otherwise). See `tssh -h`. |
| `switch-worktree` | Pick a git worktree via fzf and cd into it. Sourced via the `Ctrl+B` keybind in zsh. |
| `git-worktree-pull` | Fix the fetch refspec of a bare/worktree clone so `git fetch origin` gets all remote branches. Aliased as `gwp`. |
| `notify-sound` | Play a notification sound if this machine has a player and the file (`$NOTIFY_SOUND`, default `~/Music/daisuki.mp3`); silent no-op otherwise. Called from the Claude Code hooks. |
| `sai-record` | Hand a Claude Code hook event (stdin) to `$SAI_HOME/feed/record.py`, the turn recorder in the sai repository; silent no-op when `SAI_HOME` (default `~/.ghq/github.com/Naturalclar/sai.git/main`), the script or `python3` is missing. Called from the Claude Code hooks. |
| `killport` | Kill the processes listening on a given port (`killport 8080`). |
| `duck` / `google` | Search DuckDuckGo / Google from the terminal via lynx. |
| `urlencode` | URL-encode arguments or stdin; used by `duck` and `google`. |

[Back to the README](../README.md).
