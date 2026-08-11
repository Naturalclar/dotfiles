DOTFILES 	:= $(wildcard .??*)
IGNORE	:= .DS_Store .git .gitmodules .gitignore .github .config
TARGET	:= $(filter-out $(IGNORE), $(DOTFILES))
VSCODE_SCRIPT_PATH := $(abspath configs/.vscode)
CONFIG_PATH := $(wildcard .config/??*)
.DEFAULT_GOAL	:= dotfiles

.PHONY: list dotfiles config claude unlink brew bootstrap vscodeExtensions help

list: # Show dotfiles in this repository
	@echo 'list - Showing list of dotfiles in this repository'
	@echo '------------------------'
	@$(foreach val, $(TARGET), /bin/ls -dF $(val);)
	@echo '------------------------'

dotfiles: # Create symlinks of dotfiles to home directory
	@echo 'dotfiles - Setting symlinks of dotfiles in HOME directory'
	@echo '------------------------'
	@$(foreach val, $(TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@echo '------------------------'

config: # Create symlinks of .config at home directory
	@echo 'config - Setting symlinks of .config in HOME directory'
	@echo '------------------------'
	@echo $(abspath $(CONFIG_PATH))
	@mkdir -p $(HOME)/.config
	@$(foreach val, $(CONFIG_PATH), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@echo '------------------------'

claude: # Create symlink of Claude Code settings.json in ~/.claude
	@echo 'claude - Setting symlink of Claude Code settings.json in ~/.claude'
	@echo '------------------------'
	@mkdir -p $(HOME)/.claude
	@ln -sfnv $(abspath configs/claude/settings.json) $(HOME)/.claude/settings.json
	@echo '------------------------'

unlink: # Remove dotfile symlinks from home directory
	@echo 'unlink - Removing dotfile symlinks from HOME directory'
	@echo '------------------------'
	@$(foreach val, $(TARGET) $(CONFIG_PATH), if [ -L "$(HOME)/$(val)" ]; then rm -v "$(HOME)/$(val)"; fi;)
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
