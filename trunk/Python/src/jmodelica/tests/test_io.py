""" Test module for testing the io module
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

from jmodelica import simulate

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join("Python","jmodelica","examples")

model = os.path.join("files", "VDP.mo")
fpath = os.path.join(jm_home,path_to_examples,model)
cpath = "VDP_pack.VDP_Opt_Min_Time"
fname = cpath.replace('.','_',1)

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
    oc.compile_model(cpath, fpath, target='ipopt')
    oc.compile_model(cpath, fpath, target='ipopt')



@testattr(stddist = True)
def test_dymola_export_import():

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)

    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element

    # Create an NLP object
    nlp = ipopt.NLPCollocationLagrangePolynomials(vdp,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)

    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()
   
    # Get the result
    p_opt, traj = nlp.get_result()

    # Write to file
    nlp.export_result_dymola()

    # Load the file we just wrote
    res = jmodelica.io.ResultDymolaTextual(fname+'_result.txt')

    # Check that one of the trajectories match.
    assert max(N.abs(traj[:,3]-res.get_variable_data('x1').x))<1e-12, \
           "The result in the loaded result file does not match that of the loaded file."        

    # Check that the value of the cost function is correct
    assert N.abs(p_opt[0]-2.2811587)<1e-5, \
           "The optimal value is not correct."

@testattr(stddist = True)
def test_parameter_alias():
    model_file = os.path.join(jm_home, "Python", "jmodelica", "tests", "files", "ParameterAlias.mo")

    simulate("ParameterAlias",model_file)
