#!/bin/zsh

#command prompt aliases
alias ll='ls -lrt'
alias la='ls -lart'
alias hi=history

#homebrew aliases
alias bd='brew doctor'
alias bu='brew update'
alias bi='brew install'
alias bs='brew search'

#git aliases
alias gi='git init'
alias gc='git clone'
alias gb='git branch'
alias gs='git status -sb'
alias ga='git add -a'
alias gcm='git commit -m'
alias gpl='git pull'
alias gps='git push'
alias gf='git fetch'
alias gl='git log'
alias gplm='git pull origin master'
alias gplgm='git pull github master'
alias gphm='git push origin master'
alias gphgm='git push github master'
alias grv='git remote -v'

#gradlew aliases
alias gcb='./gradlew clean build'
alias gab='./gradlew application:bootRun'
alias gstart='./gradlew startserver'
alias grestart='./gradlew restartserver'
alias gstop='./gradlew stopserver'
