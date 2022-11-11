#!/bin/sh
java $JAVA_OPTS $JAVA_OPTS_EXTRA -Dgosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" -Dgosh.home=/app -jar org.eclipse.osgi-3.17.200.jar "$@"