DOTFILES 	:= $(wildcard .??*)
IGNORE	:= .DS_Store .git .gitmodules .gitignore .github .config
TARGET	:= $(filter-out $(IGNORE), $(DOTFILES))
VSCODE_SCRIPT_PATH := $(abspath configs/.vscode)
CONFIG_PATH := $(wildcard .config/??*)
.DEFAULT_GOAL	:= dotfiles

list: # Show dotfiles in this repository
	@echo 'list - Showing list of dotfiles in this repository'
	@echo '------------------------'
	@$(foreach val, $(TARGET), /bin/ls -dF $(val);)
	@echo '------------------------'

dotfiles: # Create symlinks of dotfiles to home directory
	@echo 'dotfiles - Setting simlinks of dotfiles in HOME directory'
	@echo '------------------------'
	@$(foreach val, $(TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@echo '------------------------'

config: # Create symlinks of .config at home directory
	@echo 'dotfiles - Setting simlinks of .config in HOME directory'
	@echo '------------------------'
	@echo $(abspath $(CONFIG_PATH))
	@$(foreach val, $(CONFIG_PATH), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@echo '------------------------'

vscodeExtensions: # Sync VSCode extensions
	@echo 'vscodeExtensions - Syncing VSCode extensions'
	@echo '------------------------'
	@bash $(VSCODE_SCRIPT_PATH)/vscodeSync.sh
	@echo '------------------------'

help: # Print Usge
	@echo 'help - showing usage'
	@echo '------------------------'
	@grep '^[^#[:space:]].*: #' Makefile
	@echo '------------------------'
