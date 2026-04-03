#! /bin/zsh

set -euo pipefail

echo "> node installations"

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

if [ ! -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  echo "Homebrew nvm installation not found"
  exit 1
fi

. "/opt/homebrew/opt/nvm/nvm.sh"

if [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
  . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

nvm install 24
nvm alias default 24
nvm use default

echo "> global npm packages"

