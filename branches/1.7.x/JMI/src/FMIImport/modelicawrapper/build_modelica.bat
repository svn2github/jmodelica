@echo off
setlocal
call "%VS90COMNTOOLS%\vsvars32.bat"
rem call "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86


set OUT_F=%~dp0results
set C_FMI_H=..\c-fmi-interface\


mkdir "%OUT_F%"

REM ---- Build c_fmi_interface.lib ----
cl modelica_c_fmi_interface.c /c /O2 /D "WIN32" /D "NDEBUG" /D "_CRT_SECURE_NO_WARNINGS" /W3 /I "..\c-fmi-interface" /Fo"%OUT_F%\\"



lib /OUT:"%OUT_F%\modelica_c_fmi_interface.lib" "%OUT_F%\modelica_c_fmi_interface.obj" "..\results\fmi_interface.lib"
echo "hej"

copy "%C_FMI_H%\*.h" "%OUT_F%"
copy modelica_tinytest.c "%OUT_F%"
copy modelica_c_fmi_interface.h "%OUT_F%"
copy mw_FMUModel_test_model.mo "%OUT_F%"

cd "%OUT_F%"




REM ---- Build maintest.exe ----
cl modelica_tinytest.c /O2 /Oi /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_CRT_SECURE_NO_WARNINGS" /W3 /nologo modelica_c_fmi_interface.lib


