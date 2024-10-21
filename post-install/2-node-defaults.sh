#! /bin/zsh

echo "> node installations"

nvm install --lts

nvm use lts

echo "> global npm packages"

#npm install -g npx