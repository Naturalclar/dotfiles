#!/bin/bash
ZSHRC="~/.zshrc"
BASH_PROFILE="~/.bash_profile"

if [ -e $ZSHRC ]; then
  echo ".zshrc found. Creating backup..."
  exec cp ~/.zshrc ~/.zshrc.backup
fi

if [ -e $BASH_PROFILE ]; then
  echo ".bash_profile found. Creating backup..."
  exec cp ~/.bash_profile ~/.bash_profile.backup
fi

exec cp .bash_profile ~/.bash_profile
exec cp .zshrc ~/.zshrc 
echo "Successfully copied .zshrc"
