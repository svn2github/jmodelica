"""
Module containing functions for compiling models. Options which are user specific can be set
either before importing this module by editing the file options.py or interactively by accessing
he default options via the common module. If options are not changed the default option settings
will be used.

"""

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


import os
import sys

import jpype

import common

#start JVM
if not jpype.isJVMStarted():
    jvm_args = common._parse_jvm_args(common.user_options['jvm_args'])
    jpype.startJVM(jpype.getDefaultJVMPath(),common._class_path,common._dir_path, tuple(jvm_args))
    print "JVM started."

#get java class (ModelicaCompiler)
org = jpype.JPackage('org')
JCompiler = org.jmodelica.modelica.compiler.ModelicaCompiler

#constants
LOG_ERROR = JCompiler.ERROR
LOG_WARNING = JCompiler.WARNING
LOG_INFO = JCompiler.INFO

def compile_model(model_file_name, model_class_name, target = "model"):
    
    """ 
    Compiles a model.
    
    Performs all steps in the compilation of a model: parsing, instantiating, 
    flattening, code generation and dll generation. Outputs are object file, 
    c-code file, xml file and dll which are all written to the folder in which 
    the compilation is performed. All files will get the default name 
    <model_class_name>.<ext>. Set target to specify the contents of the object 
    file used to build the .dll. Default is "model". Other two options are 
    "algorithms" and "ipopt". See makefile in install folder for details.
    
    Parameters:
    
        model_file_name -- 
            Path to file in which the model is contained.
        model_class_name -- 
            Name of model class in the model file to compile.
        target -- 
            The build target.
        
    Exceptions:
        
        CompilerError -- 
            Raised if one or more error is found during compilation.
        ModelicaClassNotFoundError -- 
            If the model class is not found.
        IOError -- 
            If the model file is not found, can not be read or any other IO 
            related error.
        Exception -- 
            If there are general errors related to the parsing of the model.       
        JError -- 
            If there was a runtime exception thrown by the underlying Java 
            classes.
            
    """
        
    xml_variables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_variables_template.xml'
    xml_values_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_values_template.xml'
    cppath = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_template.c'

    try:
        JCompiler.compileModel(model_file_name, model_class_name, xml_variables_path, xml_values_path, cppath)
        c_file = model_class_name.replace('.','_')
        retval = compile_dll(c_file, target)
        return retval

    except jpype.JavaException, ex:
        _handle_exception(ex)

def parse_model(model_file_name):   
    """ 
    Parses a model.
    
    Parses a model and returns a reference to the source tree representation.
    
    Parameters:    
    
        model_file_name -- 
            Path to file in which the model is contained.
            
    Return:
 
        Reference to the root of the source tree representation of the parsed 
        model.
    
    Exceptions:
        
        CompilerError --
            If one or more error is found during compilation.
        IOError --
            If the model file is not found, can not be read or any other IO 
            related error.
        Exception --
            If there are general errors related to the parsing of the model.       
        JError -- 
            If there was a runtime exception thrown by the underlying Java 
            classes.
            
    """ 
    try:
        sr = JCompiler.parseModel(model_file_name)
        return sr        
    except jpype.JavaException, ex:
        _handle_exception(ex)
               
def instantiate_model(source_root, model_class_name):
    """ 
    Generates an instance tree representation for a model.
    
    Generates an instance tree representation for a model using the source 
    tree belonging to the model which must first be created with parse_model.
        
    Parameters:   
        
        source_root -- 
            Reference to the root of the source tree representation.
        model_class_name -- 
            Name of model class in the model file to compile.
    
    Returns:
    
        Reference to the root of the instance tree representation. 
    
    Exceptions:
    
        CompilerError -- 
            If one or more error is found during compilation.
        ModelicaClassNotFoundError -- 
            If the model class is not found.
        JError --
            If there was a runtime exception thrown by the underlying Java 
            classes.
            
    """    
    try:
        ipr = JCompiler.instantiateModel(source_root,model_class_name)
        return ipr    
    except jpype.JavaException, ex:
        _handle_exception(ex)

