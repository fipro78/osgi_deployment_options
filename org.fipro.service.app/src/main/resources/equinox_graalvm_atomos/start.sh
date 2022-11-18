#!/bin/sh
/app/atomos $JAVA_OPTS gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" org.osgi.framework.storage=configuration "$@"