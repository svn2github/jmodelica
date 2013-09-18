"""
Internal module, interface to Java classes
"""
import string
import os

import jpype

import pymodelica as pym

_jm_home = pym.environ['JMODELICA_HOME']

#start JVM
# note that startJVM() fails after shutdownJVM(), hence, only one start
if not jpype.isJVMStarted():
    _jvm_args = string.split(pym.environ['JVM_ARGS'],' ')
    _jvm_class_path = pym.environ['COMPILER_JARS']
    _jvm_ext_dirs = pym.environ['BEAVER_PATH']
    jpype.startJVM(pym.environ['JPYPE_JVM'], 
        '-Djava.class.path=%s' % _jvm_class_path, 
        '-Djava.ext.dirs=%s' % _jvm_ext_dirs,
        *_jvm_args)
    org = jpype.JPackage('org')
    print "JVM started."

# Compilers
ModelicaCompilerInterface = None
OptimicaCompilerInterface = None
if pym._modelica_class:
    ModelicaCompilerInterface = jpype.JClass(pym._modelica_class)
if pym._optimica_class:
    OptimicaCompilerInterface = jpype.JClass(pym._optimica_class)

# Options registry
OptionRegistryInterface = org.jmodelica.util.OptionRegistry

# Exceptions
UnknownOptionException = jpype.JClass(
    'org.jmodelica.util.OptionRegistry$UnknownOptionException')
    
IllegalLogStringException = org.jmodelica.util.logging.IllegalLogStringException

CompilerException = org.jmodelica.util.CompilerException
ModelicaClassNotFoundException = org.jmodelica.util.ModelicaClassNotFoundException
ModelicaCCodeCompilationException = org.jmodelica.modelica.compiler.CcodeCompilationException
OptimicaCCodeCompilationException = org.jmodelica.optimica.compiler.CcodeCompilationException

SAXException = org.xml.sax.SAXException
SAXNotRecognizedException = org.xml.sax.SAXNotRecognizedException
SAXNotSupportedException = org.xml.sax.SAXNotSupportedException
SAXParseException = org.xml.sax.SAXParseException