def flatten_model(model_file_name, model_class_name, inst_prg_root):
    """ 
    Computes a flattened representation of a model. 
    
    Computes a flattened representation of a model using the instance tree 
    belonging to the model which must first be created with instantiate_model.
        
    Parameters:  
        
        model_file_name --
            Path to file in which the model is contained.
        model_class_name --
            Name of model class in the model file to compile.
        inst_prg_root -- 
            Reference to the instance tree representation. 
    
    Returns:
    
        Object (FClass) representing the flattened model. 
    
    Exceptions:
    
        CompilerError --
            If one or more error is found during compilation.
        ModelicaClassNotFoundError --
            If the model class is not found.
        IOError --
            If the model file is not found, can not be read or any other IO 
            related error.
        JError -- 
            If there was a runtime exception thrown by the underlying Java 
            classes.

    """
    try:
        fclass = JCompiler.flattenModel(model_file_name, model_class_name, inst_prg_root)
        return fclass    
    except jpype.JavaException, ex:
        _handle_exception(ex)

def generate_code(fclass):
    
    """ 
    Generates code for a model.
    
    Generates code for a model c and xml code for a model using the FClass 
    represenation created with flatten_model and template files located in 
    the JModelica installation folder. Default output folder is the current 
    folder from which this module is run.
        
    Parameters:
        
        fclass -- 
            Reference to the flattened model object representation.  
        
    Exceptions:
    
        IOError -- 
            If the model file is not found, can not be read or any other IO 
            related error.
        JError --
            If there was a runtime exception thrown by the underlying Java 
            classes.
            
    """

    xml_variables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_variables_template.xml'
    xml_values_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_values_template.xml'
    cppath = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_template.c'

    try:
        JCompiler.generateCode(fclass, xml_variables_path, xml_values_path, cppath)
    except jpype.JavaException, ex:
        _handle_exception(ex)

def compile_dll(c_file_name, target="model"):

    """ 
    Compiles a c code representation of a model.
    
    Compiles a c code representation of a model and outputs a .dll file. Default 
    output folder is the current folder from which this module is run. Needs a 
    c-file which is generated with generate_code.
        
    Parameters:
        
        c_file_name --
            Name of c-file for which the .dll should be compiled without file 
            extention.
        target --
            Build target.

    Returns:
            
        System return value. 
            
    """

    #make settings
    make_file = common._jm_home+os.sep+'Makefiles'+os.sep+'MakeFile'
    file_name =' FILE_NAME='+c_file_name
    jmodelica_h=' JMODELICA_HOME='+common._jm_home
    cppad_h = ' CPPAD_HOME='+common._jm_home+os.sep+'ThirdParty'+os.sep+'CppAD'
    ipopt_h = ' IPOPT_HOME='+common.user_options['ipopt_home']

    cmd = 'make -f'+make_file+' '+target+file_name+jmodelica_h+cppad_h+ipopt_h

    #run make -> <model_class_name>.dll
    retval=os.system(cmd)
    return retval

def set_log_level(level):
    JCompiler.setLogLevel(JCompiler.logger.getName(), level)

def _handle_exception(ex):
    """ Catch and handle all expected Java Exceptions that the underlying Java classes might throw. """
    if ex.javaClass() is org.jmodelica.ast.CompilerException:
        arraylist = ex.__javaobject__.getProblems()
        itr = arraylist.iterator()

        problems = "\n"
        while itr.hasNext():
            problems=problems+str(itr.next())+"\n"

        raise CompilerError(problems)
        
    if ex.javaClass() is org.jmodelica.ast.ModelicaClassNotFoundException:
        raise ModelicaClassNotFoundError(str(ex.__javaobject__.getClassName()))
        
    if ex.javaClass() is jpype.java.io.FileNotFoundException:
        raise IOError(ex.message())
        
    if ex.javaClass() is jpype.java.io.IOException:
        raise IOError(ex.message())           

    if ex.javaClass() is jpype.java.lang.Exception:
        raise Exception(ex.message())
    
    if ex.javaClass() is jpype.java.lang.NullPointerException:
        raise JError(str(ex.stacktrace()))

    raise JError(str(ex.stacktrace()))

class JError(Exception):
    
    """ Base class for exceptions specific to this module."""
    
    def __init__(self, message):
        """ Create new error with a specific message. """
        self.message = message
        
    def __str__(self):
        """ 
        Print error message when class instance is printed.
         
        Overrides the general-purpose special method such that a string 
        representation of an instance of this class will be the error message.
        
        """
        return self.message

class ModelicaClassNotFoundError(JError):
    
    """ 
    Class for a errors raised if the Modelica model class to be compiled 
    can not be found.
    
    """
    
    pass

class CompilerError(JError):
    
    """ 
    Class representing a compiler error. Raised if there were one or more errors 
    found during compilation of the model. If there are several errors in one 
    model, they are collected and presented in one CompilerError.
    
    """

    pass

