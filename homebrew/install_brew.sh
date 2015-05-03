# install homebrew and packages
# checks Homebrew exists and install commonly used packages

# check homebrew exists
if test ! $(which brew)
	then
		echo "Installing Homebrew ....."
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

# check brew cask exist

# TODO 

# Installing homebrew packages

# brew install mongodb
# brew install mysql
# brew install nodejs
# brew install postgresql

# Installing brew cask packages

# brew cask install robomongo
# brew cask install sequelpro
# brew cask install virtualbox
# brew cask install github
# brew cask install box / dropbox

exit 0