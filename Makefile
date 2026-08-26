DOTFILES 	:= $(wildcard .??*)
# .devcontainer and .vscode configure this repository, not $HOME. ~/.vscode in
# particular is VSCode's own extensions directory, so linking over it is wrong.
IGNORE	:= .DS_Store .git .gitmodules .gitignore .github .config .devcontainer .vscode .claude
TARGET	:= $(filter-out $(IGNORE), $(DOTFILES))
VSCODE_SCRIPT_PATH := $(abspath configs/.vscode)
CONFIG_PATH := $(wildcard .config/??*)
# Linked one skill at a time rather than as a whole directory: ~/.claude/skills
# is shared with skills that came from elsewhere, and replacing it with a link
# to this repository would hide them.
#
# They live in .claude/skills so that a cloud session, which clones this
# repository and never sees ~/.claude, picks them up with no setup at all.
# That is also why .claude is in IGNORE: it is this repository's own
# configuration, not a dotfile to drop into $HOME.
CLAUDE_SKILL_PATH := $(wildcard .claude/skills/??*)
.DEFAULT_GOAL	:= dotfiles

.PHONY: list dotfiles config claude unlink brew bootstrap vscodeExtensions help

# link <source> <destination>
# `ln -sfn dest` puts the link *inside* dest when dest is already a real
# directory, which leaves make green while the config never takes effect. Skip
# those instead, so a directory we did not create is never touched. A plain
# file is still replaced -- overwriting a stock ~/.bashrc is the whole point.
define link
if [ -d "$(2)" ] && [ ! -L "$(2)" ]; then echo "skip $(2): already a directory, remove or rename it to link"; else ln -sfnv "$(1)" "$(2)"; fi;
endef

# rmlink <destination>
# The counterpart of link: only ever removes a symlink. A real file or
# directory at the destination is something we did not create.
define rmlink
if [ -L "$(1)" ]; then rm -v "$(1)"; fi;
endef

list: # Show dotfiles in this repository
	@echo 'list - Showing list of dotfiles in this repository'
	@echo '------------------------'
	@$(foreach val, $(TARGET), /bin/ls -dF $(val);)
	@echo '------------------------'

dotfiles: # Create symlinks of dotfiles to home directory
	@echo 'dotfiles - Setting symlinks of dotfiles in HOME directory'
	@echo '------------------------'
	@$(foreach val, $(TARGET), $(call link,$(abspath $(val)),$(HOME)/$(val)))
	@echo '------------------------'

config: # Create symlinks of .config at home directory
	@echo 'config - Setting symlinks of .config in HOME directory'
	@echo '------------------------'
	@echo $(abspath $(CONFIG_PATH))
	@mkdir -p $(HOME)/.config
	@$(foreach val, $(CONFIG_PATH), $(call link,$(abspath $(val)),$(HOME)/$(val)))
	@echo '------------------------'

claude: # Create symlinks of Claude Code settings.json and skills in ~/.claude
	@echo 'claude - Setting symlinks of Claude Code settings.json and skills in ~/.claude'
	@echo '------------------------'
	@mkdir -p $(HOME)/.claude/skills
	@ln -sfnv $(abspath configs/claude/settings.json) $(HOME)/.claude/settings.json
	@$(foreach val, $(CLAUDE_SKILL_PATH), $(call link,$(abspath $(val)),$(HOME)/.claude/skills/$(notdir $(val))))
	@echo '------------------------'

unlink: # Remove dotfile symlinks from home directory
	@echo 'unlink - Removing dotfile symlinks from HOME directory'
	@echo '------------------------'
	@$(foreach val, $(TARGET) $(CONFIG_PATH), $(call rmlink,$(HOME)/$(val)))
	@$(call rmlink,$(HOME)/.claude/settings.json)
	@$(foreach val, $(CLAUDE_SKILL_PATH), $(call rmlink,$(HOME)/.claude/skills/$(notdir $(val))))
	@echo '------------------------'

bootstrap: # Full new-machine setup (Homebrew, packages, symlinks, asdf runtimes)
	@./install.sh

brew: # Install Homebrew packages from Brewfile
	@echo 'brew - Installing Homebrew packages from Brewfile'
	@echo '------------------------'
	@brew bundle --file=Brewfile --no-upgrade
	@echo '------------------------'

vscodeExtensions: # Sync VSCode extensions
	@echo 'vscodeExtensions - Syncing VSCode extensions'
	@echo '------------------------'
	@bash $(VSCODE_SCRIPT_PATH)/vscodeSync.sh
	@echo '------------------------'

help: # Print Usage
	@echo 'help - showing usage'
	@echo '------------------------'
	@grep '^[^#[:space:]].*: #' Makefile
	@echo '------------------------'
