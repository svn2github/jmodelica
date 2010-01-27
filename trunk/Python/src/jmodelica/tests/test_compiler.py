""" Test module for testing the compiler module.
 
"""

import os, os.path
import sys

import nose
import nose.tools

from jmodelica.tests import testattr

from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
import jmodelica as jm

jm_home = jm.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python', 'jmodelica', 'examples')

model_mc = os.path.join('files', 'Pendulum_pack_no_opt.mo')
fpath_mc = os.path.join(jm_home,path_to_examples,model_mc)
cpath_mc = "Pendulum_pack.Pendulum"

model_oc = os.path.join('files','Pendulum_pack.mo')
fpath_oc = os.path.join(jm_home,path_to_examples,model_oc)
cpath_oc = "Pendulum_pack.Pendulum_Opt"

mc = ModelicaCompiler()
ModelicaCompiler.set_log_level(ModelicaCompiler.LOG_ERROR)
mc.set_boolean_option('state_start_values_fixed',True)

oc = OptimicaCompiler()
OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
oc.set_boolean_option('state_start_values_fixed',True)

@testattr(stddist = True)
def test_compile():
    """
    Test that compilation is possible with compiler 
    and that all obligatory files are created. 
    """

    # detect platform specific shared library file extension
    suffix = ''
    if sys.platform == 'win32':
        suffix = '.dll'
    elif sys.platform == 'darwin':
        suffix = '.dylib'
    else:
        suffix = '.so'
        
    mc.compile_model(fpath_mc, cpath_mc)
    
    fname = cpath_mc.replace('.','_',1)
    assert os.access(fname+'.xml',os.F_OK) == True, \
           fname+'.xml'+" was not created."
    
    assert os.access(fname+'_values.xml', os.F_OK) == True, \
           fname+'_values.xml'+" was not created."
    
    assert os.access(fname+'.o', os.F_OK) == True, \
           fname+'.o'+" was not created."        
    
    assert os.access(fname+'.c', os.F_OK) == True, \
           fname+'.c'+" was not created."        
    
    assert os.access(fname+suffix, os.F_OK) == True, \
           fname+suffix+" was not created."        

@testattr(stddist = True)
def test_optimica_compile():
    """
    Test that compilation is possible with optimicacompiler
    and that all obligatory files are created. 
    """

    # detect platform specific shared library file extension
    suffix = ''
    if sys.platform == 'win32':
        suffix = '.dll'
    elif sys.platform == 'darwin':
        suffix = '.dylib'
    else:
        suffix = '.so'
        
    oc.compile_model(fpath_oc, cpath_oc)
    
    fname = cpath_oc.replace('.','_',1)
    assert os.access(fname+'.xml',os.F_OK) == True, \
           fname+'.xml'+" was not created."
    
    assert os.access(fname+'_values.xml', os.F_OK) == True, \
           fname+'_values.xml'+" was not created."
        
    assert os.access(fname+'.o', os.F_OK) == True, \
           fname+'.o'+" was not created."        
    
    assert os.access(fname+'.c', os.F_OK) == True, \
           fname+'.c'+" was not created."        
    
    assert os.access(fname+suffix, os.F_OK) == True, \
           fname+suffix+" was not created."       

@testattr(stddist = True)
def test_compile_wtarget_alg():
    """ Test that it is possible to compile (compiler.py) with target algorithms. """
    mc.compile_model(fpath_mc, cpath_mc, target='algorithms')
    
@testattr(stddist = True)
def test_optimica_compile_wtarget_alg():
    """ Test that it is possible to compile (optimicacompiler.py) with target algorithms. """
    oc.compile_model(fpath_oc, cpath_oc, target='algorithms')

@testattr(stddist = True)
def test_compile_wtarget_ipopt():
    """ Test that it is possible to compile (compiler.py) with target ipopt. """
    mc.compile_model(fpath_mc, cpath_mc, target='ipopt')    

@testattr(stddist = True)
def test_optimica_compile_wtarget_ipopt():
    """ Test that it is possible to compile (optimicacompiler.py) with target ipopt. """
    oc.compile_model(fpath_oc, cpath_oc, target='ipopt')

@testattr(stddist = True)
def test_stepbystep():
    """ Test that it is possible to compile (compiler.py) step-by-step. """
    sourceroot = mc.parse_model(fpath_mc)
    icd = mc.instantiate_model(sourceroot, cpath_mc)
    fclass = mc.flatten_model(icd)
    mc.compile_dll(cpath_mc.replace('.','_',1))   

