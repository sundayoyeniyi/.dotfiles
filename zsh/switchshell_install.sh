#! /usr/local/bin/zsh
#
# switchshell.sh
if test $(which zsh)
	then
        chsh -s $(which zsh)
    else
        #TODO - install zsh
        echo "installing zsh....."
    fi