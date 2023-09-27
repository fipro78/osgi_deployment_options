@echo off
SETLOCAL

for /l %%i in (1, 1, 10) do (
  CALL start.bat FOLDER %%i %1
)
