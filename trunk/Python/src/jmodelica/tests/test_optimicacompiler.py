""" Test module for testing the optimicacompiler module.
 
"""

import os

import nose

import jmodelica.optimicacompiler as oc


jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.sep+'Python'+os.sep+'jmodelica'+os.sep+'examples'

model = os.sep+'pendulum'+os.sep+'Pendulum_pack.mo'
fpath = jm_home+path_to_examples+model
cpath = "Pendulum_pack.Pendulum_Opt"

oc.set_log_level(oc.LOG_ERROR)
   
def test_optimica_compile():
    """
    Test that compilation is possible and that all
    obligatory files are created. 
    """
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
    
    assert os.access(fname+'.dll', os.F_OK) == True, \
           fname+'.dll'+" was not created."        
        

def test_optimica_compile_wtarget_alg():
    """ Test that it is possible to compile with target algorithms. """
    assert oc.compile_model(fpath, cpath, target='algorithms') == 0, \
           "Compiling "+cpath+" with target=algorithms failed."
    
def test_optimica_compile_wtarget_ipopt():
    """ Test that it is possible to compile with target ipopt. """
    assert oc.compile_model(fpath, cpath, target='ipopt') == 0, \
           "Compiling "+cpath+" with target=ipopt failed."
    
def test_optimica_stepbystep():
    """ Test that it is possible to compile step-by-step. """
    sourceroot = oc.parse_model(fpath)
    ipr = oc.instantiate_model(sourceroot, cpath)
    fclass = oc.flatten_model(fpath, cpath, ipr)
    assert oc.compile_dll(cpath.replace('.','_',1)) == 0, \
           "Compiling dll failed."
