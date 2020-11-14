#!/bin/zsh

if ! command -v gcc >/dev/null; then
  echo "Installing XCode command-line tools before installing Homebrew ..."
  xcode-select --install
fi

if test ! $(which brew)
  then
    echo "Installing Homebrew - package manager for mac"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

upgrade_cask() {
  cask="$1"
  if ! brew list --cask --versions "$cask" &>/dev/null; then
    brew cask install "$cask"
  else
    brew upgrade --cask "$cask"
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

brew tap adoptopenjdk/openjdk

upgrade_formulae git
upgrade_formulae gradle
upgrade_formulae maven
upgrade_formulae maven-shell
upgrade_formulae jenv
upgrade_formulae nvm
upgrade_formulae heroku
upgrade_formulae doctl
upgrade_formulae awscli
upgrade_formulae aws-shell
upgrade_formulae ansible
upgrade_formulae minikube
upgrade_formulae kompose
upgrade_formulae skaffold
upgrade_formulae hashicorp/tap/terraform
#upgrade_formulae zsh
#upgrade_formulae zsh-completions

upgrade_cask dash
upgrade_cask github
upgrade_cask teamviewer
upgrade_cask whatsapp
upgrade_cask apache-directory-studio
upgrade_cask firefox-developer-edition
upgrade_cask iterm2
upgrade_cask dbeaver-community
upgrade_cask google-chrome
upgrade_cask kafka-tool
upgrade_cask postman
upgrade_cask docker
upgrade_cask evernote
upgrade_cask intellij-idea
upgrade_cask virtualbox
upgrade_cask zoomus
upgrade_cask wireshark
upgrade_cask keepassx
upgrade_cask adoptopenjdk8
upgrade_cask adoptopenjdk9
upgrade_cask adoptopenjdk10
upgrade_cask adoptopenjdk11
upgrade_cask adoptopenjdk12
upgrade_cask adoptopenjdk13
upgrade_cask adoptopenjdk14
upgrade_cask adoptopenjdk15
upgrade_cask anaconda

upgrade_formulae docker-completion
upgrade_formulae docker-compose
upgrade_formulae docker-compose-completion
upgrade_formulae docker-machine

brew cleanup