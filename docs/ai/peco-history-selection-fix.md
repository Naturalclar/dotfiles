# Fix for peco-history-selection on macOS and WSL

## Problem

The current implementation of the `peco-history-selection` function in `.zshrc` uses `tail -r` to reverse the output of the history command. This works on macOS but fails on Windows WSL because `tail -r` is not a valid option on WSL.

## Solution

Replace `tail -r` with `tac` in the peco-history-selection function. The `tac` command is available on both macOS and WSL systems and performs the same function (reversing the order of lines).

## Implementation Details

### Current Code (Line 450 in .zshrc):
```bash
BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
```

### Modified Code:
```bash
BUFFER=`history -n 1 | tac | awk '!a[$0]++' | peco`
```

### Changes Explained:
1. Replace `tail -r` with `tac`
2. This maintains the same functionality (reversing the history output) but works on both macOS and WSL
3. The rest of the pipeline remains unchanged:
   - `history -n 1`: Get command history without line numbers
   - `tac`: Reverse the order (newest commands first)
   - `awk '!a[$0]++'`: Remove duplicate entries
   - `peco`: Interactive filtering

## Testing

After implementing the change:
1. Test on macOS to ensure the function still works as expected
2. Test on Windows WSL to confirm the issue is resolved

## Benefits
- Simple, one-line change
- Works consistently across both platforms
- Maintains the same functionality and user experience
- No conditional logic needed, reducing complexity

## Additional Enhancement: Sharing History Between All Terminal Sessions

### Problem

By default, Zsh only shows the command history from the current terminal session. This means that commands executed in other terminal sessions are not available in the history search.

### Solution

Add Zsh history settings to enable sharing history between all terminal sessions. These settings ensure that commands from all terminal sessions are available in the history search.

### Implementation Details

Added the following settings to `.zshrc` after the OS detection section:

```bash
# History settings
# Share history between all sessions
setopt SHARE_HISTORY
# Append commands to the history file as they are executed
setopt INC_APPEND_HISTORY
# Remove oldest duplicated command when the history file is full
setopt HIST_EXPIRE_DUPS_FIRST
# Don't add duplicated commands to the history
setopt HIST_IGNORE_DUPS
# Don't show duplicated commands when searching through history
setopt HIST_FIND_NO_DUPS
# Remove superfluous blanks from commands before adding them to the history
setopt HIST_REDUCE_BLANKS
# Set history file size
HISTSIZE=10000
SAVEHIST=10000
```

### Benefits
- Commands from all terminal sessions are available in the history search
- Improved workflow efficiency by having access to all previously executed commands
- Consistent history across all terminal sessions
- Duplicate commands are handled intelligently