""" Test module for testing the linearize module
"""

import os
import os.path

import numpy as N
import nose

from jmodelica.tests import testattr

import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
import jmodelica.xmlparser as xp
import jmodelica.io
from jmodelica.optimization import ipopt
from jmodelica.linearization import *
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join("Python","jmodelica","examples")

model = os.path.join("files", "CSTR.mo")
fpath = os.path.join(jm_home,path_to_examples,model)
cpath = "CSTR.CSTR_Opt"
fname = cpath.replace('.','_',1)

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
    oc.compile_model(fpath, cpath, target='ipopt')
    oc.compile_model(fpath, cpath, target='ipopt')

@testattr(stddist = True)
def test_linearization():
    
    # Load the dynamic library and XML data
    model = jmi.Model(fname)

    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
        
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    (E_dae,A_dae,B_dae,F_dae,g_dae,state_names,input_names,algebraic_names, \
     dx0,x0,u0,w0,t0) = linearize_dae(model)
    
    (A_ode,B_ode,g_ode,H_ode,M_ode,q_ode) = linear_dae_to_ode(E_dae,A_dae,B_dae,F_dae,g_dae)

    (A_ode2,B_ode2,g_ode2,H_ode2,M_ode2,q_ode2,state_names2,input_names2,algebraic_names2, \
     dx02,x02,u02,w02,t02) = linearize_ode(model)

    assert (A_ode==A_ode2).all()==True, "Error in linearization: A_ode."
    assert (B_ode==B_ode2).all()==True, "Error in linearization: B_ode."
    assert (g_ode==g_ode2).all()==True, "Error in linearization: g_ode."
    assert (H_ode==H_ode2).all()==True, "Error in linearization: H_ode."
    assert (M_ode==M_ode2).all()==True, "Error in linearization: M_ode."
    assert (q_ode==q_ode2).all()==True, "Error in linearization: q_ode."
    assert (state_names==state_names2)==True, "Error in linearization: state names"
    assert (input_names==input_names2)==True, "Error in linearization: state names"
    assert (algebraic_names==algebraic_names2)==True, "Error in linearization: state names"

    small = 1e-4
    assert (N.abs(A_ode-N.array([[ -0.00000000e+00,   1.00000000e+03,   6.00000000e+01],
 [ -0.00000000e+00,  -1.66821993e-02,  -1.19039519e+00],
 [ -0.00000000e+00,   3.48651310e-03,   2.14034026e-01]]))<=small).all()==True, "Error in linearization: A_ode"
    assert (N.abs(B_ode-N.array([[  1.00000000e+02],
 [ -0.00000000e+00],
 [  3.49859575e-02]]))<=small).all()==True, "Error in linearization: B_ode"
    assert (N.abs(g_ode-N.array([[-0.],
 [-0.],
 [-0.]]))<=small).all()==True, "Error in linearization: g_ode"

    assert N.abs(E_dae-N.array(([[-1.,  0.,  0.],
 [ 0., -1.,  0.],
 [ 0.,  0., -1.]]))<=small).all()==True, "Error in linearization: E_dae"
    assert (N.abs(A_dae-N.array([[ -0.00000000e+00,  -1.00000000e+03,  -6.00000000e+01],
 [ -0.00000000e+00,   1.66821993e-02,   1.19039519e+00],
 [ -0.00000000e+00,  -3.48651310e-03,  -2.14034026e-01]]))<=small).all()==True, "Error in linearization: A_dae"
    assert (N.abs(B_dae-N.array([[ -1.00000000e+02],
 [ -0.00000000e+00],
 [ -3.49859575e-02]]))<=small).all()==True, "Error in linearization: B_dae"
    assert (N.abs(g_dae-N.array([[-0.],
 [-0.],
 [-0.]]))<=small).all()==True, "Error in linearization: g_dae"

    assert (state_names==['cost', 'cstr.c', 'cstr.T'])==True, "Error in linearization: state names"
    assert (input_names==['u'])==True, "Error in linearization: state names"
    assert (algebraic_names==[])==True, "Error in linearization: state names"



    
