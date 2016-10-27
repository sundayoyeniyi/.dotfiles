#! /bin/bash
#
# systeminstaller.sh

# Install developer utilities and applications

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

# brew update
brew update
brew cleanup
brew cask cleanup
# tap homebrew versions repository
brew tap homebrew/versions
# install brew-cask
brew install caskroom/cask/brew-cask

# Installing homebrew packages
#brew install zsh
#brew install git
brew install homebrew/versions/node6-lts
brew cask install google-chrome
brew cask install robomongo
brew cask install mysqlworkbench
brew cask install pgadmin4
brew cask install virtualbox
brew cask install vagrant
brew cask install github-desktop
brew cask install iterm2
brew cask install keepassx
brew cask install visual-studio-code
brew cask install evernote
brew cask install skype
brew cask install teamviewer
brew cask install pixate-studio
brew cask install libreoffice
brew cask install sketch
brew cask install heroku-toolbelt
# brew cask install box-sync
# brew cask install dropbox

# R & R dependencies + RStudio (Data science and quantitative analysis)
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