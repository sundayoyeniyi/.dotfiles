#!/usr/bin/env bash
#
# Setting prompt

autoload -U colors && colors

export PS1='%B%F{blue}%n%f %F{yellow}% %/ %f
%F{blue}%#%f%F{yellow}<-->%f%b '

export RPS1='%w'
#TODO = change right prompt to state of git