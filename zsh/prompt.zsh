#!/usr/bin/env bash
#
# Setting prompt

autoload -U colors && colors

export PS1='%B%F{red}%n%f %F{green}% %/ %f
%F{blue}%#%f%F{green}-->%f%b '

export RPS1='%w'
#TODO = change right prompt to state of git