%JAVA_HOME%\bin\jlink.exe ^
--no-header-files ^
--no-man-pages ^
--module-path equinox-app.jar ^
--add-modules org.fipro.service.equinox.app ^
--launcher start=org.fipro.service.equinox.app ^
--output jlink_executable

%JAVA_HOME%\bin\jlink.exe ^
--compress=2 ^
--no-header-files ^
--no-man-pages ^
--module-path equinox-app.jar ^
--add-modules org.fipro.service.equinox.app ^
--launcher start=org.fipro.service.equinox.app ^
--output jlink_executable_compressed

%JAVA_HOME%\bin\jlink.exe ^
--no-header-files ^
--no-man-pages ^
--module-path atomos-equinox-app.jar ^
--add-modules org.fipro.service.equinox.app ^
--launcher start=org.fipro.service.equinox.app ^
--output jlink_executable

%JAVA_HOME%\bin\jlink.exe ^
--compress=2 ^
--no-header-files ^
--no-man-pages ^
--module-path atomos-equinox-app.jar ^
--add-modules org.fipro.service.equinox.app ^
--launcher start=org.fipro.service.equinox.app ^
--output jlink_executable_compressed
