#!/usr/bin/env bash
#
# switchshell.sh
if test $(which zsh)
	then
        chsh -s $(which zsh)
    else
        #TODO - install zsh
    fi