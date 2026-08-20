# asdf comes from a git clone rather than a package, so it is not always there:
# a machine that has not run install.sh yet, a container, CI. Guard the source
# -- unguarded it wrote "no such file or directory" to stderr on every start,
# two lines before the message below that explains how to install it.
#
# Both branches did this identically, so it lives ahead of the case. That keeps
# the order they had: asdf first, then the PATH entries that should win over
# its shims.
export ASDF_DIR="$HOME/.asdf"
[ -f "$ASDF_DIR/asdf.sh" ] && . "$ASDF_DIR/asdf.sh"

# Set option depending on OS
case "${OS}" in
    Darwin*)
        # Add Brew Path
        export PATH="/opt/homebrew/bin:$PATH"
        export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
        # Repair SSH_AUTH_SOCK when missing (e.g. inside tmux) by pointing
        # at the macOS launchd ssh-agent socket
        if [[ -z "$SSH_AUTH_SOCK" || ! -S "$SSH_AUTH_SOCK" ]]; then
            _launchd_sock=(/private/tmp/com.apple.launchd.*/Listeners(N))
            [[ -n "$_launchd_sock" ]] && export SSH_AUTH_SOCK="${_launchd_sock[1]}"
            unset _launchd_sock
        fi
    ;;
    Linux*)
        # One agent per machine, not one per shell. `eval "$(ssh-agent)"` on
        # every start left a stray agent behind for every terminal ever opened,
        # and each shell got its own: a key added with ssh-add in one window
        # was invisible in the next.
        #
        # So point every shell at the same socket -- reuse the agent answering
        # there, and only start one when nothing does. macOS needs none of this
        # because launchd already runs an agent; the Darwin branch above just
        # finds its socket again.
        _ssh_agent_sock="${XDG_RUNTIME_DIR:-/tmp}/ssh-agent-$UID.sock"
        # ssh-add -l exits 1 for "agent is there, holding no keys" and 2 for
        # "could not reach an agent" -- only the second one means we need one.
        if [[ -n "$SSH_AUTH_SOCK" ]] && { ssh-add -l >/dev/null 2>&1 || [[ $? -ne 2 ]] }; then
            : # an agent is already reachable (forwarded over SSH, systemd, ...)
        elif [[ -S "$_ssh_agent_sock" ]] && { SSH_AUTH_SOCK="$_ssh_agent_sock" ssh-add -l >/dev/null 2>&1 || [[ $? -ne 2 ]] }; then
            export SSH_AUTH_SOCK="$_ssh_agent_sock"
        elif command -v ssh-agent >/dev/null 2>&1; then
            # Nothing is listening, so the socket is a leftover from an agent
            # that died; ssh-agent -a refuses to bind over it.
            rm -f "$_ssh_agent_sock"
            eval "$(ssh-agent -a "$_ssh_agent_sock" 2>/dev/null)" >/dev/null
        fi
        unset _ssh_agent_sock
        # set pbcopy to be similar to Darwin
        alias pbcopy='xsel --clipboard --input'
        # Check if required commands are installed
      if ! command -v asdf &> /dev/null; then
        echo "asdf is not installed"
        echo "git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1"
        echo "For additional guides, check: https://asdf-vm.com/guide/getting-started.html"
      fi
      if ! command -v node &> /dev/null; then
        echo "node is not installed"
        echo "asdf plugin add nodejs"
        echo "asdf install nodejs latest"
        echo "For additional guides, check: https://github.com/asdf-vm/asdf-nodejs"
      fi
      if ! command -v ghq &> /dev/null; then
        echo "ghq is not installed"
        echo "asdf plugin add ghq"
        echo "asdf install ghq latest"
        echo "For additional guides, check: https://github.com/x-motemen/ghq"
      fi
      if ! command -v peco &> /dev/null; then
        echo "peco is not installed"
        echo "sudo apt install peco"
        echo "For additional guides, check: https://github.com/peco/peco"
      fi
      if ! command -v lazygit &> /dev/null; then
        echo "lazygit is not installed"
        echo "Install using guides in https://github.com/jesseduffield/lazygit"
      fi
      export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
      export PATH=$HOME/.local/share/bob/nvim-bin:$PATH
      export PATH=/snap/bin:$PATH
      # WSL Explorer command (similar to macOS 'open')
      alias open="explorer.exe"
      # npm global path for WSL
      export PATH=~/.npm-global/bin:$PATH
      # Set SHELL for WSL
      export SHELL=/usr/bin/zsh
      # end set JAVA_HOME
      # TODO: only do this if linuxbrew exists
      # eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac

