#!/bin/sh
if [ "$USAGE" = "modulepath" ] ;
then
  java $JAVA_OPTS --add-modules=ALL-MODULE-PATH,java.net.http -p bundles -m org.apache.felix.atomos org.osgi.framework.system.packages="" gosh.home=/app gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" "$@";
else
  java $JAVA_OPTS -cp "bundles/*" org.apache.felix.atomos.Atomos gosh.home=/app gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" "$@";
fi