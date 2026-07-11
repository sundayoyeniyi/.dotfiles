#!/bin/zsh

export ZSH=$HOME/.dotfiles
symlinks=($ZSH/symlinks/*.symlink)
for symlink in ${symlinks}
  do
    dotfile="$HOME/.$(basename "${symlink%.*}")"
    ln -s -f -v "$symlink" "$dotfile"
  done

config_files=($ZSH/config/**/*(.N))
for config_file_source in ${config_files}
  do
    relative_path="${config_file_source#$ZSH/config/}"
    if [[ "$relative_path" == *.symlink ]]; then
      relative_path="${relative_path%.*}"
    fi

    config_file="$HOME/.config/${relative_path}"
    mkdir -p "$(dirname "$config_file")"
    ln -s -f -v "$config_file_source" "$config_file"
  done
