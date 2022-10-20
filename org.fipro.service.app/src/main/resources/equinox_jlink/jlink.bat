C:\Development\JDK\OpenJDK\jdk-17.0.3+7\bin\jlink.exe ^
--compress=2 ^
--no-header-files ^
--no-man-pages ^
--module-path atomos_equinox.jar ^
--add-modules equinox.app ^
--launcher start=equinox.app ^
--output jlink_executable_compressed
 
C:\Development\JDK\OpenJDK\jdk-17.0.3+7\bin\jlink.exe ^
--no-header-files ^
--no-man-pages ^
--module-path atomos_equinox.jar ^
--add-modules equinox.app ^
--launcher start=equinox.app ^
--output jlink_executable
