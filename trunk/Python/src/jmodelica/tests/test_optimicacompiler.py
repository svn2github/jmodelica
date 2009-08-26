""" Test module for testing the optimicacompiler module.
 
"""

import os
import sys
import nose

from jmodelica.compiler import OptimicaCompiler
import jmodelica as jm

jm_home = jm.environ['JMODELICA_HOME']
path_to_examples = os.sep+'Python'+os.sep+'jmodelica'+os.sep+'examples'

model = os.sep+'files'+os.sep+'Pendulum_pack.mo'
fpath = jm_home+path_to_examples+model
cpath = "Pendulum_pack.Pendulum_Opt"

OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
oc = OptimicaCompiler()
   
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
        
    assert oc.compile_model(fpath, cpath) == 0, \
           "Compiling "+cpath+" failed."
    
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
        

def test_optimica_compile_wtarget_alg():
    """ Test that it is possible to compile (optimicacompiler.py) with target algorithms. """
    assert oc.compile_model(fpath, cpath, target='algorithms') == 0, \
           "Compiling "+cpath+" with target=algorithms failed."
    
def test_optimica_compile_wtarget_ipopt():
    """ Test that it is possible to compile (optimicacompiler.py) with target ipopt. """
    assert oc.compile_model(fpath, cpath, target='ipopt') == 0, \
           "Compiling "+cpath+" with target=ipopt failed."
    
def test_optimica_stepbystep():
    """ Test that it is possible to compile (optimicacompiler.py) step-by-step. """
    sourceroot = oc.parse_model(fpath)
    ipr = oc.instantiate_model(sourceroot, cpath)
    fclass = oc.flatten_model(fpath, cpath, ipr)
    assert oc.compile_dll(cpath.replace('.','_',1)) == 0, \
           "Compiling dll failed."

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
    
