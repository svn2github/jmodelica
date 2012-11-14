#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Module containing convenience functions for compiling models. Options which 
are user specific can be set either before importing this module by editing 
the file options.xml or interactively. If options are not changed the default 
option settings will be used.
"""

import os
import sys
import platform
import logging
from subprocess import check_call, STDOUT

import pymodelica as pym
from pymodelica.common import xmlparser
from pymodelica.common.core import get_unit_name


def compile_fmu(class_name, file_name=[], compiler='auto', target='fmume', 
                compiler_options={}, compile_to='.', compiler_log_level='warning',
                separate_process=False, jvm_args=''):
    """ 
    Compile a Modelica model to an FMU.
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
        - Default compiler setting is 'auto' which means that the appropriate 
          compiler will be selected based on model file ending, i.e. 
          ModelicaCompiler if a .mo file and OptimicaCompiler if a .mop file is 
          found in file_name list.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
    The compiler target is 'model_fmume' by default which means that the shared 
    file contains the FMI for Model Exchange API. This is currently the only 
    target that is possible to use.
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries. Supports only be .mo files.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model. The different options are:
              - 'auto': the compiler is selected automatically depending on 
                 file ending
              - 'modelica': the ModelicaCompiler is used
              - 'optimica': the OptimicaCompiler is used
            Default: 'auto'
            
        target --
            Compiler target.
            Default: 'fmume'
            
        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify location of the compiled FMU. Directory will be created if 
            it does not exist.
            Default: Current directory.

        compiler_log_level --
            Set the log level for the compiler. Valid options are 'warning'/'w', 
            'error'/'e' or 'info'/'i'.
            Default: 'warning'
        
        separate_process --
            Run the compilation of the model in a separate proecss. Requires 
            the environment variable SEPARATE_PROCESS_JVM to be set.
            Default: False
            
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
            
            
    Returns::
    
        Name of the FMU which has been created.
    """
    return _compile_unit(class_name, file_name, compiler, target, 
                compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args)       

def compile_fmux(class_name, file_name=[], compiler='auto', compiler_options={}, 
                 compile_to='.', compiler_log_level='warning', separate_process=False,
                 jvm_args=''):
    """ 
    Compile a Modelica model to an FMUX.
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be to files or libraries
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries. Supports both be .mo and .mop files.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model.
            Default: 'auto'
            
        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify location of the compiled FMUX. Directory will be created if 
            it does not exist.
            Default: Current directory.

        compiler_log_level --
            Set the log level for the compiler. Valid options are 'warning'/'w', 
            'error'/'e' or 'info'/'i'.
            Default: 'warning'
        
        separate_process --
            Run the compilation of the model in a separate proecss. Requires 
            the environment variable SEPARATE_PROCESS_JVM to be set.
            Default: False
            
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
            
    Returns::
    
        Name of the FMUX which has been created.
    """
    return _compile_unit(class_name, file_name, compiler, 'fmux', 
                compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args)

def compile_jmu(class_name, file_name=[], compiler='auto', compiler_options={}, 
                compile_to='.', compiler_log_level='warning', separate_process = False,
                jvm_args=''):
    """ 
    Compile a Modelica or Optimica model to a JMU.
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
        - Default compiler is ModelicaCompiler.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be for files or libraries
        - Default compiler setting is 'auto' which means that the appropriate 
          compiler will be selected based on model file ending, i.e. 
          ModelicaCompiler if .mo file and OptimicaCompiler if a .mop file is 
          found in file_name list.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries. Supports both be .mo and .mop files.
            Default: Empty list.
            
        compiler -- 
            'auto' if a compiler should be selected automatically depending on 
            file ending, 'modelica' if a ModelicaCompiler should be used or 
            'optimica' if a OptimicaCompiler should be used.
            Default: 'auto' (i.e. depends on argument file_name)
            
        compiler_options --
            Options for the compiler.
            Default: Empty dict.
            
        compile_to --
            Specify location of the compiled JMU. Directory will be created if 
            it does not exist.
            Default: Current directory.
            
        compiler_log_level --
            Set the log level for the compiler. Valid options are 'warning'/'w', 
            'error'/'e' or 'info'/'i'.
            Default: 'warning'
        
        separate_process --
            Run the compilation of the model in a separate proecss. Requires 
            the environment variable SEPARATE_PROCESS_JVM to be set.
            Default: False
            
        jvm_args --
            String of arguments to be passed to the JVM when compiling in a 
            separate process.
            Default: Empty string
                
            
    Returns::
    
        Name of the JMU which has been created.
    """
    return _compile_unit(class_name, file_name, compiler, 'jmu', 
                compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args)

def _compile_unit(class_name, file_name, compiler, target, 
                compiler_options, compile_to, compiler_log_level,
                separate_process, jvm_args):
    """
    Helper function for compile_fmu, compile_jmu and compile_fmux.
    """
    if isinstance(file_name, basestring):
        file_name = [file_name]
        
    if not separate_process:   
        # get a compiler based on 'compiler' argument or files listed in file_name
        comp = _get_compiler(files=file_name, selected_compiler=compiler)
        # set compiler options
        comp.set_options(compiler_options)
        
        # set log level
        comp.set_compiler_log_level(compiler_log_level)
        
        # compile unit in java
        if (target.find('fmume') >= 0 or target.find('fmucs') >= 0): 
            comp.compile_FMU(class_name, file_name, target, compile_to)
        elif target.find('jmu') >= 0:
            comp.compile_JMU(class_name, file_name, compile_to)
        elif target.find('fmux') >= 0:
            comp.compile_FMUX(class_name, file_name, compile_to)
        else:
            raise Exception("Model unit (FMU/JMU/FMUX) could not be extracted from the target: %s" %(target))
    else:
        compile_separate_process(class_name, file_name, compiler, target, compiler_options, 
                                 compile_to, compiler_log_level, jvm_args)

    return os.path.join(compile_to, _get_unit_name_from_target(class_name, target))

def compile_separate_process(class_name, file_name=[], compiler='auto', target='fmume', compiler_options={}, 
                             compile_to='.', compiler_log_level='warning', jvm_args=''):
    """
    Compile model in separate process.
    Requires environment variable SEPARATE_PROCESS_JVM to be set, otherwise defaults
    to JAVA_HOME.
    
    class_name -- 
        The name of the model class.
        
    file_name -- 
        A path (string) or paths (list of strings) to model files and/or 
        libraries. Supports only be .mo files.
        Default: Empty list.
        
    compiler -- 
        The compiler used to compile the model. The different options are:
          - 'auto': the compiler is selected automatically depending on 
             file ending
          - 'modelica': the ModelicaCompiler is used
          - 'optimica': the OptimicaCompiler is used
        Default: 'auto'
        
    target --
        Compiler target. Valid options are 'fmume', 'fmucs', 'fmux' or 'jmu'.
        Default: 'fmume'
        
    compiler_options --
        Options for the compiler.
        Default: Empty dict.
        
    compile_to --
        Specify location of the compiled FMU. Directory will be created if 
        it does not exist.
        Default: Current directory.

    compiler_log_level --
        Set the log level for the compiler. Valid options are 'warning'/'w', 
        'error'/'e' or 'info'/'i'.
        Default: 'warning'
    
    jvm_args --
        String of arguments to be passed to the JVM when compiling in a 
        separate process.
        Default: Empty string
    """
    JVM_PATH = _get_separate_JVM()
        
    JAVA_CLASS_PATH = pym.environ['COMPILER_JARS'] + os.pathsep + os.path.join(pym.environ['BEAVER_PATH'],'beaver.jar')
 
    comp = _which_compiler(file_name, compiler)
    if comp is 'MODELICA':
        COMPILER = pym._modelica_class
    else: 
        COMPILER = pym._optimica_class
    
    if jvm_args:
        JVM_ARGS = jvm_args
    else:
        JVM_ARGS = pym.environ['JVM_ARGS']
        
    LOG = '-log=' + _gen_log_level(compiler_log_level)

    OPTIONS = '-opt=' + _gen_compiler_options(compiler_options)
    
    TARGET = "-" + target
    
    MODEL_FILES = ",".join(file_name)
    
    MODELICA_CLASS = class_name
        
    # create cmd
    if compiler_options:
        cmd = [JVM_PATH, "-cp", JAVA_CLASS_PATH, COMPILER, JVM_ARGS, LOG, OPTIONS, TARGET, MODEL_FILES, MODELICA_CLASS]
    else:
        cmd = [JVM_PATH, "-cp", JAVA_CLASS_PATH, COMPILER, JVM_ARGS, LOG, TARGET, MODEL_FILES, MODELICA_CLASS]
        
    check_call(cmd, stderr=STDOUT)

def _gen_compiler_options(compiler_options):
    """
    Helper function. Takes compiler options dict and generates a string with 
    options so the Java compiler understands it.
    """
    # Save in opts in the form: opt1:val1,opt2:val2
    opts = ','.join(['%s:%s' %(k, v) for k, v in compiler_options.iteritems()])
    # Convert all Python True/False to Java true/false
    opts = opts.replace('True', 'true')
    opts = opts.replace('False', 'false')
    return opts
    
def _gen_log_level(log_level):
    """
    Helper function. Takes log level as accepted by Python and generates a string
    which is understood by the Java compiler.
    """
    if log_level[0] in ('i', 'w', 'e', 'd'):
        return log_level[0]
    else:
        logging.warning("Log level %s is not allowed. Using the default log level \"error\" instead." %(log_level))
        return 'e'
        
    
def _get_separate_JVM():
    """
    Helper function to get the path of the JVM to use for compiling in a separate 
    process.
    """
    # Check if SEPARATE_PROCESS_JVM is set, otherwise return with an error
    separate_jvm = ''
    try:
        separate_jvm = os.environ['SEPARATE_PROCESS_JVM']
    except KeyError:
        try:
            logging.warning("The environment variable SEPARATE_PROCESS_JVM is not set. Trying JAVA_HOME instead.")
            separate_jvm = os.environ['JAVA_HOME']
        except KeyError:
            raise Exception("Neither SEPARATE_PROCESS_JVM nor JAVA_HOME is not set. Can not start the JVM.")
    # Check that SEPARATE_PROCESS_JVM points at a jvm.dll/JRE/JDK
    # Accepted paths:
    # Full path to java.exe
    # <JDK home>
    # <JRE home>
    separate_jvm = _ensure_path(separate_jvm, os.path.join('bin', 'java.exe'))
    
    # Check that path exist
    # First make sure that all path separators are correct
    if not os.path.isfile(separate_jvm):
        raise Exception("The jvm.dll path %s does not exist." %(separate_jvm))
 
    return separate_jvm

def _ensure_path(start, end):
    """
    Helper function for building the correct path to a JVM. Handled cases:
    - Full path to Java.exe
    - Path to JDK home
    - Path to JVM home
    """
    if start.endswith(end):
        return start
    endparts = end.split(os.path.sep)
    for e in endparts:
        if start.endswith(e):
            continue
        else:
            start = os.path.join(start, e)
            
    return start


def _get_unit_name_from_target(class_name, target):
   """
   Helper method to get unit file ending from compiler target.
   """
   # compile unit in java
   if (target.find('fmume') >=0 or target.find('fmucs') >= 0): 
       return get_fmu_name(class_name)
   elif target.find('jmu') >= 0:
       return get_jmu_name(class_name)
   elif target.find('fmux') >= 0:
       return get_fmux_name(class_name)
   else:
       raise Exception("Could not extract unit type from target %s" %(target))
    
def get_jmu_name(class_name):
    """
    Computes the JMU name from a class name.
    
    Parameters::
        
        class_name -- 
            The name of the model.
        
    Returns::
    
        The JMU name (replaced dots with underscores).
    """
    return get_unit_name(class_name, unit_type='JMU')

def get_fmu_name(class_name):
    """
    Computes the FMU name from a class name.
    
    Parameters::
        
        class_name -- 
            The name of the model.
        
    Returns::
    
        The FMU name (replaced dots with underscores).
    """
    return get_unit_name(class_name, unit_type='FMU')

def get_fmux_name(class_name):
    """
    Computes the FMUX name from a class name.
    
    Parameters::
        
        class_name -- 
            The name of the model.
        
    Returns::
    
        The FMUX name (replaced dots with underscores).
    """
    return get_unit_name(class_name, unit_type='FMUX')

def _get_compiler(files, selected_compiler='auto'):
    from compiler_wrappers import ModelicaCompiler, OptimicaCompiler
    
    comp = _which_compiler(files, selected_compiler)
    if comp is 'MODELICA':
        return ModelicaCompiler()
    else:
        return OptimicaCompiler()
            
    return comp

def _which_compiler(files, selection_mode='auto'):
    # if selection_mode is 'auto' - detect file suffix
    if selection_mode == 'auto':
        comp = 'MODELICA'
        for f in files:
            basename, ext = os.path.splitext(f)
            if ext == '.mop':
                comp = 'OPTIMICA'
                break
    else:
        if selection_mode.lower() == 'modelica':
            comp = 'MODELICA'
        elif selection_mode.lower() == 'optimica':
            comp = 'OPTIMICA'
        else:
            logging.warning("Invalid compiler selected: %s using OptimicaCompiler instead." %(selection_mode))
            comp = 'OPTIMICA'
            
    return comp     
    
def _get_platform():
    """ 
    Helper function. Returns string describing the platform on which jmodelica 
    is run. 
    
    Possible return values::
        
        win32
        win64
        darwin32
        darwin64
        linux32
        linux64
    """
    _platform = ''
    if sys.platform == 'win32':
        # windows
        _platform = 'win'
    elif sys.platform == 'darwin':
        # mac
        _platform = 'darwin'
    else:
        # assume linux
        _platform = 'linux'
    
    (bits, linkage) =  platform.architecture()
    if bits == '32bit':
        _platform = _platform +'32'
    else:
        _platform = _platform + '64'
    
    return _platform
