@echo off
REM call "%VS90COMNTOOLS%\vsvars32.bat" 

cd "unzip11"
set OUT_F=%~dp0\tmpfolder
set ZLIB_HEADER=..\zlib-1.2.5
set ZLIB=%OUT_F%\zlib.lib


mkdir "%OUT_F%"
cl miniunz.c unzip.c ioapi.c iowin32.c mztools.c zip.c "%ZLIB%" /MT /I"%ZLIB_HEADER%" /Fo"%OUT_F%\\" "%ZLIB%"
