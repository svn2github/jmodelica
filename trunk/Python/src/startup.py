# -*- coding: utf-8 -*-
"""Default startup script for jmodelica.org

This script sets items in the 'jmodelica.environ' dictionary. The
values are set from system environment variables if defined, otherwise
to default values. Values can be overriden by a user startup script
(optional):

  $HOME/jmodelica.org/startup.py (unix)
  $HOMEPATH/jmodelica.org/startup.py (win32)

Required keys:
  'JMODELICA_HOME' : Path to JModelica.org installation directory
  'IPOPT_HOME' : Path to Ipopt installation directory
  'SUNDIALS_HOME' : Path to Sundials installation directory
  'CPPAD_HOME' : Path to Cpp_AD installation directory
  'MINGW_HOME' : Path to mingw installation directory (only win32)
  'MC_JAR' : Path to ModelicaCompiler jar file
  'OC_JAR' : Path to OptimicaCompiler jar file
  'UTIL_JAR' : Path to org.jmodelica.Util jar file
  'GRAPHS_JAR' : Path to org.jmodelica.graphs jar file
  'BEAVER_LIB' : Path to Beaver lib directory
  'CLASSPATH' : Java CLASSPATH
  'JVM_PATH' : Path to JVM dll file
  'JVM_ARGS' : JVM arguments


This script and the user startup script are executed in the jmodelica
module global namespace. Therefore, please use a leading underscore on
all names that are used, unless it is explicitly desired that they are
available in this namespace (unlikely).
"""

import os, os.path
import sys
import logging
import jpype

_jm_home = os.environ['JMODELICA_HOME']
#exception here if jm_home not found
environ = {}
environ['JMODELICA_HOME'] = _jm_home

_defaults = [('IPOPT_HOME','',True),
             ('SUNDIALS_HOME','',True),
             ('CPPAD_HOME',os.path.join(_jm_home,'ThirdParty','CppAD'),True),
             ('MC_JAR',os.path.join(_jm_home,'lib','OptimicaCompiler.jar'),True),
             ('OC_JAR',os.path.join(_jm_home,'lib','ModelicaCompiler.jar'),True),
             ('UTIL_JAR',os.path.join(_jm_home,'lib','util.jar'),True),
             ('GRAPHS_JAR',os.path.join(_jm_home,'lib','graphs.jar'),True),
             ('BEAVER_PATH',os.path.join(_jm_home,'ThirdParty','Beaver','lib'),True),
             ('MODELICAPATH',os.path.join(_jm_home,'ThirdParty','MSL'),True),
             ('JVM_PATH',jpype.getDefaultJVMPath(),True),
             ('JVM_ARGS','-Xmx512m',False)]

# Set MODELICAPATH
#os.environ['MODELICAPATH'] = os.path.join(_jm_home,'ThirdParty','MSL')

if sys.platform == 'win32':
    _defaults.append(('MINGW_HOME',os.path.join(_jm_home,'mingw'),True))

# read values for system environment if possible, otherwise set default
for _e in _defaults:
    try:
        environ[_e[0]] = os.environ[_e[0]]
    except KeyError:
        environ[_e[0]] = _e[1]
  
if sys.platform == 'win32':
    # add mingw to path (win32)
    os.environ['PATH'] = os.path.join(environ['MINGW_HOME'],'bin') + \
                         ';' + os.environ['PATH']
#else:
#    # MINGW_HOME only on win32
#    del environ['MINGW_HOME']


# set matplotlib backend
# one of GTK GTKAgg GTKCairo FltkAgg QtAgg TkAgg
# WX WXAgg Agg Cairo GD GDK Paint PS PDF SVG Template
# Qt4Agg
#matplotlib.rcParams['backend'] = 'TkAgg'
#matplotlib.rcParams['interactive'] = True

# read user startup script
if sys.platform == 'win32':
    _p = os.environ['USERPROFILE']
#    _p = os.environ['HOMEPATH']
else:
    _p = os.environ['HOME']
    
try:
    execfile(os.path.join(_p,'jmodelica.org','startup.py'))
except IOError:
    None

# check paths
for _e in _defaults:
    if _e[0] == 'MODELICAPATH':
        if sys.platform == 'win32':
            paths = environ[_e[0]].split(';') #On windows the paths are separeted with semicolons, so split.
        else:
            paths = environ[_e[0]].split(':') #On other platforms they are separeted with colons, so split.
        for p in paths:
            if _e[2] and not os.path.exists(p):
                logging.warning('%s=%s path does not exist. Environment may be corrupt.' % (_e[0],p))
    else:
        if _e[2] and not os.path.exists(environ[_e[0]]):
            if _e[0] == 'IPOPT_HOME':
                logging.warning('%s=%s path does not exist. An IPOPT installation could not be found, some modules and examples will therefore not work properly.\0' % (_e[0],environ[_e[0]]))
            elif _e[0] == 'SUNDIALS_HOME':
                logging.warning('%s=%s path does not exist. An SUNDIALS installation could not be found, some modules and examples will therefore not work properly.\0' % (_e[0],environ[_e[0]]))
            else:
                logging.warning('%s=%s path does not exist. Environment may be corrupt.' % (_e[0],environ[_e[0]]))