@testattr(stddist = True)
def test_optimica_stepbystep():
    """ Test that it is possible to compile (optimicacompiler.py) step-by-step. """
    sourceroot = oc.parse_model(fpath_oc)
    icd = oc.instantiate_model(sourceroot, cpath_oc)
    fclass = oc.flatten_model(icd)
    oc.compile_dll(cpath_oc.replace('.','_',1))

@testattr(stddist = True)
def test_compiler_error():
    """ Test that a CompilerError is raised if compilation errors are found in the model."""
    corruptmodel = os.path.join('files','CorruptCodeGenTests.mo')
    path = os.path.join(jm_home,path_to_examples,corruptmodel)
    cl = 'CorruptCodeGenTests.CorruptTest1'
    nose.tools.assert_raises(jm.compiler.CompilerError, mc.compile_model, path, cl)
    nose.tools.assert_raises(jm.compiler.CompilerError, oc.compile_model, path, cl) 

@testattr(stddist = True)
def test_class_not_found_error():
    """ Test that a ModelicaClassNotFoundError is raised if model class is not found. """
    errorcl = 'NonExisting.Class'
    nose.tools.assert_raises(jm.compiler.ModelicaClassNotFoundError, mc.compile_model, fpath_mc, errorcl)
    nose.tools.assert_raises(jm.compiler.OptimicaClassNotFoundError, oc.compile_model, fpath_oc, errorcl)

@testattr(stddist = True)
def test_IO_error():
    """ Test that an IOError is raised if the model file is not found. """          
    errormodel = os.path.join('files','NonExistingModel.mo')
    errorpath = os.path.join(jm_home,path_to_examples,errormodel)
    nose.tools.assert_raises(IOError, mc.compile_model, errorpath, cpath_mc)
    nose.tools.assert_raises(IOError, oc.compile_model, errorpath, cpath_oc)

@testattr(stddist = True)
def test_setget_modelicapath():
    """ Test modelicapath setter and getter. """
    newpath = os.path.join(jm_home,'ThirdParty','MSL')
    mc.set_modelicapath(newpath)
    nose.tools.assert_equal(mc.get_modelicapath(),newpath)
    nose.tools.assert_equal(oc.get_modelicapath(),newpath)
    

@testattr(stddist = True)
def test_setget_XML_tpl():
    """ Test XML template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmodelica_model_description.tpl')
    mc.set_XML_tpl(newtemplate)
    nose.tools.assert_equal(mc.get_XML_tpl(), newtemplate)
    
#@testattr(stddist = True)
#def test_setget_XMLTemplate():
#    """ Test XML template setter and getter. """
#    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_variables_template.xml')
#    oc.set_XMLVariablesTemplate(newtemplate)
#    nose.tools.assert_equal(oc.get_XMLVariablesTemplate(), newtemplate)
    
@testattr(stddist = True)
def test_setget_XML_values_tpl():
    """ Test XML values template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmodelica_model_values.tpl')
    mc.set_XML_values_tpl(newtemplate)
    nose.tools.assert_equal(mc.get_XML_values_tpl(), newtemplate)

#@testattr(stddist = True)
#def test_setget_XMLValuesTemplate():
#    """ Test XML values template setter and getter. """
#    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_modelica_values_template.xml')
#    oc.set_XMLValuesTemplate(newtemplate)
#    nose.tools.assert_equal(oc.get_XMLValuesTemplate(), newtemplate)
    
@testattr(stddist = True)
def test_setget_cTemplate():
    """ Test c template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_modelica_template.c')
    mc.set_cTemplate(newtemplate)
    nose.tools.assert_equal(mc.get_cTemplate(), newtemplate)

@testattr(stddist = True)
def test_setget_cTemplate():
    """ Test c template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_template.c')
    oc.set_cTemplate(newtemplate)
    nose.tools.assert_equal(oc.get_cTemplate(), newtemplate)

@testattr(stddist = True)
def test_parse_multiple():
    """ Test that it is possible to parse two model files. """
    lib = os.path.join(jm_home,path_to_examples,'files','CSTRLib.mo')
    opt = os.path.join(jm_home,path_to_examples, 'files','CSTR2_Opt.mo')
    oc.parse_model([lib, opt])

@testattr(stddist = True)
def test_compile_multiple():
    """ Test that it is possible to compile two model files. """
    lib = os.path.join(jm_home,path_to_examples,'files','CSTRLib.mo')
    opt = os.path.join(jm_home,path_to_examples, 'files','CSTR2_Opt.mo')
    oc.compile_model([lib,opt],'CSTR2_Opt')

