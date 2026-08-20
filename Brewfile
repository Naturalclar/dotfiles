# Top-level tools only (from `brew leaves`) — dependencies resolve automatically.
# Apply with `make brew`.
# Note: node/ghq etc. are managed by asdf, and neovim by bob, not Homebrew.
#
# The "used by CI" block below is kept by hand: those are here so a new machine
# can run what CI runs, whether or not they are installed on the machine this
# file was last regenerated from. Regenerating from `brew leaves` drops them,
# so put them back — test/docs.bats fails if one goes missing.

tap "nikitabobko/tap"
tap "stripe/stripe-cli"
tap "xcodesorg/made"

# Shell / terminal workflow
brew "bat"
brew "coreutils"
brew "direnv"
brew "fzf"
brew "peco"
brew "ripgrep"
brew "tmux"
brew "lynx" # used by .scripts/duck and .scripts/google

# Git
brew "gh"
brew "git-lfs"
brew "lazygit"

# Used by CI (shellcheck is an actionlint dep, but relied on directly)
brew "actionlint"
brew "bats-core"
brew "gitleaks"
brew "shellcheck"

# Dev tools
brew "cocoapods"
brew "docker"
brew "docker-compose"
brew "terraform"
brew "valkey"
brew "stripe/stripe-cli/stripe"
brew "xcodesorg/made/xcodes"

# Media
brew "ffmpeg"
brew "imagemagick"
brew "jpeg"
brew "librsvg"
brew "pkgconf"

# Apps
cask "aerospace"
cask "bruno"
cask "discord"
cask "slack"
cask "visual-studio-code@insiders"
