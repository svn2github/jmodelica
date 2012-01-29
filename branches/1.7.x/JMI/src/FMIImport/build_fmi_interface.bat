@echo off
setlocal
call "%VS90COMNTOOLS%\vsvars32.bat"
rem call "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86

set OUT_F=%~dp0\results
mkdir "%OUT_F%"

cd zip
call build_all.bat

cd "%~dp0c-fmi-interface"
call build_c_fmi_interface.bat
cd "%~dp0"

set C_FMI_F=%~dp0c-fmi-interface
set UNZIP_F=%~dp0zip


REM ---- Build fmi_interface.lib = c_fmi_interface.lib + miniunz.lib ----
lib /OUT:%OUT_F%\fmi_interface.lib /LIBPATH:"%UNZIP_F%" /LIBPATH:"%C_FMI_F%" miniunz.lib c_fmi_interface.lib
copy "%C_FMI_F%\fmiPlatformTypes.h" "%OUT_F%"
copy "%C_FMI_F%\c_fmi_interface_datatypes.h" "%OUT_F%"
copy "%C_FMI_F%\c_fmi_interface_me_1_0.h" "%OUT_F%"
copy "%C_FMI_F%\c_fmi_interface_cs_1_0.h" "%OUT_F%"
copy "%C_FMI_F%\c_fmi_interface_common_1_0.h" "%OUT_F%"
copy "%C_FMI_F%\c_fmi_interface.h" "%OUT_F%\fmi_interface.h"
