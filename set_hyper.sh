#!/bin/bash
HYPER="~/.hyper.js"
if [ -e $HYPER ]; then
  echo ".hyper.js found. Creating backup..."
  exec cp ~/.hyper.js ~/.hyper.js.backup
fi
exec cp .hyper.js ~/.hyper.js 
echo "Successfully copied .hyper.js"