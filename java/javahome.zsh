#!/usr/bin/env bash
#
# Setting Java_Home

# Create a JAVA_HOME variable, determined dynamically
#export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-11.0.2.jdk/Contents/Home
#export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/server
# Add that to the global PATH variable
export PATH=${JAVA_HOME}/bin:$PATH