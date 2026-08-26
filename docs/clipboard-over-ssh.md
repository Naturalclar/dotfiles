# Clipboard over SSH

`y` in vim/nvim on an SSH target can only reach the client's clipboard through
the terminal, via the OSC 52 escape sequence. When `$SSH_TTY`/`$SSH_CONNECTION`
is set:

- **Neovim** (`.config/nvim/lua/config/options.lua`) forces the OSC 52
  clipboard provider. The built-in auto-detection is *not* enough: it only kicks
  in when no `pbcopy`/`xclip`/`wl-copy` exists on the server and it is inhibited
  by tmux (`:h clipboard-osc52`), so a Mac target would silently copy to its own
  clipboard. Paste (`"+p`, `P`) returns the last yank instead of asking the
  terminal, because most terminals refuse clipboard reads and nvim would wait
  up to 10 s.
- **Vim** (`.vim/vimrc`) writes OSC 52 on `TextYankPost` with a few lines of
  vimscript; no plugin needed.
- **tmux** (`.tmux.conf`) has `set-clipboard on` and `allow-passthrough on` so
  the sequence is relayed to the outer terminal instead of swallowed.
- Locally (no SSH variables) nothing changes.

Terminals: WezTerm, kitty, Ghostty, Windows Terminal and Alacritty accept
OSC 52 writes by default. **iTerm2 does not** — enable
*Settings → General → Selection → "Applications in terminal may access
clipboard"* (GUI only, not in dotfiles).

To check the path without an editor, run this on the server and paste on the
client (inside tmux, `tmux show-buffer` shows whether tmux relayed it):

```sh
printf '\033]52;c;%s\a' "$(printf hello | base64)"
```

Note that a tmux server started locally and attached later over SSH does not
have the SSH variables in already-open shells; open a new window or
`tmux set-environment`.

Payload limit: tmux does not truncate (checked with 500 lines / 20 KB), but some
terminals cap a single OSC 52 at 100 000 bytes of base64 (~74 KB of text, the
xterm default). A yank above that is dropped silently. Workaround for anything
bigger: write it to a file and `scp`, or yank in chunks.

[Back to the README](../README.md).
