""" Test module for testing the compiler module.
 
"""

import os
import sys

import nose

import jmodelica.compiler as cp

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.sep+'Python'+os.sep+'jmodelica'+os.sep+'examples'

model = os.sep+'files'+os.sep+'Pendulum_pack_no_opt.mo'
fpath = jm_home+path_to_examples+model
cpath = "Pendulum_pack.Pendulum"
cp.set_log_level(cp.LOG_ERROR)

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
        
    assert cp.compile_model(fpath, cpath) == 0, \
           "Compiling "+cpath+" failed."
    
    fname = cpath.replace('.','_',1)
    assert os.access(fname+'_variables.xml',os.F_OK) == True, \
           fname+'_variables.xml'+" was not created."
    
    assert os.access(fname+'_values.xml', os.F_OK) == True, \
           fname+'_values.xml'+" was not created."
    
    assert os.access(fname+'.o', os.F_OK) == True, \
           fname+'.o'+" was not created."        
    
    assert os.access(fname+'.c', os.F_OK) == True, \
           fname+'.c'+" was not created."        
    
    assert os.access(fname+suffix, os.F_OK) == True, \
           fname+suffix+" was not created."        
        

def test_compile_wtarget_alg():
    """ Test that it is possible to compile (compiler.py) with target algorithms. """
    assert cp.compile_model(fpath, cpath, target='algorithms') == 0, \
           "Compiling "+cpath+" with target=algorithms failed."
    
def test_compile_wtarget_ipopt():
    """ Test that it is possible to compile (compiler.py) with target ipopt. """
    assert cp.compile_model(fpath, cpath, target='ipopt') == 0, \
           "Compiling "+cpath+" with target=ipopt failed."
    
def test_stepbystep():
    """ Test that it is possible to compile (compiler.py) step-by-step. """
    sourceroot = cp.parse_model(fpath)
    ipr = cp.instantiate_model(sourceroot, cpath)
    fclass = cp.flatten_model(fpath, cpath, ipr)
    assert cp.compile_dll(cpath.replace('.','_',1)) == 0, \
           "Compiling dll failed."

