#!/bin/zsh

lazy_load_nvm() {
  echo ">>> lazy loading NVM ..."
  mkdir -p $HOME/.nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

nvm() {
  unset -f nvm
  lazy_load_nvm
  nvm "$@"
}
