@echo off
setlocal
call "%VS90COMNTOOLS%\vsvars32.bat"

REM ---- Build tinytest.exe----

cd "tinytest"
copy "tinytest.c" "..\results"

cd "..\results"
dir
echo %cd%

cl "tinytest.c" /O2 /Oi /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_CRT_SECURE_NO_WARNINGS" /W3 /nologo fmi_interface.lib /I "%cd%"

cd "%~dp0"