@echo off
REM call "%VS90COMNTOOLS%\vsvars32.bat"

cd "zlib-1.2.5"
setlocal
set OUT_F=%~dp0zlibresults
set C_F=.
set C_S=%C_F%\adler32.c %C_F%\compress.c %C_F%\crc32.c %C_F%\deflate.c %C_F%\gzclose.c %C_F%\gzlib.c %C_F%\gzread.c %C_F%\gzwrite.c %C_F%\infback.c %C_F%\inffast.c %C_F%\inflate.c %C_F%\inftrees.c %C_F%\trees.c %C_F%\uncompr.c %C_F%\zutil.c

mkdir "%OUT_F%"

set OBJ_F=%OUT_F%
set OBJ_S=%OBJ_F%\adler32.obj %OBJ_F%\compress.obj %OBJ_F%\crc32.obj %OBJ_F%\deflate.obj %OBJ_F%\gzclose.obj %OBJ_F%\gzlib.obj %OBJ_F%\gzread.obj %OBJ_F%\gzwrite.obj %OBJ_F%\infback.obj %OBJ_F%\inffast.obj %OBJ_F%\inflate.obj %OBJ_F%\inftrees.obj %OBJ_F%\trees.obj %OBJ_F%\uncompr.obj %OBJ_F%\zutil.obj

cl %C_S% /O2 /D "WIN32" /D "_WINDOWS" /D "NDEBUG" /D "NO_FSEEKO" /D "_CRT_SECURE_NO_DEPRECATE" /D "_CRT_NONSTDC_NO_DEPRECATE" /D "ZLIB_DLL" /D "_MBCS"  /MT /Fo"%OUT_F%\\" /W3 /nologo /c /TC /errorReport:prompt /Zm1000 

lib /OUT:"%OUT_F%\zlib.lib" /NOLOGO %OBJ_S%
