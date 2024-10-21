#!/bin/zsh

if ! command -v gcc >/dev/null; then
  echo "Installing XCode command-line tools before installing Homebrew ..."
  xcode-select --install
fi

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew - package manager for mac"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "Homebrew installation complete."
fi

upgrade_cask() {
  cask="$1"
  if ! brew list --cask --versions "$cask" &>/dev/null; then
    brew install "$cask" --cask
  else
    brew upgrade "$cask" --cask
  fi
}

upgrade_formulae() {
  formulae="$1"
  if ! brew list --versions "$formulae" &>/dev/null; then
    brew install "$formulae"
  else
    brew upgrade "$formulae"
  fi
}

brew update
brew cleanup

brew tap homebrew/cask-versions

upgrade_formulae git
upgrade_formulae gradle
upgrade_formulae maven
upgrade_formulae maven-shell
upgrade_formulae jenv
upgrade_formulae nvm
#upgrade_formulae heroku
#upgrade_formulae kubernetes-cli
#upgrade_formulae helm
upgrade_formulae kind
upgrade_formulae zsh
upgrade_formulae zsh-completions

upgrade_cask dash
upgrade_cask github
upgrade_cask teamviewer
upgrade_cask whatsapp
upgrade_cask apache-directory-studio
upgrade_cask iterm2
upgrade_cask dbeaver-community
upgrade_cask google-chrome
upgrade_cask postman
upgrade_cask docker
upgrade_cask evernote
upgrade_cask intellij-idea
upgrade_cask zoom
upgrade_cask wireshark
upgrade_cask corretto17
upgrade_cask corretto21
upgrade_cask anaconda
upgrade_cask microsoft-edge

upgrade_formulae docker-completion
upgrade_formulae docker-compose
upgrade_formulae docker-machine

brew cleanup

echo "> Post-install steps for managing non-brew installations"
export ZSH=$HOME/.dotfiles

post_install_files=($(ls $ZSH/post-install/*.sh | sort))
for file in "${post_install_files[@]}"
do
  $file
done
