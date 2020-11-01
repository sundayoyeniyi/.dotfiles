#!/bin/zsh

export ZSH=$HOME/.dotfiles
symlinks=($ZSH/symlinks/*.symlink)
for symlink in ${symlinks}
  do
    dotfile="$HOME/.$(basename "${symlink%.*}")"
    ln -s -f -v "$symlink" "$dotfile"
  done