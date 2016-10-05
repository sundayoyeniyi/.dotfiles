#! /bin/bash
#
# installing latest nodejs version
nvm install 6.7.0
nvm use 6.7.0
nvm alias default 6.7.0

# Global nodejs modules
npm uninstall -g eslint
npm install -g tslint
npm install -g typescript
npm install -g typings
npm install -g gulp
npm install -g mocha
npm install -g node-inspector
npm install -g bower
npm install -g jasmine
npm install -g karma-cli
npm install -g npm
npm install -g watch
npm install -g babel-cli
npm install -g browserify
npm install -g express-generator
npm install -g strongloop
npm install -g angular-cli