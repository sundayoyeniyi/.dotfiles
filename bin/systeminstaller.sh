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
# tap homebrew versions repository
brew tap homebrew/versions
# install brew-cask
brew install caskroom/cask/brew-cask

# Installing homebrew packages
#brew install zsh
#brew install git
brew reinstall homebrew/versions/node4-lts --force
brew cask install google-chrome
#brew cask install firefox-developer-edition
brew cask reinstall robomongo --force
brew cask reinstall mysqlworkbench --force
brew cask reinstall pgadmin3 --force
brew cask reinstall virtualbox --force
brew cask reinstall vagrant --force
brew cask reinstall github-desktop --force
brew cask reinstall iterm2
brew cask reinstall keepassx --force
brew cask reinstall visual-studio-code --force
brew cask reinstall evernote --force
brew cask reinstall skype --force
brew cask reinstall teamviewer --force
brew cask reinstall pixate-studio --force
brew cask reinstall libreoffice --force
brew cask reinstall sketch --force
brew cask reinstall heroku-toolbelt --force
# brew cask install box-sync
# brew cask install dropbox

# R & R dependencies + RStudio (Data science and quantitative analysis)
brew tap homebrew/science
brew cask reinstall xquartz --force
brew reinstall r --force
brew cask reinstall rstudio --force

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