@echo off
REM
REM    Copyright (C) 2009 Modelon AB
REM
REM    This program is free software: you can redistribute it and/or modify
REM    it under the terms of the GNU General Public License version 3 as published
REM    by the Free Software Foundation, or optionally, under the terms of the
REM    Common Public License version 1.0 as published by IBM.
REM
REM    This program is distributed in the hope that it will be useful,
REM    but WITHOUT ANY WARRANTY; without even the implied warranty of
REM    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM    GNU General Public License, or the Common Public License, for more details.
REM
REM    You should have received copies of the GNU General Public License
REM    and the Common Public License along with this program.  If not,
REM    see <http://www.gnu.org/licenses/> or
REM    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
REM


setlocal
call "%VS90COMNTOOLS%\vsvars32.bat"

set FMIImport_F=%~dp0
set ThirdParty_F=%~dp0..\..\..\ThirdParty

set ThirdParty_CS_1_0_F=%ThirdParty_F%\FMI\1.0-CS


set ImportDLL_F=%FMIImport_F%\DLL\include
set ImportDLL_SRC_F=%FMIImport_F%\DLL\src
set ImportDLL_COMMON_F=%ImportDLL_SRC_F%\Common
set ImportDLL_1_0_ME_F=%ImportDLL_SRC_F%\1.0-ME
set ImportDLL_1_0_CS_F=%ImportDLL_SRC_F%\1.0-CS

set OUT_F=%FMIImport_F%\results


REM ---- Create the results folder ----
mkdir "%OUT_F%"

REM ---- Build fmu_dll.lib ----
set S1="%ImportDLL_COMMON_F%\fmi_common_dll.c"
set S2="%ImportDLL_1_0_ME_F%\fmi_1_0_me_dll.c"
set S3="%ImportDLL_1_0_CS_F%\fmi_1_0_cs_dll.c"
set S4="%ImportDLL_1_0_ME_F%\fmi_1_0_me_load_fcn_dll.c"
set S5="%ImportDLL_1_0_CS_F%\fmi_1_0_cs_load_fcn_dll.c"

set H1=%ImportDLL_F%
set H2=%ImportDLL_1_0_ME_F%
set H3=%ImportDLL_1_0_CS_F%
set H4=%ThirdParty_CS_1_0_F%

set O1=%OUT_F%\fmi_common_dll.obj
set O2=%OUT_F%\fmi_1_0_me_dll.obj
set O3=%OUT_F%\fmi_1_0_cs_dll.obj
set O4=%OUT_F%\fmi_1_0_me_load_fcn_dll.obj
set O5=%OUT_F%\fmi_1_0_cs_load_fcn_dll.obj


cl /O2 /c /W3 /D "WIN32" /D "NDEBUG" /D "_CRT_SECURE_NO_WARNINGS" %S1% %S2% %S3% %S4% %S5% /I"%H1%" /I"%H2%" /I"%H3%" /I"%H4%" /Fo"%OUT_F%\\"

lib /OUT:%OUT_F%\fmu_dll.lib %O1% %O2% %O3% %O4%


