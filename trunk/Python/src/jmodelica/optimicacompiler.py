""" Module containing functions for compiling Optimica models. Options which are user specific can be set
    either before importing this module by editing the file options.py or interactively by accessing
    the default options via the common module. If options are not changed the default option settings
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

#get paths to external directories: OptimicaCompiler, Beaver
_oc_jar = common._jm_home+os.sep+'lib'+os.sep+'OptimicaCompiler.jar'
_beaver_lib = common._jm_home+os.sep+'ThirdParty'+os.sep+'Beaver'+os.sep+'lib'

_dir_path="-Djava.ext.dirs=%s" %_beaver_lib
_class_path="-Djava.class.path=%s" %_oc_jar

#start JVM
if not jpype.isJVMStarted():
    jpype.startJVM(jpype.getDefaultJVMPath(),_class_path,_dir_path)
    print "JVM started."

#get java class (OptimicaCompiler)
org = jpype.JPackage('org')
OptCompiler = org.jmodelica.applications.OptimicaCompiler


def compile_model(model_file_name, model_class_name, target = "model"):
    """ Performs all steps in the compilation of a model: parsing, 
    instantiating, flattening, code generation and dll generation.
    Outputs are object file, c-code file, xml file and dll which 
    are all written to the folder in which the compilation is performed.
    All files will get the default name <model_class_name>.<ext>.
    
    @param model_file_name: 
        Path to file in which the model is contained.
    @param model_class_name:
        Name of model class in the model file to compile.
    @param target:
        Set target to specify the contents of the object file used 
        to build the .dll. Default is "model". Other two options
        are "algorithms" and "ipopt". See makefile in install folder
        for details.
        
    @raise CompilerError:
        Raised if one or more error is found during compilation.
    @raise OptimicaClassNotFoundError:
        Raised if the model class is not found.
    @raise IOError:
        Raised if the model file is not found, can not be read or
        any other IO related error.
    @raise Exception:
        Raised by the parser for general errors related to the parsing 
        of the model.       
    @raise JError:
        Raised if there was a runtime exception thrown by the underlying Java
        classes, for example, NullPointerException.
        
