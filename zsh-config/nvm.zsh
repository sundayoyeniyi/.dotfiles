#!/bin/zsh

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  . "/opt/homebrew/opt/nvm/nvm.sh"

  if [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; then
    . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  fi
fi

autoload -U add-zsh-hook

use_nvm_project_version() {
  if ! command -v nvm >/dev/null 2>&1; then
    return
  fi

  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc 2>/dev/null)"

  if [ -n "$nvmrc_path" ]; then
    nvm use --silent >/dev/null 2>&1 || nvm install >/dev/null 2>&1
  else
    nvm use --silent default >/dev/null 2>&1 || true
  fi
}

add-zsh-hook chpwd use_nvm_project_version
use_nvm_project_version
