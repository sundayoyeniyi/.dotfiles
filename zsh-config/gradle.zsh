#!/usr/bin/env bash
#
# Setting Gradle_Home

# Create a GRADLE_HOME variable, determined dynamically
export GRADLE_HOME=/usr/local/bin/gradle
# Add that to the global PATH variable
export PATH=${GRADLE_HOME}/bin:$PATH