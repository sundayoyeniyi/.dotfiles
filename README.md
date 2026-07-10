# .dotfiles

## Introduction

This is the way I choose to organise the .dotfiles on my development machine and install my software development arsenals.  It is largely personal but I was influenced and motivated to do this because I cannot find my way around OMZ - if you know what I mean.

## Installation

 > Clone the repo into your home folder and execute `./.dotfiles/bin/system_installer.sh` after reviewing the script to make sure it does what you want it to do.  It will install the software I use and set up the shell prompt as I like it.

## WezTerm

WezTerm is configured through `symlinks/wezterm.lua.symlink`, which is installed as `~/.wezterm.lua` by `./.dotfiles/bin/symlink_installer.sh`.

The starter config uses JetBrains Mono at 18pt, the Tokyo Night colour scheme, ligatures, macOS-friendly window defaults, conservative padding, tab and pane shortcuts, and a small amount of transparency/blur.

The TradeAlpha workspace can be launched with:

```sh
./.dotfiles/bin/tradealpha_workspace.sh
```

It opens a `TradeAlpha` WezTerm workspace with panes for Ollama, the TradeAlpha server, and OpenCode using `ollama/qwen3-coder:30b`.

## OpenCode

OpenCode is configured through `config/opencode/opencode.json.symlink`, which is installed as `~/.config/opencode/opencode.json` by `./.dotfiles/bin/symlink_installer.sh`.

The config uses Ollama at `http://localhost:11434/v1` and registers the local models currently managed here: `qwen3-coder:30b`, `deepseek-r1:14b`, and `gpt-oss:20b`.

## Resulting shell prompt

![shell prompt](/assets/my-shell-prompt.png)

## Outstanding task list

1. WIP

## Contributing

> This is work in progress **WIP** and I am happy for you to teach me what to do via a pull request.

## Resources

The resources I found very useful are:

1. [ZSH](http://zsh.sourceforge.net).
1. [holman](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).
1. [dotfiles](https://dotfiles.github.io/).
1. [dotfiles hosting](http://www.dotfiles.org/).
