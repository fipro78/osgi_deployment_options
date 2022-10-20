@echo off
setlocal

REM %1 = APPID, %2 = execution id, %3 clean (optional)

IF "%3"=="clean" (SET clean=-Dorg.osgi.framework.storage.clean=onFirstInit)

FOR /F "delims=" %%A IN ('powershell.exe -NoLogo -NoProfile -Command "[DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()"') DO (SET "THETIME=%%~A")

java -Dbenchmark.appid=%1 -Dbenchmark.executionid=%2 -Dbenchmark.starttime=%THETIME% %clean% -jar org.eclipse.osgi-3.17.200.jar -console
