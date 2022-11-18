#!/bin/sh
if [ "$USAGE" = "modulepath" ] ;
then
  java $JAVA_OPTS $JAVA_OPTS_EXTRA --add-modules=ALL-MODULE-PATH,java.net.http${EXTRA_MODULES:+,$EXTRA_MODULES} -p bundles -m org.apache.felix.atomos org.osgi.framework.system.packages="" gosh.home=/app gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" org.osgi.framework.storage=configuration "$@";
else
  java $JAVA_OPTS $JAVA_OPTS_EXTRA -cp "bundles/*" org.apache.felix.atomos.Atomos gosh.home=/app gosh.args="--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start" org.osgi.framework.storage=configuration "$@";
fi