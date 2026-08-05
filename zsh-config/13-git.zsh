#!/bin/zsh

# Ensure the global gitignore (symlinked to symlinks/gitignore.symlink) is active.
git config --global core.excludesFile "$HOME/.gitignore"
