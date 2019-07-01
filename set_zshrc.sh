#!/bin/bash
ZSHRC="~/.zshrc"
if [ -e $ZSHRC ]; then
  echo ".zshrc found. Creating backup..."
  exec cp ~/.zshrc ~/.zshrc.backup
fi
exec cp .zshrc ~/.zshrc 
echo "Successfully copied .zshrc"