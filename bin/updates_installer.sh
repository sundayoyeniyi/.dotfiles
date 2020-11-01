#! /bin/zsh

export ZSH=$HOME/.dotfiles

update_files=($ZSH/updates/*.sh)
for file in ${update_files}
  do
    $file
  done