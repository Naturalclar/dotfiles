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


