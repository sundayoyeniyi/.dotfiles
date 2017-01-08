#!/usr/bin/env bash
#
# Setting Java_Home

export JAVA_HOME=$(/usr/libexec/java_home)
export LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/server