"""Interfaces to the JModelica compilers

Module containing functions for compiling models. Options which are
user specific can be set either before importing this module by
editing the file options.py or interactively by accessing he default
options via the common module. If options are not changed the default
option settings will be used.

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
import subprocess
import jpype
import string
import jmodelica as jm


#start JVM
# note that startJVM() fails after shutdownJVM(), hence, only one start
if not jpype.isJVMStarted():
    _jvm_args = string.split(jm.environ['JVM_ARGS'],' ')
    _jvm_class_path = jm.environ['MC_JAR'] + os.pathsep + jm.environ['OC_JAR']+ os.pathsep + jm.environ['UTIL_JAR']
    _jvm_ext_dirs = jm.environ['BEAVER_PATH']
    jpype.startJVM(jm.environ['JVM_PATH'],
                   '-Djava.class.path=%s' % _jvm_class_path,
                   '-Djava.ext.dirs=%s' % _jvm_ext_dirs,
                   *_jvm_args)
    org = jpype.JPackage('org')
    print "JVM started."

OptionRegistry = org.jmodelica.util.OptionRegistry

class ModelicaCompiler():
    """ User class for accessing the Java ModelicaCompiler class. """
    
    ModelicaCompiler = org.jmodelica.modelica.compiler.ModelicaCompiler
    
    LOG_ERROR = ModelicaCompiler.ERROR
    LOG_WARNING = ModelicaCompiler.WARNING
    LOG_INFO = ModelicaCompiler.INFO
    
    jm_home = jm.environ['JMODELICA_HOME']
    
    xml_var_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_modelica_variables_template.xml')    
    xml_val_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_modelica_values_template.xml')
    c_tpl_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_modelica_template.c')    
    options_file_path = os.path.join(jm_home, 'Options','options.xml')

    def __init__(self):
        try:
            options = OptionRegistry(self.options_file_path)
        except jpype.JavaException, ex:
            _handle_exception(ex)
            
        options.setStringOption('MODELICAPATH',jm.environ['MODELICAPATH'])
        self._compiler = self.ModelicaCompiler(options, 
                                               self.xml_var_path, 
                                               self.xml_val_path, 
                                               self.c_tpl_path)
    @classmethod
    def set_log_level(self,level):
        self.ModelicaCompiler.setLogLevel(self.ModelicaCompiler.logger.getName(), level)
        
    def get_modelicapath(self):
        """ Returns the modelicapath set for this compiler."""
        return self._compiler.getModelicapath()
    
    def set_modelicapath(self, path):
        """ Sets the modelicapath to path. """
        self._compiler.setModelicapath(path)
        
    def get_boolean_option(self, key):
        return self._compiler.getBooleanOption(key)
    
    def set_boolean_option(self, key, value):
        self._compiler.setBooleanOption(key, value)
        
    def get_integer_option(self, key):
        return self._compiler.getIntegerOption(key)
    
    def set_integer_option(self, key, value):
        self._compiler.setIntegerOption(key, value)
        
    def get_real_option(self, key):
        return self._compiler.getRealOption(key)
    
    def set_real_option(self, key, value):
        self._compiler.setRealOption(key, value)
        
    def get_string_option(self, key):
        return self._compiler.getStringOption(key)
        
    def set_string_option(self, key, value):
        self._compiler.setStringOption(key, value)   
        
    def get_XMLVariablesTemplate(self):
        """ Returns file path to the XML variables template. """
        return self._compiler.getXMLVariablesTemplate()

    def set_XMLVariablesTemplate(self, template):
        """ Sets the XML variables template to the file pointed out by template."""
        self._compiler.setXMLVariablesTemplate(template)

    def get_XMLValuesTemplate(self):
        """ Returns file path to the XML values template. """
        return self._compiler.getXMLValuesTemplate()
    
    def set_XMLValuesTemplate(self, template):
        """ Sets the XML values template to the file pointed out by template."""
        self._compiler.setXMLValuesTemplate(template)
        
    def get_cTemplate(self):
        """ Returns file path to the c template. """
        return self._compiler.getCTemplate()
    
    def set_cTemplate(self, template):
        """ Sets the c template to the file pointed out by template."""
        self._compiler.setCTemplate(template)

    def compile_model(self,
                      model_file_name,
                      model_class_name,
                      target = "model"):
    
        """ 
        Compiles a model.

        Performs all steps in the compilation of a model: parsing,
        instantiating, flattening, code generation and dll
        generation. Outputs are object file, c-code file, xml file and
        dll which are all written to the folder in which the
        compilation is performed. All files will get the default name
        <model_class_name>.<ext>. Set target to specify the contents
        of the object file used to build the .dll. Default is"model". Other two options are 
        "algorithms" and "ipopt". See makefile in install folder for details.

        Parameters:

            model_file_name -- 
                Path to file or list of paths to files in which the model is contained.
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
        if isinstance(model_file_name, str):
            model_file_name = [model_file_name]           
        try:
            self._compiler.compileModel(model_file_name,
                                                model_class_name)
            c_file = model_class_name.replace('.','_')
            retval = self.compile_dll(c_file, target)
            return retval

        except jpype.JavaException, ex:
            _handle_exception(ex)

    def parse_model(self,model_file_name):   
        """ 
        Parses a model.

        Parses a model and returns a reference to the source tree
        representation.

        Parameters:    

            model_file_name -- 
                Path to file or list of paths to files in which the model is contained.

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
        if isinstance(model_file_name, str):
            model_file_name = [model_file_name]
        try:
            sr = self._compiler.parseModel(model_file_name)
            return sr        
        except jpype.JavaException, ex:
            _handle_exception(ex)

    def instantiate_model(self, source_root, model_class_name):
        """ 
        Generates an instance tree representation for a model.

        Generates an instance tree representation for a model using
        the source tree belonging to the model which must first be
        created with parse_model.

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
            ipr = self._compiler.instantiateModel(source_root, model_class_name)
            return ipr    
        except jpype.JavaException, ex:
            _handle_exception(ex)

    def flatten_model(self, model_file_name, model_class_name, inst_prg_root):
        """ 
        Computes a flattened representation of a model. 

        Computes a flattened representation of a model using the
        instance tree belonging to the model which must first be
        created with instantiate_model.

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
            fclass = self._compiler.flattenModel(model_file_name,
                                                 model_class_name,
                                                 inst_prg_root)
            return fclass    
        except jpype.JavaException, ex:
            _handle_exception(ex)

    def generate_code(self,fclass):
    
        """ 
        Generates code for a model.

        Generates code for a model c and xml code for a model using
        the FClass represenation created with flatten_model and
        template files located in the JModelica installation
        folder. Default output folder is the current folder from which
        this module is run.

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
        try:
            self._compiler.generateCode(fclass)
        except jpype.JavaException, ex:
            _handle_exception(ex)

    def compile_dll(self, c_file_name, target="model"):

        """ 
        Compiles a c code representation of a model.

        Compiles a c code representation of a model and outputs a .dll
        file. Default output folder is the current folder from which
        this module is run. Needs a c-file which is generated with
        generate_code.

        Parameters:
            c_file_name --
                Name of c-file for which the .dll should be compiled without file 
                extention.
            target --
                Build target.


        """
        #make settings
        make_file = os.path.join(self.jm_home, 'Makefiles', 'MakeFile')
        file_name =' FILE_NAME=' + c_file_name
        jmodelica_h =' JMODELICA_HOME=' + self.jm_home
        cppad_h = ' CPPAD_HOME=' + jm.environ['CPPAD_HOME']
        ipopt_h = ' IPOPT_HOME=' + jm.environ['IPOPT_HOME']

        if sys.platform == 'win32':
            make = os.path.join(jm.environ['MINGW_HOME'],'bin','mingw32-make') + ' -f '
            compiler = ' CXX=' + os.path.join(jm.environ['MINGW_HOME'],'bin','g++')
            ar = ' AR=' + os.path.join(os.environ['MINGW_HOME'],'bin','ar')

            cmd = make + \
                  make_file + \
                  compiler + \
                  ar + \
                  ' ' + \
                  target + \
                  file_name + \
                  jmodelica_h + \
                  cppad_h + \
                  ipopt_h
        else:
            cmd = 'make -f' + \
                  make_file + \
                  ' ' + \
                  target + \
                  file_name + \
                  jmodelica_h + \
                  cppad_h + \
                  ipopt_h

        #run make -> <model_class_name>.dll
        retcode = subprocess.call(cmd, shell=True)
        if retcode != 0:
            raise CcodeCompilationError("Retcode was: "+str(retcode))
        else:
            print >>sys.stderr, "make returned", retcode

