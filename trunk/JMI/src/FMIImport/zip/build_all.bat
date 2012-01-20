@echo off

call "%VS90COMNTOOLS%\vsvars32"

call build_zlib.bat
cd %~dp0
call build_unzip11.bat
cd %~dp0

