%GRAALVM_HOME%\bin\java ^
-agentlib:native-image-agent=config-merge-dir=META-INF/native-image ^
--add-modules ALL-MODULE-PATH ^
--module-path atomos_lib/ ^
--module org.apache.felix.atomos ^
gosh.home=.