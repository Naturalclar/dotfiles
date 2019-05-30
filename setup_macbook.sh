# install cli tools for xcode
xcode-select --install
# install homebrew https://brew.sh/
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# install iterm2
brew cask install iterm2
# install zsh
brew install zsh
# install visual studio code
brew cask install visual-studio-code
# install nvm (node version manager) https://github.com/nvm-sh/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
# set nvm to PATH
export NVM_DIR="${XDG_CONFIG_HOME/:-$HOME/.}nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
# install latest version of node
nvm install node
# install yarn https://yarnpkg.com
brew install yarn
# install docker
brew cask install docker
# install watchman for react-native development
brew install watchman
# install react-native-cli
yarn global add react-native-cli
# install expo-cli https://facebook.github.io/react-native/docs/getting-started
yarn global add expo-cli
# install typescript https://www.typescriptlang.org/
yarn global add typescript
# install gatsby-cli https://www.gatsbyjs.org
yarn global add gatsby-cli