class OptimicaCompiler(ModelicaCompiler):
    """ User class for accessing the Java OptimicaCompiler class. """

    OptimicaCompiler = org.jmodelica.optimica.compiler.OptimicaCompiler

    jm_home = jm.environ['JMODELICA_HOME']
    
    xml_var_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_optimica_variables_template.xml')    
    c_tpl_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_optimica_template.c')
    xml_prob_path = os.path.join(jm_home, 'CodeGenTemplates', 'jmi_optimica_problvariables_template.xml')

    def __init__(self):
        try:
            options = OptionRegistry(self.options_file_path)
        except jpype.JavaException, ex:
            _handle_exception(ex)
        options.setStringOption('MODELICAPATH',jm.environ['MODELICAPATH'])
        self._compiler = self.OptimicaCompiler(options, 
                                               self.xml_var_path, 
                                               self.xml_prob_path, 
                                               self.xml_val_path, 
                                               self.c_tpl_path)

    @classmethod
    def set_log_level(self,level):
        self.OptimicaCompiler.setLogLevel(self.OptimicaCompiler.logger.getName(), level)

    def get_XMLProblVariablesTemplate(self):
        """ Returns file path to the XML problem variables template. """
        return self._compiler.getXMLProblVariablesTemplate()

    def set_XMLProblVariablesTemplate(self, template):
        """ Sets the XML problem variables template to the file pointed out by template."""
        self._compiler.setXMLProblVariablesTemplate(template)


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

