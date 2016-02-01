#!/usr/bin/env bash
#
# Setting prompt
# color codes
# 0=black; 1=red; 2=green; 3=yellow; 4=blue; 5=magenta; 6=cyan; 7=white;

autoload -U colors && colors

export PS1='%B%F{2}[%F{1}%n%F{2}] %/
%F{4}%#%F{2}-->%f%b '

export RPS1='%w'
#TODO = change right prompt to state of git