# Mirrors .zsh/50-path.zsh. GIT_EDITOR is what gh and git use; EDITOR is the
# fallback everything else (crontab, visudo, ...) reads.
set -gx EDITOR vim
set -gx GIT_EDITOR vim
