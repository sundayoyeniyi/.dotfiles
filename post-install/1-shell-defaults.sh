#! /bin/zsh

if test $(which zsh)
  then
    echo "Making ZSH default shell"
    chsh -s $(which zsh)
  else
    echo "ZSH not yet installed"
  fi
