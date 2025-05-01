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