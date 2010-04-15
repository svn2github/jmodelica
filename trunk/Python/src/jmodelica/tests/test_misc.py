# -*- coding: utf-8 -*-
"""
Test module for functions directly in jmodelica.
"""
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os

import numpy as N
import nose
import nose.tools

import jmodelica
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica import jmi
from jmodelica.tests import testattr
from jmodelica.algorithm_drivers import InvalidAlgorithmArgumentException
from jmodelica.algorithm_drivers import InvalidSolverArgumentException
from Assimulo.Explicit_ODE import *

int = N.int32
N.int = N.int32


jm_home = jmodelica.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python', 'jmodelica', 'examples')


#create Model objects
mofile_vdp = os.path.join('files', 'VDP.mo')
fpath_vdp = os.path.join(jm_home, path_to_examples, mofile_vdp)
cpath_vdp = "VDP_pack.VDP_Opt"
dll_vdp = cpath_vdp.replace('.','_',1)

mofile_rlc = os.path.join('files','RLC_Circuit.mo')
fpath_rlc = os.path.join(jm_home, path_to_examples, mofile_rlc)
cpath_rlc = "RLC_Circuit"
dll_rlc = cpath_rlc.replace('.','_',1)

mc = ModelicaCompiler()
mc.set_boolean_option('state_start_values_fixed',True)
oc = OptimicaCompiler()
oc.set_boolean_option('state_start_values_fixed',True)

mc.compile_model(cpath_rlc, fpath_rlc)
oc.compile_model(cpath_vdp, fpath_vdp, target='ipopt')

model_rlc = jmi.Model(dll_rlc)
model_vdp = jmi.Model(dll_vdp)


#@testattr(stddist = True)
#def test_initialize():
#    """ Test the jmodelica.initialize function. """
#    mofile_cstr = os.path.join('files','CSTR.mo')
#    fpath_cstr = os.path.join(jm_home,path_to_examples,mofile_cstr)
#    cpath_cstr = "CSTR.CSTR_Init"
#    model = jmodelica.initialize(cpath_cstr, fpath_cstr, compiler='optimica')
#    
#
@testattr(stddist = True)
def test_optimize():
    """ Test the jmodelica.optimize function using all default parameters. """
    mofile_pend = os.path.join('files','Pendulum_pack.mo')
    fpath_pend = os.path.join(jm_home,path_to_examples,mofile_pend)
    cpath_pend = "Pendulum_pack.Pendulum_Opt"
    
    (model,res) = jmodelica.optimize(cpath_pend, fpath_pend, 
                                     compiler_options={'state_start_values_fixed':True})
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1] - 1.2921683e-01) < 1e-3, \
        "Wrong value of cost function using jmodelica.optimize with vdp."
   

@testattr(stddist = True)
def test_optimize_set_n_cp():
    """ Test the jmodelica.optimize function and setting n_cp in alg_args.
    """
    (model,res) = jmodelica.optimize(model_vdp, 
                                     compiler_options={'state_start_values_fixed':True},
                                     alg_args={'n_cp':10})
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1] - 2.34602647e+01 ) < 1e-3, \
            "Wrong value of cost function using jmodelica.optimize with vdp. \
            cost.x[-1] was: "+str(cost.x[-1])
            
@testattr(stddist = True)
def test_optimize_set_args():
    """Test the jmodelica.optimize function and setting some algorithm and solver args.
    """
    mofile_vdp = os.path.join('files', 'VDP.mo')
    fpath_vdp = os.path.join(jm_home, path_to_examples, mofile_vdp)
    cpath_vdp = "VDP_pack.VDP_Opt"
    
    res_file_name = 'test_optimize_set_result_mesh.txt'
    (model,res) = jmodelica.optimize(model_vdp, 
                                     compiler_options={'state_start_values_fixed':True},
                                     alg_args={'result_mesh':'element_interpolation', 
                                               'result_file_name':res_file_name},
                                     solver_args={'max_iter':100})
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1] - 2.3469089e+01) < 1e-3, \
            "Wrong value of cost function using jmodelica.optimize with vdp."


