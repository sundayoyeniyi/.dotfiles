#!/bin/zsh

export ZSH=$HOME/.dotfiles
symlinks=($ZSH/symlinks/*.symlink)
for symlink in ${symlinks}
  do
    dotfile="$HOME/.$(basename "${symlink%.*}")"
    ln -s -f -v "$symlink" "$dotfile"
  done

config_symlinks=($ZSH/config/**/*.symlink(N))
for symlink in ${config_symlinks}
  do
    relative_path="${symlink#$ZSH/config/}"
    config_file="$HOME/.config/${relative_path%.*}"
    mkdir -p "$(dirname "$config_file")"
    ln -s -f -v "$symlink" "$config_file"
  done
