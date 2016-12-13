#! /bin/bash
#
# systeminstaller.sh

# Install developer utilities and applications
#
# TODO
# OSX - runs /system/osx/install.sh & defaults.sh & osxupdates.sh

#1. install home brew and all packages
#2. install all symlinks
#3. install all custom shell installers

#
#1. install homebrew and all packages
#

# check homebrew exists
if test ! $(which brew)
	then
		echo "Installing Homebrew ....."
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

# tap homebrew versions repository
brew tap homebrew/versions
# install brew-cask
brew install caskroom/cask/brew-cask
brew install nvm

# Installing homebrew packages
#brew install zsh
#brew install git
brew uninstall homebrew/versions/node4-lts --force
brew cask install google-chrome
brew cask install robomongo
brew cask install mysqlworkbench
brew cask install pgadmin3
brew cask install virtualbox
brew cask install vagrant
brew cask install github-desktop
brew cask install iterm2
brew cask install keepassx
brew cask install visual-studio-code --force
brew cask install evernote --force
brew cask install hipchat
brew cask install tree
brew cask install libreoffice
brew cask install sketch
brew tap homebrew/science
brew cask install xquartz
brew install r
brew cask install rstudio
#
#2. install all symlinks
#
DOTFILES_ROOT=$(pwd -P)
DOTFILES_HOME=".dotfiles"
for dotfilesymlink in $(find -H "$DOTFILES_ROOT/$DOTFILES_HOME" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dotfile="$HOME/.$(basename "${dotfilesymlink%.*}")"
    ln -s -f -v "$dotfilesymlink" "$dotfile"
  done

#
#3. install all custom shell installers
#
for shellscripts in $(find -H "$DOTFILES_ROOT/$DOTFILES_HOME" -maxdepth 2 -name '*_install.sh' -not -path '*.git*')
  do
	echo $shellscripts
	$shellscripts
  done

exit 0