class OptimicaClassNotFoundError(JError):
    
    """ 
    Class for a errors raised if the Optimica model class to be compiled 
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

class CcodeCompilationError(JError):
    pass

class XPathExpressionError(JError):
    pass

class ParserConfigurationError(JError):
    pass

class SAXError(JError):
    pass

def _handle_exception(ex):
    """ Catch and handle all expected Java Exceptions that the
    underlying Java classes might throw."""
    if ex.javaClass() is org.jmodelica.modelica.compiler.CompilerException \
        or ex.javaClass() is org.jmodelica.optimica.compiler.CompilerException:
        arraylist = ex.__javaobject__.getProblems()
        itr = arraylist.iterator()
        
        problems = "\n"
        while itr.hasNext():
            problems = problems + str(itr.next()) + "\n"
            
        raise CompilerError(problems)
    
    if ex.javaClass() is org.jmodelica.modelica.compiler.ModelicaClassNotFoundException:
        raise ModelicaClassNotFoundError(str(ex.__javaobject__.getClassName()))
    
    if ex.javaClass() is org.jmodelica.optimica.compiler.ModelicaClassNotFoundException:
        raise OptimicaClassNotFoundError(str(ex.__javaobject__.getClassName()))
    
    if ex.javaClass() is jpype.java.io.FileNotFoundException:
        raise IOError('Message: '+str(ex.message())+'\n Stacktrace: '+str(ex.stacktrace()))
    
    if ex.javaClass() is jpype.java.io.IOException:
        raise IOError('Message: '+str(ex.message())+'\n Stacktrace: '+str(ex.stacktrace()))
    
    if ex.javaClass() is jpype.javax.xml.xpath.XPathExpressionException:
        raise XPathExpressionError('Message: '+str(ex.message())+'\n Stacktrace: '+str(ex.stacktrace()))
    
    if ex.javaClass() is jpype.javax.xml.parsers.ParserConfigurationException:
        raise ParserConfigurationError('Message: '+str(ex.message())+'\n Stacktrace: '+str(ex.stacktrace()))
    
#    if ex.javaClass() is jpype.org.xml.sax.SAXException:
#        raise SAXError('Message: '+ex.message()+'\n Stacktrace: '+ex.stacktrace())
    
    if ex.javaClass() is jpype.java.lang.Exception:
        raise Exception('Message: '+str(ex.message())+'\n Stacktrace: '+str(ex.stacktrace()))
    
    if ex.javaClass() is jpype.java.lang.NullPointerException:
        raise JError(str(ex.stacktrace()))
    
    raise JError(str(ex.stacktrace()))

