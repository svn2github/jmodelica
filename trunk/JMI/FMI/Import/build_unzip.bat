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

set MINIZIP_F=%ThirdParty_F%\minizip
set ZLIB_F=C:\JModelica.org-SDK-1.6\src\JMI\src\FMIImport\zip\zlib-1.2.5

set OUT_F=%FMIImport_F%\results


REM ---- Create the results folder ----
mkdir "%OUT_F%"

REM ---- Build zlib ----
set ZS1=%ZLIB_F%\adler32.c
set ZS2=%ZLIB_F%\compress.c
set ZS3=%ZLIB_F%\crc32.c
set ZS4=%ZLIB_F%\deflate.c
set ZS5=%ZLIB_F%\gzclose.c
set ZS6=%ZLIB_F%\gzlib.c
set ZS7=%ZLIB_F%\gzread.c
set ZS8=%ZLIB_F%\gzwrite.c
set ZS9=%ZLIB_F%\infback.c
set ZS10=%ZLIB_F%\inffast.c
set ZS11=%ZLIB_F%\inflate.c
set ZS12=%ZLIB_F%\inftrees.c
set ZS13=%ZLIB_F%\trees.c
set ZS14=%ZLIB_F%\uncompr.c
set ZS15=%ZLIB_F%\zutil.c

set ZO1=%OUT_F%\adler32.obj
set ZO2=%OUT_F%\compress.obj
set ZO3=%OUT_F%\crc32.obj
set ZO4=%OUT_F%\deflate.obj
set ZO5=%OUT_F%\gzclose.obj
set ZO6=%OUT_F%\gzlib.obj
set ZO7=%OUT_F%\gzread.obj
set ZO8=%OUT_F%\gzwrite.obj
set ZO9=%OUT_F%\infback.obj
set ZO10=%OUT_F%\inffast.obj
set ZO11=%OUT_F%\inflate.obj
set ZO12=%OUT_F%\inftrees.obj
set ZO13=%OUT_F%\trees.obj
set ZO14=%OUT_F%\uncompr.obj
set ZO15=%OUT_F%\zutil.obj


cl /O2 /MT /Fo"%OUT_F%\\" /W3 /nologo /c /TC  /D "WIN32" /D "_WINDOWS" /D "NDEBUG" /D "NO_FSEEKO" /D "_CRT_SECURE_NO_DEPRECATE" /D "_CRT_NONSTDC_NO_DEPRECATE" /D "ZLIB_DLL" /D "_MBCS" "%ZS1%" "%ZS2%" "%ZS3%" "%ZS4%" "%ZS5%" "%ZS6%" "%ZS7%" "%ZS8%" "%ZS9%" "%ZS10%" "%ZS11%" "%ZS12%" "%ZS13%" "%ZS14%" "%ZS15%" /errorReport:prompt /Zm1000 

REM ---- Build minizip ----
set MS1=%MINIZIP_F%\miniunz.c
set MS2=%MINIZIP_F%\unzip.c
set MS3=%MINIZIP_F%\ioapi.c
set MS4=%MINIZIP_F%\iowin32.c
set MS5=%MINIZIP_F%\mztools.c
set MS6=%MINIZIP_F%\zip.c

set MO1=%OUT_F%\miniunz.obj
set MO2=%OUT_F%\unzip.obj
set MO3=%OUT_F%\ioapi.obj
set MO4=%OUT_F%\iowin32.obj
set MO5=%OUT_F%\mztools.obj
set MO6=%OUT_F%\zip.obj

cl /c "%MS1%" "%MS2%" "%MS3%" "%MS4%" "%MS5%" "%MS6%" /MT /I"%ZLIB_F%" /Fo"%OUT_F%\\"

REM ---- Build fmu_zip.lib ----
lib /OUT:"%OUT_F%\miniunz.lib" %ZO1% %ZO2% %ZO3% %ZO4% %ZO5% %ZO6% %ZO7% %ZO8% %ZO9% %ZO10% %ZO11% %ZO12% %ZO13% %ZO14% %ZO15% %MO1% %MO2% %MO3% %MO4% %MO5% %MO6%
