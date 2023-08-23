# install cli tools for xcode
xcode-select --install
# install homebrew https://brew.sh/
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# install iterm2
brew cask install iterm2

# create a directory to be able to link python (required for watchman)
sudo mkdir /usr/local/Framework
sudo chown $(whoami):admin /usr/local/Framework

# install visual studio code
brew cask install visual-studio-code
# install docker
brew cask install docker
# install watchman for react-native development
brew install watchman

# install ghq
brew install ghq
# install peco
brew install peco

# install Slack
brew cask install slack
