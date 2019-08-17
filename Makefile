# Set zshrc
zshrc:
	@echo 'Setting zshrc to home directory'
	ln -sfnv $(abspath .zshrc) $(HOME)/.zshrc

# Set hyper.js config
hyper:
	@echo 'Setting .hyper.js to home directory'
	ln -sfnv $(abspath .hyper.js) $(HOME)/.hyper.js

# Set BASH_PROFILE
bash:
	@echo 'Setting .bash_profile to home directory'
	ln -sfnv $(abspath .bash_profile) $(HOME)/.bash_profile

# Set gitconfig
git:
	@echo 'Setting .gitconfig to home directory'
	ln -sfnv $(abspath .gitconfig) $(HOME)/.gitconfig
