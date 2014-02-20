#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys
import platform
from casadi import *
from modelicacasadi_wrapper import *
JVM_SET_UP=False


def transfer_to_casadi_interface(class_name, file_name=[], compiler='auto', 
                compiler_options={}, compiler_log_level='warning'):
    """ 
    Compiles and transfers a model or optimization problem to the ModelicaCasADi 
    interface. 
    
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
    
        
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
            
        compiler -- 
            The compiler used to compile the model. The different options are:
              - 'auto': the compiler is selected automatically depending on 
                 file ending
              - 'modelica': the ModelicaCompiler is used
              - 'optimica': the OptimicaCompiler is used
            Default: 'auto'
            
        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'
                  
    Returns::
    
        A Model or OptimizationProblem, dependent on which compiler
        that was used. 
    
    """
    if isinstance(file_name, basestring):
        file_vec = [file_name]
    else: 
        file_vec = file_name
    
    # JVM can only be set up once. SetUpJVM fails after tearDownJVM. 
    global JVM_SET_UP
    if not JVM_SET_UP:
        setUpJVM()
        JVM_SET_UP=True
        
    if _which_compiler(file_vec, compiler) == "MODELICA":
        return _transfer_modelica(class_name, _generate_StringVector(file_vec),
                                  _get_options(compiler_options),
                                  compiler_log_level)
    else:
        return _transfer_optimica(class_name, _generate_StringVector(file_vec),
                                  _get_options(compiler_options),
                                  compiler_log_level)


def _generate_StringVector(file_vec):
    string_file_vec = StringVector()
    for f_i in file_vec:
        string_file_vec.push_back(f_i)
    return string_file_vec

def _transfer_modelica(class_name, files, options, log_level):
	return modelicacasadi_wrapper._transferXmlModel(class_name, files)
    #return modelicacasadi_wrapper._transferModelicaModel(class_name, files, options, log_level)
    
def _transfer_optimica(class_name, files, options, log_level):
    return modelicacasadi_wrapper._transferOptimizationProblem(class_name, files, options, log_level)


def _get_options(compiler_options):
    """
    Generate an instance of the CompilerOptionsWrapper class
    for ModelicaCasADi. 

    Note that MODELICAPATH is set to the standard for this
    installation if not given as an option.

    Parameters::

        compiler_options --
            A dict of options where the key specifies which option to modify 
            and the value the new value for the option.

    Returns::

        CompilerOptionsWrapper --
            
    """
    options_wrapper = CompilerOptionsWrapper()

    if not compiler_options.has_key("MODELICAPATH"):
        options_wrapper.addStringOption("MODELICAPATH", os.path.join(os.environ['JMODELICA_HOME'],'ThirdParty','MSL'))
    else:
        options_wrapper.addStringOption("MODELICAPATH", compiler_options["MODELICAPATH"])

    # set compiler options
    for key, value in compiler_options.iteritems():
        if isinstance(value, bool):
            options_wrapper.setBooleanOption(key, value)
        elif isinstance(value, basestring):
            options_wrapper.setStringOption(key,value)
        elif isinstance(value, int):
            options_wrapper.setIntegerOption(key,value)
        elif isinstance(value, float):
            options_wrapper.setRealOption(key,value)
        elif isinstance(value, list):
            options_wrapper.setStringOption(key, _list_to_string(value))
    return options_wrapper

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
            print ("Invalid compiler selected: %s using OptimicaCompiler instead." %(selection_mode))
            comp = 'OPTIMICA'      
    return comp     

def _list_to_string(item_list):
    """
    Helper function that takes a list of items, which are typed to str and 
    returned as a string with the list items separated by platform dependent 
    path separator. For example: 
        (platform = win)
        item_list = [1, 2, 3]
        return value: '1;2;3'
    """
    ret_str = ''
    for l in item_list:
        ret_str =ret_str+str(l)+os.pathsep
    return ret_str
