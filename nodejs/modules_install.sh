#! /bin/bash
#
# installing latest nodejs version
nvm install 6.7.0
nvm use 6.7.0
nvm alias default 6.7.0
# Global nodejs modules
npm install -g eslint
npm install -g tslint
npm install -g typescript
npm install -g gulp
npm install -g mocha
npm install -g node-inspector
npm install -g bower
npm install -g browser-sync