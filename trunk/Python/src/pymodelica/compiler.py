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

from pymodelica.common import xmlparser
from pymodelica.common.core import get_unit_name


def compile_fmu(class_name, file_name=[], compiler='auto', 
    target='model_fmume', compiler_options={}, compile_to='.', 
    compiler_log_level='warning'):
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
            Default: 'model_fmume'
            
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
            
    Returns::
    
        Name of the FMU which has been created.
    """
    if isinstance(file_name, basestring):
        file_name = [file_name]
        
    # get a compiler based on 'compiler' argument or files listed in file_name
    comp = _get_compiler(files=file_name, selected_compiler=compiler)
    
    # set compiler options
    comp.set_options(compiler_options)
    
    # set log level
    comp.set_compiler_log_level(compiler_log_level)
    
    # compile FMU in java
    comp.compile_FMU(class_name, file_name, target, compile_to)
    
    return os.path.join(compile_to, get_fmu_name(class_name))       


def compile_fmux(class_name, file_name=[], compiler='auto', 
                 compiler_options={}, compile_to='.', 
                 compiler_log_level='warning'):
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
            
    Returns::
    
        Name of the FMUX which has been created.
    """
    if isinstance(file_name, basestring):
        file_name = [file_name]
        
    # get a compiler based on 'compiler' argument or files listed in file_name
    comp = _get_compiler(files=file_name, selected_compiler=compiler)
    
    # set compiler options
    comp.set_options(compiler_options)
    
    # set log level
    comp.set_compiler_log_level(compiler_log_level)
    
    # compile FMU in java
    comp.compile_FMUX(class_name, file_name, compile_to)
    
    return os.path.join(compile_to, get_fmux_name(class_name))

def compile_jmu(class_name, file_name=[], compiler='auto', target='ipopt', 
    compiler_options={}, compile_to='.', compiler_log_level='warning'):
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
    
    The compiler target is 'ipopt' by default which means that libraries for AD 
    and optimization/initialization algortihms will be available as well as the 
    JMI. The other targets are:
    
        'model' -- 
            AD and JMI is included.
        'algorithm' -- 
            AD and algorithm but no Ipopt linking.
        'model_noad' -- 
            Only JMI, that is no AD interface. (Must currently be used when 
            model includes external functions.)
    
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
            
        target --
            Compiler target. 'model', 'algorithm', 'ipopt' or 'model_noad'.
            Default: 'ipopt'
            
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
                
            
    Returns::
    
        Name of the JMU which has been created.
    """
    if isinstance(file_name, basestring):
        file_name = [file_name]
        
    # get a compiler based on 'compiler' argument or files listed in file_name
    comp = _get_compiler(files=file_name, selected_compiler=compiler)
    
    # set compiler options
    comp.set_options(compiler_options)
    
    # set log level
    comp.set_compiler_log_level(compiler_log_level)
            
    # compile jmu in Java
    comp.compile_JMU(class_name, file_name, target, compile_to)
    
    return os.path.join(compile_to, get_jmu_name(class_name))

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
    
    # if selected_compiler is 'auto' - detect file suffix
    if selected_compiler == 'auto':
        comp = ModelicaCompiler()
        for f in files:
            basename, ext = os.path.splitext(f)
            if ext == '.mop':
                comp = OptimicaCompiler()
                break
    else:
        if selected_compiler.lower() == 'modelica':
            comp = ModelicaCompiler()
        elif selected_compiler.lower() == 'optimica':
            comp = OptimicaCompiler()
        else:
            logging.warning("Invalid compiler argument: "+str(compiler) + 
                ". Using OptimicaCompiler instead.")
            comp = OptimicaCompiler()
            
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