@testattr(stddist = True)
def test_optimize_invalid_algorithm_arg():
    """ Test that the jmodelica.optimize function raises exception for an 
        invalid algorithm argument.
    """
    mofile_vdp = os.path.join('files', 'VDP.mo')
    fpath_vdp = os.path.join(jm_home, path_to_examples, mofile_vdp)
    cpath_vdp = "VDP_pack.VDP_Opt"
    
    nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidAlgorithmArgumentException,
                             jmodelica.optimize,
                             model_vdp, 
                             compiler_options={'state_start_values_fixed':True},
                             alg_args={'ne':10})

@testattr(stddist = True)
def test_simulate():
    """ Test the jmodelica.simulate function using all default parameters."""
    mofile_rlc = os.path.join('files','RLC_Circuit.mo')
    fpath_rlc = os.path.join(jm_home, path_to_examples, mofile_rlc)
    cpath_rlc = "RLC_Circuit"
    
    (model,res) = jmodelica.simulate(cpath_rlc, fpath_rlc)
    resistor_v = res.get_variable_data('resistor.v')
    
    assert N.abs(resistor_v.x[-1] - 0.138037041741) < 1e-3, \
        "Wrong value in simulation result using jmodelica.simulate with rlc."
        
@testattr(stddist = True)
def test_simulate_set_alg_arg():
    """ Test the jmodelica.simulate function and setting an algorithm argument."""    
    (model,res) = jmodelica.simulate(model_rlc, alg_args={'final_time':30.0})
    resistor_v = res.get_variable_data('resistor.v')
    
    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
        "Wrong value in simulation result using jmodelica.simulate with rlc."
        
@testattr(stddist = True)
def test_simulate_invalid_solver_arg():
    """ Test that the jmodelica.simulate function raises an exception for an 
        invalid solver argument.
    """    
    nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidSolverArgumentException,
                             jmodelica.simulate,
                             model_rlc,
                             compiler_options={'state_start_values_fixed':True},
                             solver_args={'mxiter':10})

@testattr(stddist = True)
def test_simulate_invalid_algorithm_arg():
    """ Test that the jmodelica.optimize function raises exception for an 
        invalid algorithm argument.
    """
    nose.tools.assert_raises(jmodelica.algorithm_drivers.InvalidAlgorithmArgumentException,
                             jmodelica.simulate,
                             model_rlc,
                             compiler_options={'state_start_values_fixed':True},
                             alg_args={'starttime':10})
      
@testattr(stddist=True)
def test_simulate_w_ode():
    """ Test jmodelica.simulate with ODE problem and setting solver args."""
    mofile_vdp = os.path.join('files', 'VDP.mo')
    fpath_vdp = os.path.join(jm_home, path_to_examples, mofile_vdp)
    cpath_vdp = "VDP_pack.VDP_Opt"

    (model,res) = jmodelica.simulate(cpath_vdp, 
                                     fpath_vdp,
                                     compiler='optimica',
                                     compiler_options={'state_start_values_fixed':True},
                                     compiler_target='model',
                                     alg_args={'solver':CVode, 'final_time':20, 'num_communication_points':0},
                                     solver_args={'discr':'BDF', 'iter':'Newton'})
    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    
    assert N.abs(x1.x[-1] + 0.736680243) < 1e-5, \
           "Wrong value in simulation result in VDP_assimulo.py" 
    assert N.abs(x2.x[-1] - 1.57833994) < 1e-5, \
           "Wrong value in simulation result in VDP_assimulo.py"

@testattr(stddist = True)
def test_exception_raised():
    """ Test compact functions without passing mofile raises exception."""
    cpath = "Pendulum_pack.Pendulum"   
    nose.tools.assert_raises(Exception, jmodelica.simulate, cpath)
    nose.tools.assert_raises(Exception, jmodelica.optimize, cpath)
    

   
    

  