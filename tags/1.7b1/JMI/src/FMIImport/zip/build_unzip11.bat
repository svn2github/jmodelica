@echo off
REM call "%VS90COMNTOOLS%\vsvars32.bat" 
cd "%~dp0\unzip11"

setlocal
set OUT_F=%~dp0unzip11results
set ZLIB_HEADER=%~dp0zlib-1.2.5
set ZLIB_F=%~dp0zlibresults

mkdir "%OUT_F%"
cl /c miniunz.c unzip.c ioapi.c iowin32.c mztools.c zip.c /MT /I"%ZLIB_HEADER%" /Fo"%OUT_F%\\"

lib /OUT:"%OUT_F%\miniunz.lib" /NOLOGO /LIBPATH:"%OUT_F%\\" /LIBPATH:"%ZLIB_F%\\" miniunz.obj unzip.obj ioapi.obj iowin32.obj mztools.obj zip.obj zlib.lib

copy "%OUT_F%\miniunz.lib" "%~dp0"
copy "miniunz.h" "%~dp0"

cd "%~dp0"