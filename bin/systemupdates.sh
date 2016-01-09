#! /usr/local/bin/zsh
#
# systemupdates.sh

# Set OS X defaults
$ZSH/osx/defaults_install.sh

# Upgrade homebrew
echo "› brew update"
brew update

#  Mac App Store software updates
echo "› sudo softwareupdate -i -a"
sudo softwareupdate -i -a