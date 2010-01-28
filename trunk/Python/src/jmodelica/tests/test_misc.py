"""
Test module for functions directly in jmodelica.
"""
import os

import numpy as N
import nose
import nose.tools

import jmodelica
from jmodelica.tests import testattr

int = N.int32
N.int = N.int32


jm_home = jmodelica.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python', 'jmodelica', 'examples')

@testattr(stddist = True)
def test_optimize():
    """ Test the jmodelica.optimize function using all default parameters. """
    model_pend = os.path.join('files','Pendulum_pack.mo')
    fpath_pend = os.path.join(jm_home,path_to_examples,model_pend)
    cpath_pend = "Pendulum_pack.Pendulum_Opt"
    
    res = jmodelica.optimize(fpath_pend, cpath_pend)    
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1] - 1.2921683e-01) < 1e-3, \
        "Wrong value of cost function using jmodelica.optimize with vdp."
   

@testattr(stddist = True)
def test_optimize_2():
    """ Test the jmodelica.optimize function and set some
        default parameters.
    """
    model_vdp = os.path.join('files', 'VDP.mo')
    fpath_vdp = os.path.join(jm_home, path_to_examples, model_vdp)
    cpath_vdp = "VDP_pack.VDP_Opt"
    
    res = jmodelica.optimize(fpath_vdp, cpath_vdp, max_iter=500)
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1] - 2.3469089e+01) < 1e-3, \
            "Wrong value of cost function using jmodelica.optimize with vdp."
            
@testattr(stddist = True)
def test_simulate():
    """ Test the jmodelica.simulate function using all default parameters."""
    model_rlc = os.path.join('files','RLC_Circuit.mo')
    fpath_rlc = os.path.join(jm_home, path_to_examples, model_rlc)
    cpath_rlc = "RLC_Circuit"
    
    res = jmodelica.simulate(fpath_rlc, cpath_rlc, final_time=30.0)
    resistor_v = res.get_variable_data('resistor.v')
    
    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
        "Wrong value in simulation result using jmodelica.simulate with rlc."
    
    
    
    
    