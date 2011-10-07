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
Interfaces to the JModelica compilers.

Module containing functions for compiling models. Options which are user 
specific can be set either before importing this module by editing the file 
options.xml or interactively. If options are not changed the default option 
settings will be used.
"""

import os
import sys
import platform
import subprocess
import string

import jpype

import jmodelica as jm
from jmodelica import xmlparser
from jmodelica.core import list_to_string

#start JVM
# note that startJVM() fails after shutdownJVM(), hence, only one start
if not jpype.isJVMStarted():
    _jvm_args = string.split(jm.environ['JVM_ARGS'],' ')
    _jvm_class_path = jm.environ['MC_JAR'] + os.pathsep + jm.environ['OC_JAR']+\
        os.pathsep + jm.environ['UTIL_JAR'] + os.pathsep + \
        jm.environ['GRAPHS_JAR']
    _jvm_ext_dirs = jm.environ['BEAVER_PATH']
    jpype.startJVM(jm.environ['JVM_PATH'], 
        '-Djava.class.path=%s' % _jvm_class_path, 
        '-Djava.ext.dirs=%s' % _jvm_ext_dirs,
        *_jvm_args)
    org = jpype.JPackage('org')
    print "JVM started."

OptionRegistry = org.jmodelica.util.OptionRegistry

UnknownOptionException = jpype.JClass(
    'org.jmodelica.util.OptionRegistry$UnknownOptionException')

def _get_compiler(files, selected_compiler='auto'):
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
            
class ModelicaCompiler(object):
    """ 
    User class for accessing the Java ModelicaCompiler class. 
    """
    
    ModelicaCompiler = org.jmodelica.modelica.compiler.ModelicaCompiler
    
    LOG_ERROR = ModelicaCompiler.ERROR
    LOG_WARNING = ModelicaCompiler.WARNING
    LOG_INFO = ModelicaCompiler.INFO
    
    jm_home = jm.environ['JMODELICA_HOME']

    options_file_path = os.path.join(jm_home, 'Options','options.xml')


    def __init__(self, xml_template = None, xml_values_template = None, 
                 c_template = None):
        """ 
        Create a Modelica compiler. The compiler can be used to compile pure 
        Modelica models. A compiler instance can be used multiple times.
        """
        try:
            options = OptionRegistry(self.options_file_path)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
            
        options.addStringOption('MODELICAPATH',jm.environ['MODELICAPATH'])
        
        self._compiler = self.ModelicaCompiler(options, 
                                               xml_template,
                                               xml_values_template,
                                               c_template)
            
    @classmethod
    def set_log_level(self,level):
        """ 
        Set the level of log messages. Valid options are 
        ModelicaCompiler.LOG_ERROR, ModelicaCompiler.LOG_WARNING and 
        ModelicaCompiler.LOG_INFO. They will print, errors only, both errors and 
        warnings and all log messages respectively.
        
        Parameters::
        
            level --
                Level of log messages to set. Valid options are 
                ModelicaCompiler.LOG_ERROR, ModelicaCompiler.LOG_WARNING and 
                ModelicaCompiler.LOG_INFO.
        """
        self.ModelicaCompiler.setLogLevel(self.ModelicaCompiler.log, level)

    @classmethod
    def get_log_level(self):
        """ 
        Get the current level of log messages set. 
        
        Returns::
        
            The current level of log messages.
        """
        return self.ModelicaCompiler.getLogLevel(self.ModelicaCompiler.log)
    
    
    def set_options(self, compiler_options):
        # set compiler options
        for key, value in compiler_options.iteritems():
            if isinstance(value, bool):
                self.set_boolean_option(key, value)
            elif isinstance(value, basestring):
                self.set_string_option(key,value)
            elif isinstance(value, int):
                self.set_integer_option(key,value)
            elif isinstance(value, float):
                self.set_real_option(key,value)
            elif isinstance(value, list):
                self.set_string_option(key, list_to_string(value))
            else:
                raise JMIException("Unknown compiler option type for key: %s. \
                Should be of the following types: boolean, string, integer, \
                float or list" %key)

    def set_compiler_log_level(self, compiler_log_level):
        # set compiler log level
        if compiler_log_level.lower().startswith('w'):
            self.set_log_level(ModelicaCompiler.LOG_WARNING)
        elif compiler_log_level.lower().startswith('e'):
            self.set_log_level(ModelicaCompiler.LOG_ERROR)
        elif compiler_log_level.lower().startswith('i'):
            self.set_log_level(ModelicaCompiler.LOG_INFO)
        else:
            logging.warning("Invalid compiler_log_level: "+str(compiler_log_level) + 
            " using level 'warning' instead.")

        
    def get_modelicapath(self):
        """ 
        Get the path to Modelica libraries set for this compiler.
        
        Returns::
        
            Path to Modelica libraries set.
        """
        return self._compiler.getModelicapath()
    
    def set_modelicapath(self, path):
        """ 
        Set the path to Modelica libraries for this compiler instance. 
        
        Parameters::
        
            path --
                The path to Modelica libraries.
        """
        self._compiler.setModelicapath(path)

    def get_boolean_option(self, key):
        """ 
        Get the boolean option set for the specific key. 
        
        Parameters::
        
            key --
                Get the boolean option for this key.
        """
        try:
            option = self._compiler.getBooleanOption(key)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        return bool(option)
    
    def set_boolean_option(self, key, value):
        """ 
        Set the boolean option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the boolean option.
                
            value --
                Boolean option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setBooleanOption(key, value)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        
    def get_integer_option(self, key):
        """ 
        Get the integer option set for the specific key. 
        
        Parameters::
        
            key --
                Get the integer option for this key.
        """
        try:
            option = self._compiler.getIntegerOption(key)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        return option
    
    def set_integer_option(self, key, value):
        """ 
        Set the integer option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the integer option.
                
            value --
                Integer option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setIntegerOption(key, value)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        
    def get_real_option(self, key):
        """ 
        Get the real option set for the specific key. 
        
        Parameters::
        
            key --
                Get the real option for this key.
        """
        try:
            option = self._compiler.getRealOption(key)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        return option
    
    def set_real_option(self, key, value):
        """ 
        Set the real option with key to value. If the option does not exist an 
        exception will be raised.
        
        Parameters::
        
            key --
                Key for the real option.
                
            value --
                Real option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setRealOption(key, value)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
                    
    def get_string_option(self, key):
        """ 
        Get the string option set for the specific key. 
        
        Parameters::
        
            key --
                Get the string option for this key.
        """
        try:
            option = self._compiler.getStringOption(key)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        return str(option)
        
    def set_string_option(self, key, value):
        """ 
        Set the string option with key to value. If the option does not exist an 
        exception will be raised.
        
        Parameters::
        
            key --
                Key for the string option.
                
            value --
                String option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setStringOption(key, value)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
    
    def get_XML_tpl(self):
        """ 
        Get the file path to the XML model description template.
        
        Returns::
        
            The file path for the XML model description template.
        """
        return self._compiler.getXMLTpl()

    def set_XML_tpl(self, template):
        """ 
        Set the XML model description template to the file pointed out by 
        template.
        
        Parameters::
        
            template --
                The new XML model description template.
        
        """
        self._compiler.setXMLTpl(template)

    def get_XML_values_tpl(self):
        """ 
        Get the file path to the XML model values template. 
        
        Returns::
        
            The file path for the XML model values template.
        """
        return self._compiler.getXMLValuesTpl()
    
    def set_XML_values_tpl(self, template):
        """ 
        Set the XML values template to the file pointed out by template.
        
        Parameters::
        
            template --
                The new XML model values template.
        
        """
        self._compiler.setXMLValuesTpl(template)
        
    def get_cTemplate(self):
        """ 
        Get the file path to the c code template. 
        
        Returns::
        
            The file path for the c code template.
        """
        return self._compiler.getCTemplate()
    
    def set_cTemplate(self, template):
        """ 
        Set the c code template to the file pointed out by template.
        
        Parameters::
        
            template --
                The new c code template.
        """
        self._compiler.setCTemplate(template)
        
        
    def compile_JMU(self, class_name, file_name, target, compile_to):
        """
        Compiles a model (parsing, instantiating, flattening, code generation 
        and binary file generation) and creates a JMU on the file system. Set 
        target to specify the contents of the object file used to build the 
        binary. The options are "model", "model_noad", "algorithms" and "ipopt". 
        See makefile in install folder for details on the different targets.
        
        Parameters::
        
            class_name --
                Name of model class in the model file to compile.
            
            file_name --
                Path to file or list of paths to files in which the model is 
                contained.
                
            target --
                The build target. Valid options are 'model', 'model_noad', 
                'algorithms' and 'ipopt'.
                
            compile_to --
                Specify location of the compiled JMU. Directory will be created 
                if it does not exist.
        """
        try:
            self._compiler.compileJMU(class_name, file_name, target, compile_to)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
        
    def compile_FMU(self, class_name, file_name, target, compile_to):
        """
        Compiles a model (parsing, instantiating, flattening, code generation 
        and binary file generation) and creates an FMU on the file system. Set 
        target to specify the contents of the object file used to build the 
        binary. The options are "model", "model_noad", "algorithms" and "ipopt". 
        See makefile in install folder for details on the different targets.
        
        Note: target must currently be set to 'model_noad'.
        
        Parameters::
        
            class_name --
                Name of model class in the model file to compile.
            
            file_name --
                Path to file or list of paths to files in which the model is 
                contained.
                
            target --
                The build target. Valid options are 'model', 'model_noad', 
                'algorithms' and 'ipopt'.
                Note: Must currently be set to 'model_noad'.
                
            compile_to --
                Specify location of the compiled FMU. Directory will be created 
                if it does not exist.
        """
        try:
            self._compiler.compileFMU(class_name, file_name, target, compile_to)
        except jpype.JavaException, ex:
            self._handle_exception(ex)

    def compile_FMUX(self, class_name, file_name, compile_to):
        """
        Compiles a model (parsing, instantiating, flattening and XML code 
        generation) and creates an FMUX on the file system.
        
        Parameters::
        
            class_name --
                Name of model class in the model file to compile.
            
            file_name --
                Path to file or list of paths to files in which the model is 
                contained.
                
            compile_to --
                Specify location of the compiled FMUX. Directory will be created 
                if it does not exist.
        """
        try:
            self._compiler.compileFMUX(class_name, file_name, compile_to)
        except jpype.JavaException, ex:
            self._handle_exception(ex)

    def parse_model(self,model_file_name):   
        """ 
        Parse a model.

        Parse a model and return a reference to the source tree representation.

        Parameters::
            
            model_file_name -- 
                Path to file or list of paths to files in which the model is 
                contained.

        Returns::
        
            Reference to the root of the source tree representation of the 
            parsed model.

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            IOError if the model file is not found, can not be read or any other 
            IO related error.
            
            Exception if there are general errors related to the parsing of the 
            model.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """        
        if isinstance(model_file_name, basestring):
            model_file_name = [model_file_name]
        try:
            sr = self._compiler.parseModel(model_file_name)
            return sr        
        except jpype.JavaException, ex:
            self._handle_exception(ex)

    def instantiate_model(self, source_root, model_class_name):
        """ 
        Generate an instance tree representation for a model.

        Generate an instance tree representation for a model using the 
        source tree belonging to the model which must first be created 
        with parse_model.

        Parameters::
          
            source_root -- 
                Reference to the root of the source tree representation.
                
            model_class_name -- 
                Name of model class in the model file to compile.

        Returns::
        
            Reference to the instance AST node representing the model instance. 

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            ModelicaClassNotFoundError if the model class is not found.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """    
        try:
            ipr = self._compiler.instantiateModel(source_root, model_class_name)
            return ipr    
        except jpype.JavaException, ex:
            self._handle_exception(ex)

    def flatten_model(self, inst_class_decl):
        """ 
        Compute a flattened representation of a model. 

        Compute a flattened representation of a model using the instance tree 
        belonging to the model which must first be created with 
        instantiate_model.

        Parameters::
          
            inst_class_decl -- 
                Reference to a model instance. 

        Returns::
        
            Object (FClass) representing the flattened model. 

        Raises::
        
            CompilerError if one or more error is found during compilation.
            
            ModelicaClassNotFoundError if the model class is not found.
            
            IOError if the model file is not found, can not be read or any 
            other IO related error.
            
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """
        try:
            fclass = self._compiler.flattenModel(inst_class_decl)
            return fclass    
        except jpype.JavaException, ex:
            self._handle_exception(ex)

    def generate_code(self,fclass):
        """ 
        Generate code for a model.

        Generate code for a model c and xml code for a model using the FClass 
        represenation created with flatten_model and template files located in 
        the JModelica installation folder. Default output folder is the current 
        folder from which this module is run.

        Parameters::
        
            fclass -- 
                Reference to the flattened model object representation.  

        Raises::
        
            IOError if the model file is not found, can not be read or any other 
            IO related error.
                
            JError if there was a runtime exception thrown by the underlying 
            Java classes.
        """
        try:
            self._compiler.generateCode(fclass)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
            
    def _handle_exception(self, ex):
        """ 
        Catch and handle all expected Java Exceptions that the 
        underlying Java classes might throw. Raises an appropriate Python error 
        or the default JError.
        """
        if ex.javaClass() is org.jmodelica.modelica.compiler.CompilerException \
            or ex.javaClass() is org.jmodelica.optimica.compiler.CompilerException:
            arraylist = ex.__javaobject__.getProblems()
            itr = arraylist.iterator()

            compliance_errors = []
            errors = []
            warnings = []
            while itr.hasNext():
                p = str(itr.next())
                if p.count('Compliance error')>0:
                    compliance_errors.append(p)
                elif p.count('Warning')>0:
                    warnings.append(p)
                else:
                    errors.append(p)
                    
            raise CompilerError(errors,compliance_errors,warnings)
        
        if ex.javaClass() is \
            org.jmodelica.modelica.compiler.ModelicaClassNotFoundException:
            raise ModelicaClassNotFoundError(
                str(ex.__javaobject__.getClassName()))
        
        if ex.javaClass() is \
            org.jmodelica.optimica.compiler.ModelicaClassNotFoundException:
            raise OptimicaClassNotFoundError(
                str(ex.__javaobject__.getClassName()))
        
        if ex.javaClass() is jpype.java.io.FileNotFoundException:
            raise IOError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.io.IOException:
            raise IOError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.javax.xml.xpath.XPathExpressionException:
            raise XPathExpressionError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.javax.xml.parsers.ParserConfigurationException:
            raise ParserConfigurationError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is org.xml.sax.SAXException or \
            ex.javaClass() is org.xml.sax.SAXNotRecognizedException or \
            ex.javaClass() is org.xml.sax.SAXNotSupportedException or \
            ex.javaClass() is org.xml.sax.SAXParseException:
            raise SAXError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
    
        if ex.javaClass() is UnknownOptionException:
            raise UnknownOptionError(
                ex.message().encode('utf-8')+'\nStacktrace: '+\
                    ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.lang.Exception:
            raise Exception(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is jpype.java.lang.NullPointerException:
            raise JError(ex.stacktrace().encode('utf-8'))
        
        if ex.javaClass() is \
            org.jmodelica.modelica.compiler.CcodeCompilationException or \
            ex.javaClass() is \
            org.jmodelica.optimica.compiler.CcodeCompilationException:
            raise CcodeCompilationError(
                '\nMessage: '+ex.message().encode('utf-8')+\
                '\nStacktrace: '+ex.stacktrace().encode('utf-8'))
        
        raise JError(ex.stacktrace().encode('utf-8'))

class OptimicaCompiler(ModelicaCompiler):
    """ 
    User class for accessing the Java OptimicaCompiler class. 
    """

    OptimicaCompiler = org.jmodelica.optimica.compiler.OptimicaCompiler

    jm_home = jm.environ['JMODELICA_HOME']

    def __init__(self, xml_template = None, xml_values_template = None, 
                 c_template = None, optimica_c_template = None):
        """ 
        Create an Optimica compiler. The compiler can be used to compile both 
        Modelica and Optimica models. A compiler instance can be used multiple 
        times.
        """
        try:
            options = OptionRegistry(self.options_file_path)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
            
        options.addStringOption('MODELICAPATH',jm.environ['MODELICAPATH'])
        
        self._compiler = self.OptimicaCompiler(options,
                                               xml_template,
                                               xml_values_template,
                                               c_template,
                                               optimica_c_template)

    @classmethod
    def set_log_level(self,level):
        """ 
        Set the level of log messages. Valid options are 
        OptimicaCompiler.LOG_ERROR, OptimicaCompiler.LOG_WARNING and 
        OptimicaCompiler.LOG_INFO. They will print, errors only, both errors and 
        warnings and all log messages respectively.
        
        Parameters::
        
            level --
                Level of log messages to set. Valid options are 
                OptimicaCompiler.LOG_ERROR, OptimicaCompiler.LOG_WARNING 
                and OptimicaCompiler.LOG_INFO.
        """
        self.OptimicaCompiler.setLogLevel(self.OptimicaCompiler.log, level)

    @classmethod
    def get_log_level(self):
        """ 
        Get the current level of log messages set. 
        
        Returns::
        
            The current level of log messages.
        """
        return self.OptimicaCompiler.getLogLevel(self.ModelicaCompiler.log)

    def set_boolean_option(self, key, value):
        """ 
        Set the boolean option with key to value. If the option does not exist 
        an exception will be raised. 
        
        Parameters::
        
            key --
                Key for the boolean option.
                
            value --
                Boolean option.
                
        Raises::
        
            UnknownOptionError if the options does not exist.
        """
        try:
            self._compiler.setBooleanOption(key, value)
        except jpype.JavaException, ex:
            self._handle_exception(ex)
              

class JError(Exception):
    """ 
    Base class for exceptions specific to this module.
    """
    
    def __init__(self, message):
        """ 
        Create new error with a specific message. 
        
        Parameters::
        
            message --
                The error message.
        """
        self.message = message
        
    def __str__(self):
        """ 
        Print error message when class instance is printed.
         
        Override the general-purpose special method such that a string 
        representation of an instance of this class will be the error message.
        
        Returns::
        
            The error message.
        """
        return self.message

class ModelicaClassNotFoundError(JError):
    """ 
    Class for errors raised if the Modelica model class to be compiled can not 
    be found.
    """
    pass

class OptimicaClassNotFoundError(JError):
    """ 
    Class for a errors raised if the Optimica model class to be compiled can not 
    be found.
    """ 
    pass


class CompilerError(JError):
    """ 
    Class representing a compiler error. Raised if there were one or more errors 
    found during compilation of the model. If there are several errors in one 
    model, they are collected and presented in one CompilerError.
    """

    def __init__(self, errors, compliance_errors, warnings):
        """ 
        Create CompilerError with a list of error messages. 
        """
        self.compliance_errors = compliance_errors
        self.warnings = warnings
        self.errors = errors
        
    def __str__(self):
        """ 
        Print error messages.
         
        Override the general-purpose special method such that a string 
        representation of an instance of this class will a string representation
        of the error messages.
        """
    
        problems = '\n' + str(len(self.errors)) + ' error(s), ' + \
            str(len(self.compliance_errors)) + ' compliance error(s) and ' + \
            str(len(self.warnings)) + ' warning(s) found:\n\n' 
        for e in self.errors:
            problems = problems + e + "\n\n"
        for ec in self.compliance_errors:
            problems = problems + ec + "\n\n"
        for w in self.warnings:
            problems = problems + w + "\n\n"
        
        return problems

class CcodeCompilationError(JError):
    """ 
    Class for errors thrown when compiling a binary file from c code.
    """
    pass

class XPathExpressionError(JError):
    """ 
    Class representing errors in XPath expressions. 
    """
    pass

class ParserConfigurationError(JError):
    """ 
    Class for errors thrown when configuring XML parser. 
    """
    pass

class SAXError(JError):
    """ 
    Class representing a SAX error. 
    """
    pass

class UnknownOptionError(JError):
    """ 
    Class for error thrown when trying to access unknown compiler option. 
    """
    pass
    
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
