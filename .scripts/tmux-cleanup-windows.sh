#!/bin/bash

# tmux-cleanup-windows.sh
# Closes all tmux windows except the active one and the first 3 windows (0, 1, 2)

# Check if we're in a tmux session
if [ -z "$TMUX" ]; then
    echo "Error: Not in a tmux session"
    exit 1
fi

# Get current window index
current_window=$(tmux display-message -p '#I')

# Get all window indices
windows=$(tmux list-windows -F '#I' | sort -n)

# Close windows that are not the current window and not in the first 3 (0, 1, 2)
for window in $windows; do
    if [ "$window" != "$current_window" ] && [ "$window" -gt 2 ]; then
        echo "Closing window $window"
        tmux kill-window -t "$window"
    fi
done

echo "Cleanup complete. Kept active window ($current_window) and windows 0-2"