@testattr(stddist = True)
def test_setget_boolean_option():
    """ Test boolean option setter and getter. """
    option = 'boolean_testoption'
    setvalue = True
    # create new option
    mc.set_boolean_option(option, setvalue)
    nose.tools.assert_equal(mc.get_boolean_option(option), setvalue)
    # change value of option
    setvalue = False
    mc.set_boolean_option(option, setvalue)
    nose.tools.assert_equal(mc.get_boolean_option(option), setvalue)
    # option should be of type bool
    assert isinstance(mc.get_boolean_option(option),bool)
    
@testattr(stddist = True)
def test_setget_boolean_option_error():
    """ Test that boolean option getter raises the proper error. """
    option = 'nonexist_boolean'
    #try to get an unknown option
    nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_boolean_option, option)

@testattr(stddist = True)
def test_setget_integer_option():
    """ Test integer option setter and getter. """
    option = 'integer_testoption'
    setvalue = 10
    # create new option
    mc.set_integer_option(option, setvalue)
    nose.tools.assert_equal(mc.get_integer_option(option), setvalue)
    # change value of option
    setvalue = 100
    mc.set_integer_option(option, setvalue)
    nose.tools.assert_equal(mc.get_integer_option(option), setvalue)
    # option should be of type int
    assert isinstance(mc.get_integer_option(option),int)
    
@testattr(stddist = True)
def test_setget_integer_option_error():
    """ Test that integer option getter raises the proper error. """
    option = 'nonexist_integer'
    #try to get an unknown option
    nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_integer_option, option) 

@testattr(stddist = True)
def test_setget_real_option():
    """ Test real option setter and getter. """
    option = 'real_testoption'
    setvalue = 10.0
    # create new option
    mc.set_real_option(option, setvalue)
    nose.tools.assert_equal(mc.get_real_option(option), setvalue)
    # change value of option
    setvalue = 100.0
    mc.set_real_option(option, setvalue)
    nose.tools.assert_equal(mc.get_real_option(option), setvalue)
    # option should be of type float
    assert isinstance(mc.get_real_option(option),float)
    
@testattr(stddist = True)
def test_setget_real_option_error():
    """ Test that real option getter raises the proper error. """
    option = 'nonexist_real'
    #try to get an unknown option
    nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_real_option, option)     

@testattr(stddist = True)
def test_setget_string_option():
    """ Test string option setter and getter. """
    option = 'string_testoption'
    setvalue = 'option 1'
    # create new option
    mc.set_string_option(option, setvalue)
    nose.tools.assert_equal(mc.get_string_option(option), setvalue)
    # change value of option
    setvalue = 'option 2'
    mc.set_string_option(option, setvalue)
    nose.tools.assert_equal(mc.get_string_option(option), setvalue)
    # option should be of type str
    assert isinstance(mc.get_string_option(option),str)
    
@testattr(stddist = True)
def test_setget_string_option_error():
    """ Test that string option getter raises the proper error. """
    option = 'nonexist_real'
    #try to get an unknown option
    nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_string_option, option) 

@testattr(stddist = True)
def test_get_option_description():
    """ Test that it is possible to get a description for an option. """
    option = 'get_desc_test'
    value = 'value'
    description = 'this is the description'
    mc.set_string_option(option, value, description)
    nose.tools.assert_equal(mc.get_option_description(option),description)

@testattr(stddist = True)
def TO_ADDtest_MODELICAPATH():
    """ Test that the MODELICAPATH is loaded correctly.

    This test does currently not pass since changes of global
    environment variable MODELICAPATH does not take effect
    after OptimicaCompiler has been used a first time."""

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    jm_home = os.environ['JMODELICA_HOME']
    model = os.path.join('files','Test_MODELICAPATH.mo')
    fpath = os.path.join(curr_dir,model)
    cpath = "Test_MODELICAPATH"
    fname = cpath.replace('.','_',1)
        
    pathElSep = ''
    if sys.platform == 'win32':
        pathElSep = ';'
    else:
        pathElSep = ':'

    modelica_path = os.environ['MODELICAPATH']
    os.environ['MODELICAPATH'] = os.environ['MODELICAPATH'] + pathElSep + \
                                 os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc1') + pathElSep + \
                                 os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc2')

    comp_res = 1
    try:
        oc.compile_model(fpath, cpath, target='ipopt')
    except:
        comp_res = 0

    assert comp_res==1, "Compilation failed in test_MODELICAPATH"