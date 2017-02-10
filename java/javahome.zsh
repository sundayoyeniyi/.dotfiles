#!/usr/bin/env bash
#
# Setting Java_Home

# Create a JAVA_HOME variable, determined dynamically
export JAVA_HOME=$(/usr/libexec/java_home)
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/server
# Add that to the global PATH variable
export PATH=${JAVA_HOME}/bin:$PATH
# Add the Android SDK to the PATH variable
export PATH=${PATH}:~/Library/Android/sdk/tools:~/Library/Android/sdk/platform-tools