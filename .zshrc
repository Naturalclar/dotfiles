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

for _zsh_part in "$ZSH_CONFIG_DIR"/*.zsh(N.); do
  source "$_zsh_part"
done
unset _zsh_part
