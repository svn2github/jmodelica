@echo off

REM call "%VS90COMNTOOLS%\vsvars32"

cd %~dp0
call build_zlib.bat
cd %~dp0
call build_unzip11.bat
cd %~dp0

