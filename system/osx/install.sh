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
	# install cask
		# brew install caskroom/cask/brew-cask

# Installing homebrew packages

# brew install mongodb
# brew install mysql
# brew install node
# brew install postgresql
# brew install wget

# taps & install for Drush
# #taps for Drush
# brew tap homebrew/dupes
# brew tap homebrew/versions
# brew tap homebrew/php
# brew install drush

# Pandoc for document conversions

# brew install pandoc

# Installing brew cask packages

# brew cask install robomongo
# brew cask install sequelpro
# brew cask install mysqlworkbench
# brew cask install pgadmin3
# brew cask install virtualbox
# brew cask install vagrant
# brew cask install github
# brew cask install box-sync
# brew cask install dropbox
# brew cask install sublime-text
# brew cask install iterm2
# brew cask install keepassx
# brew cask install visual-studio-code
# brew cask install evernote
# brew cask install todoist
# brew cask install teamviewer
# brew cask install skype

# R & R dependencies + RStudio (Data science and quantitative analysis)
# brew tap homebrew/science
# brew cask install xquartz
# brew install r
# brew cask install rstudio

exit 0