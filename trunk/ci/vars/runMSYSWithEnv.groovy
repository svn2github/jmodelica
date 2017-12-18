def call(command, extraBat="", sdk_home="C:\\JModelica.org-SDK-1.13\\") {
    writeFile file:'run.sh', text:"""\
#!/bin/bash
cd "${unixpath(pwd())}"
${command}
"""
        bat """\
${extraBat}
set WORKSPACE=${pwd()}
IF NOT DEFINED JMODELICA_HOME set JMODELICA_HOME=%WORKSPACE%/install
set SDK_HOME=${sdk_home}
call %SDK_HOME%\\setenv.bat
%SDK_HOME%\\MinGW\\msys\\1.0\\bin\\sh --login "${pwd()}\\run.sh"
"""
    }