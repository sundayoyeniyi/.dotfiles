#! /bin/bash
#
# systemupdates.sh

# Upgrade homebrew
echo "› brew update"
brew update

#  Mac App Store software updates
echo "› sudo softwareupdate -i -a"
sudo softwareupdate -i -a
