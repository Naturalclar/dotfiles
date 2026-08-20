# Everything lives in .zsh/*.zsh, sourced in filename order.
#
# The numeric prefixes are load order, and it matters: options and PATH before
# the things that use them, and the syntax-highlighting plugin after the
# aliases it highlights. Concatenating the parts in this order reproduces the
# single file this replaced, byte for byte.
#
#   00  shell options and locale        50  PATH
#   10  OS-specific setup               60  plugins
#   20  history                         70  aliases and widgets
#   30  language runtimes               80  late setup
#   40  prompt
#
# %N is the path of the file being sourced, so this resolves whether zsh reads
# a ~/.zshrc symlink or the file is sourced straight out of the repository --
# CI does the latter.
ZSH_CONFIG_DIR="${${(%):-%N}:A:h}/.zsh"

# Both switches are off unless asked for: a shell that prints something on
# every start makes its output unusable for anything reading it.
#
#   ZSH_STARTUP_TIME=1 zsh -i -c exit   how long the modules took
#   ZSH_PROFILE=1 zsh -i -c exit        which functions that time went to
#
# They live here rather than in a module because this loop is what they
# measure -- an end marker parked in one module would silently stop covering
# whatever gets added after it.
if [[ -n "$ZSH_PROFILE" ]]; then
  zmodload zsh/zprof
fi
if [[ -n "$ZSH_STARTUP_TIME" ]]; then
  zmodload zsh/datetime
  _zsh_load_start=$EPOCHREALTIME
fi

for _zsh_part in "$ZSH_CONFIG_DIR"/*.zsh(N.); do
  source "$_zsh_part"
done
unset _zsh_part

if [[ -n "$ZSH_STARTUP_TIME" ]]; then
  printf 'zsh startup: %.0fms\n' $(( (EPOCHREALTIME - _zsh_load_start) * 1000 ))
  unset _zsh_load_start
fi
if [[ -n "$ZSH_PROFILE" ]]; then
  zprof
fi
