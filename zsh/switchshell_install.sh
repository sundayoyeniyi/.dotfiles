#! /bin/bash
#
# switchshell.sh
if test $(which zsh)
	then
       sudo  chsh -s $(which zsh)
    else
        #TODO - install zsh
        echo "installing zsh....."
    fi