"""
    xml_variables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_optimica_variables_template.xml'
    xml_problvariables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_optimica_problvariables_template.xml'
    xml_values_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_values_template.xml'
    cppath = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_optimica_template.c'

    try:
        OptCompiler.compileModel(model_file_name, model_class_name, xml_variables_path, xml_problvariables_path, xml_values_path, cppath)
        c_file = model_class_name.replace('.','_',1)
        retval = compile_dll(c_file, target)
        return retval

    except jpype.JavaException, ex:
        _handle_exception(ex)


def parse_model(model_file_name):
    """ Parses a model and returns a reference to the source tree representation.
    
        @param model_file_name:
            Path to file in which the model is contained.
        @return: 
            Reference to the root of the source tree representation of the parsed model.
        
        @raise CompilerError:
            Raised if one or more error is found during compilation.
        @raise IOError:
            Raised if the model file is not found, can not be read or
            any other IO related error.
        @raise Exception:
            Raised by the parser for general errors related to the parsing 
            of the model.       
        @raise JError:
            Raised if there was a runtime exception thrown by the underlying Java
            classes, for example, NullPointerException.

    """ 
    try:
        sr = OptCompiler.parseModel(model_file_name)
        return sr
        
    except jpype.JavaException, ex:
        _handle_exception(ex)
               

def instantiate_model(source_root, model_class_name):
    """ Generates an instance tree representation for a model 
        using the source tree belonging to the model which must 
        first be created with parse_model.
        
        @see: parse_model
        
        @param source_root:
            Reference to the root of the source tree representation.
        @param model_class_name:
            Name of model class in the model file to compile.
            
        @return: Reference to the root of the instance tree representation. 
    
        @raise CompilerError:
            Raised if one or more error is found during compilation.
        @raise OptimicaClassNotFoundError:
            Raised if the model class is not found.
        @raise JError:
            Raised if there was a runtime exception thrown by the underlying Java
            classes, for example, NullPointerException.

    """
    
    try:
        ipr = OptCompiler.instantiateModel(source_root,model_class_name)
        return ipr
    
    except jpype.JavaException, ex:
        _handle_exception(ex)


def flatten_model(model_file_name, model_class_name, inst_prg_root):
    """ Computes a flattened representation of a model using the instance tree 
        belonging to the model which must first be created with instantiate_model.
        
        @see: instantiate_model
        
        @param model_file_name:
            Path to file in which the model is contained.
        @param model_class_name:
            Name of model class in the model file to compile.
        @param inst_prg_root: Reference to the instance tree representation. 
        
        @return: Object (FClass) representing the flattened model. 
    
        @raise CompilerError:
            Raised if one or more error is found during compilation.
        @raise OptimicaClassNotFoundError:
            Raised if the model class is not found.
        @raise IOError:
            Raised if the model file is not found, can not be read or
            any other IO related error.
        @raise JError:
            Raised if there was a runtime exception thrown by the underlying Java
            classes, for example, NullPointerException.

    """

    try:
        fclass = OptCompiler.flattenModel(model_file_name, model_class_name, inst_prg_root)
        return fclass
    
    except jpype.JavaException, ex:
        _handle_exception(ex)


def generate_code(fclass):
    """ Generates c and xml code for a model using the FClass represenation created
        with flatten_model and template files located in the JModelica installation folder.
        Default output folder is the current folder from which this module is run.
        
        @see: flatten_model
        
        @param fclass: Reference to the flattened model object representation.  
        
        @raise IOError:
            Raised if the model file is not found, can not be read or
            any other IO related error.
        @raise JError:
            Raised if there was a runtime exception thrown by the underlying Java
            classes, for example, NullPointerException.

    """
    xml_variables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_optimica_variables_template.xml'
    xml_problvariables_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_optimica_problvariables_template.xml'
    xml_values_path = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_values_template.xml'
    cppath = common._jm_home+os.sep+'CodeGenTemplates'+os.sep+'jmi_modelica_template.c'

    try:
        OptCompiler.generateCode(fclass, xml_variables_path, xml_values_path, cppath)
    except jpype.JavaException, ex:
        _handle_exception(ex)


def compile_dll(c_file_name, target="model"):
    """ Compiles a c code representation of a model and outputs a .dll file.
        Default output folder is the current folder from which this module is run.
        Needs a c-file which is generated with generate_code.
        
        @see: generate_code
        
        @param c_file_name:
            Name of c-file for which the .dll should be compiled without file extention.
        @param target:
            Set target to specify the contents of the object file used 
            to build the .dll. Default is "model". Other two options
            are "algorithms" and "ipopt". See makefile in install folder
            for details.
            
        @return: System return value.
      
    """
    #make settings
    make_file = common._jm_home+os.sep+'Makefiles'+os.sep+'MakeFile'
    file_name =' FILE_NAME='+c_file_name
    jmodelica_h=' JMODELICA_HOME='+common._jm_home
    cppad_h = ' CPPAD_HOME='+common.user_options['cppad_home']
    ipopt_h = ' IPOPT_HOME='+common.user_options['ipopt_home']

    cmd = 'make -f'+make_file+' '+target+file_name+jmodelica_h+cppad_h+ipopt_h

    #run make -> <model_class_name>.dll
    retval=os.system(cmd)


def _handle_exception(ex):
    """ Help function which catches and handles all expected Java Exceptions 
        that the underlying Java classes might throw.
    
    """      

    if ex.javaClass() is org.jmodelica.ast.CompilerException:
        arraylist = ex.__javaobject__.getProblems()
        itr = arraylist.iterator()

        problems = ""
        while itr.hasNext():
            problems=problems+str(itr.next())

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


class JError(Exception):
    """ Base class for exceptions specific to this module. 
    """
    def __init__(self, message):
        self.message = message
        
    def __str__(self):
        return self.message

class OptimicaClassNotFoundError(JError):
    """ Raised if the model class to be compiled can not be found.
    """
    pass

class CompilerError(JError):
    """ Raised if there were one or more errors found during compilation 
        of the model. If there are several errors in one model, they are 
        collected and presented in one CompilerError. 
    """
    pass
