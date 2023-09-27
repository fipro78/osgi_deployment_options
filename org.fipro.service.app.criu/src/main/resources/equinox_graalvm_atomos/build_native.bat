%GRAALVM_HOME%\bin\native-image ^
-o atomos ^
--no-server ^
--no-fallback ^
--initialize-at-build-time=org.apache.felix.atomos ^
--initialize-at-build-time=org.apache.felix.service.command.Converter ^
--class-path ^
atomos_lib/api-1.0.0-SNAPSHOT.jar;^
atomos_lib/benchmark-1.0.0-SNAPSHOT.jar;^
atomos_lib/command-1.0.0-SNAPSHOT.jar;^
atomos_lib/configurable-1.0.0-SNAPSHOT.jar;^
atomos_lib/eventhandler-1.0.0-SNAPSHOT.jar;^
atomos_lib/impl-1.0.0-SNAPSHOT.jar;^
atomos_lib/org.apache.felix.atomos-1.0.0.jar;^
atomos_lib/org.apache.felix.configadmin-1.9.24.jar;^
atomos_lib/org.apache.felix.gogo.command-1.1.2.jar;^
atomos_lib/org.apache.felix.gogo.runtime-1.1.6.jar;^
atomos_lib/org.apache.felix.gogo.shell-1.1.4.jar;^
atomos_lib/org.apache.felix.scr-2.2.0.jar;^
atomos_lib/org.eclipse.equinox.event-1.6.100.jar;^
atomos_lib/org.eclipse.osgi-3.17.200.jar;^
atomos_lib/org.osgi.namespace.implementation-1.0.0.jar;^
atomos_lib/org.osgi.service.event-1.4.1.jar;^
atomos_lib/org.osgi.util.function-1.2.0.jar;^
atomos_lib/org.osgi.util.promise-1.2.0.jar;^
atomos_lib/osgi.annotation-8.1.0.jar;^
atomos_lib/osgi.core-8.0.0-AtomosEquinox.jar^
--verbose ^
-H:ConfigurationFileDirectories=native-image-resources ^
-H:+ReportUnsupportedElementsAtRuntime ^
-H:+ReportExceptionStackTraces ^
org.apache.felix.atomos.Atomos