@echo off
rem call "%VS90COMNTOOLS%\vsvars32.bat"
rem call "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86

setlocal

set OUT_F=%~dp0\results
set MINIUNZ_H=%~dp0..\zip
mkdir "%OUT_F%"

REM ---- Setup Source files and Object files ----
set C_F=%~dp0
set C_S=%C_F%\c_fmi_unzip.c %C_F%\c_fmi_interface_me_1_0.c %C_F%\c_fmi_interface_cs_1_0.c %C_F%\c_fmi_interface_common_1_0.c

set O_F=%OUT_F%
set O_S=%O_F%\c_fmi_unzip.obj %O_F%\c_fmi_interface_me_1_0.obj %O_F%\c_fmi_interface_cs_1_0.obj %O_F%\c_fmi_interface_common_1_0.obj

REM ---- Build c_fmi_interface.lib ----
cl %C_S% /c /O2 /D "WIN32" /D "NDEBUG" /D "_CRT_SECURE_NO_WARNINGS" /W3 /I "%MINIUNZ_H%" /Fo"%OUT_F%\\"
lib /OUT:%OUT_F%\c_fmi_interface.lib %O_S%
copy "%OUT_F%\c_fmi_interface.lib" "%~dp0"