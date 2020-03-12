# Starship
starship init fish | source

# Ruby
set -gx PATH $HOME/Software/ruby $PATH
set -gx PATH $HOME/Software/ruby/bin $PATH

# Yarn
set -gx PATH $HOME/.yarn/bin $PATH

# Brew
set -gx PATH /usr/local/sbin $PATH

# Deno
set -gx PATH $HOME/.deno/bin $PATH

# Rust
set -gx PATH $HOME/.cargo/bin $PATH

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
#export ANDROID_NDK_HOME=/usr/local/share/android-ndk
set -gx PATH $HOME/Library/Android/sdk $PATH
set -gx PATH $ANDROID_HOME/tools $PATH
set -gx PATH $ANDROID_HOME/tools/bin $PATH
set -gx PATH $ANDROID_HOME/platform-tools $PATH
set -gx PATH $ANDROID_HOME/emulator $PATH

# opam configuration
source $HOME/.opam/opam-init/init.fish > /dev/null 2> /dev/null || true

# asdf version manager
source /usr/local/opt/asdf/asdf.fish
