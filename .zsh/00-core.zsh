# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# set vim motion
set -o vi

# Force a UTF-8 locale so multibyte (e.g. Japanese) renders over SSH clients
# like Termius, which don't forward the locale Terminal.app sets locally.
# Only export a locale that's actually generated -- stock WSL/container images
# ship C.UTF-8 only, and an unavailable value makes bash warn on every start:
#   bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
for _l in en_US.UTF-8 C.UTF-8; do
    if locale -a 2>/dev/null | grep -qiE "^${_l%.*}\.(utf-?8)$"; then
        export LANG="$_l"
        export LC_ALL="$_l"
        break
    fi
done
unset _l

# Profiling and startup timing are opt-in and live in .zshrc; see the comment
# there for ZSH_PROFILE and ZSH_STARTUP_TIME.

OS=`uname`

