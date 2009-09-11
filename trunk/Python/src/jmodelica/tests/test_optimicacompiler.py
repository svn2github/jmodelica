""" Test module for testing the optimicacompiler module.
 
"""

import os, os.path
import sys
import nose

from jmodelica.tests import testattr

from jmodelica.compiler import OptimicaCompiler
import jmodelica as jm


jm_home = jm.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python','jmodelica','examples')

model = os.path.join('files','Pendulum_pack.mo')
fpath = os.path.join(jm_home,path_to_examples,model)
cpath = "Pendulum_pack.Pendulum_Opt"

OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
oc = OptimicaCompiler()


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
        
    oc.compile_model(fpath, cpath)
    
    fname = cpath.replace('.','_',1)
    assert os.access(fname+'_variables.xml',os.F_OK) == True, \
           fname+'_variables.xml'+" was not created."
    
    assert os.access(fname+'_values.xml', os.F_OK) == True, \
           fname+'_values.xml'+" was not created."
    
    assert os.access(fname+'_problvariables.xml', os.F_OK) == True, \
           fname+'_values.xml'+" was not created."
    
    assert os.access(fname+'.o', os.F_OK) == True, \
           fname+'.o'+" was not created."        
    
    assert os.access(fname+'.c', os.F_OK) == True, \
           fname+'.c'+" was not created."        
    
    assert os.access(fname+suffix, os.F_OK) == True, \
           fname+suffix+" was not created."        
        

@testattr(stddist = True)
def test_optimica_compile_wtarget_alg():
    """ Test that it is possible to compile (optimicacompiler.py) with target algorithms. """
    oc.compile_model(fpath, cpath, target='algorithms')
    
    
@testattr(stddist = True)
def test_optimica_compile_wtarget_ipopt():
    """ Test that it is possible to compile (optimicacompiler.py) with target ipopt. """
    oc.compile_model(fpath, cpath, target='ipopt')
    
    
@testattr(stddist = True)
def test_optimica_stepbystep():
    """ Test that it is possible to compile (optimicacompiler.py) step-by-step. """
    sourceroot = oc.parse_model(fpath)
    ipr = oc.instantiate_model(sourceroot, cpath)
    fclass = oc.flatten_model(fpath, cpath, ipr)
    oc.compile_dll(cpath.replace('.','_',1))


@testattr(stddist = True)
def test_compiler_error():
    """ Test that a CompilerError is raised if compilation errors are found in the model."""
    corruptmodel = os.path.join('files','CorruptCodeGenTests.mo')
    path = os.path.join(jm_home,path_to_examples,corruptmodel)
    cl = 'CorruptCodeGenTests.CorruptTest1'
    nose.tools.assert_raises(jm.compiler.CompilerError, oc.compile_model, path, cl)
    
    
@testattr(stddist = True)
def test_class_not_found_error():
    """ Test that an OptimicaClassNotFoundError is raised if model class is not found. """
    errorcl = 'NonExisting.OptimicaClass'
    nose.tools.assert_raises(jm.compiler.OptimicaClassNotFoundError, oc.compile_model, fpath, errorcl)


@testattr(stddist = True)
def test_IO_error():
    """ Test that an IOError is raised if the model file is not found. """          
    errormodel = os.path.join('files','NonExistingModel.mo')
    errorpath = os.path.join(jm_home,path_to_examples,errormodel)
    nose.tools.assert_raises(IOError, oc.compile_model, errorpath, cpath)


@testattr(stddist = True)
def test_setget_modelicapath():
    """ Test modelicapath setter and getter. """
    newpath = os.path.join(jm_home,'ThirdParty','MSL','Modelica')
    oc.set_modelicapath(newpath)
    nose.tools.assert_equal(oc.get_modelicapath(),newpath)
    
    
@testattr(stddist = True)
def test_setget_XMLVariablesTemplate():
    """ Test XML variables template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_variables_template.xml')
    oc.set_XMLVariablesTemplate(newtemplate)
    nose.tools.assert_equal(oc.get_XMLVariablesTemplate(), newtemplate)


@testattr(stddist = True)
def test_setget_XMLProblVariablesTemplate():
    """ Test XML variables template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_problvariables_template.xml')
    oc.set_XMLVariablesTemplate(newtemplate)
    nose.tools.assert_equal(oc.get_XMLVariablesTemplate(), newtemplate)


@testattr(stddist = True)
def test_setget_XMLValuesTemplate():
    """ Test XML values template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_modelica_values_template.xml')
    oc.set_XMLValuesTemplate(newtemplate)
    nose.tools.assert_equal(oc.get_XMLValuesTemplate(), newtemplate)


@testattr(stddist = True)
def test_setget_cTemplate():
    """ Test c template setter and getter. """
    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_template.c')
    oc.set_cTemplate(newtemplate)
    nose.tools.assert_equal(oc.get_cTemplate(), newtemplate)


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
    
