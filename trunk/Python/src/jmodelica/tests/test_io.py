""" Test module for testing the io module
"""

import os
import os.path

import nose

import jmodelica.jmi as jmi
import jmodelica.optimicacompiler as oc
import jmodelica.xmlparser as xp
import jmodelica.io

import numpy as N

sep = os.path.sep

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = sep + "Python" + sep + "jmodelica" + sep + "examples"

model = sep + "files" + sep + "VDP.mo"
fpath = jm_home+path_to_examples+model
cpath = "VDP_pack.VDP_Opt"

fname = cpath.replace('.','_',1)

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    oc.set_log_level(oc.LOG_ERROR)
    oc.compile_model(fpath, cpath, target='ipopt')

def test_dymola_export_import():

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)

    # Initialize the mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element

    # Create an NLP object
    nlp = jmi.SimultaneousOptLagPols(vdp,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)

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

    
