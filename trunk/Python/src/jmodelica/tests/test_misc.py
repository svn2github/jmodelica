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
from jmodelica.tests import testattr
from jmodelica.simulation.sundials import TrajectoryLinearInterpolation

int = N.int32
N.int = N.int32


jm_home = jmodelica.environ['JMODELICA_HOME']
path_to_examples = os.path.join('Python', 'jmodelica', 'examples')


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
   

#@testattr(stddist = True)
#def test_optimize_2():
#    """ Test the jmodelica.optimize function and set some
#        default parameters.
#    """
#    mofile_vdp = os.path.join('files', 'VDP.mo')
#    fpath_vdp = os.path.join(jm_home, path_to_examples, mofile_vdp)
#    cpath_vdp = "VDP_pack.VDP_Opt"
#    
#    (model,res) = jmodelica.optimize(cpath_vdp, fpath_vdp, max_iter=500, 
#                                     compiler_options={'state_start_values_fixed':True})
#    cost=res.get_variable_data('cost')
#    
#    assert N.abs(cost.x[-1] - 2.3469089e+01) < 1e-3, \
#            "Wrong value of cost function using jmodelica.optimize with vdp."
#            
@testattr(stddist = True)
def test_simulate():
    """ Test the jmodelica.simulate function using all default parameters."""
    mofile_rlc = os.path.join('files','RLC_Circuit.mo')
    fpath_rlc = os.path.join(jm_home, path_to_examples, mofile_rlc)
    cpath_rlc = "RLC_Circuit"
    
    (model,res) = jmodelica.simulate(cpath_rlc, fpath_rlc, final_time=30.0)
    resistor_v = res.get_variable_data('resistor.v')
    
    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
        "Wrong value in simulation result using jmodelica.simulate with rlc."
        
#@testattr(stddist = True)
#def test_simulate_2():
#    """ Test first simulate -> change model and set input -> 
#        simulate without recompiling.
#    """
#    model_name = 'SecondOrder'
#    mofile = os.path.join('files','SecondOrder.mo')
#    fpath=os.path.join(jm_home, path_to_examples, mofile)
#    
#    (model,res)=jmodelica.simulate(model_name, fpath)
#    
#    x1_sim = res.get_variable_data('x1')
#    x2_sim = res.get_variable_data('x2')
#    u_sim = res.get_variable_data('u')
#    assert N.abs(x1_sim.x[-1] - 0.0) < 1e-3, \
#            "Wrong value of x1_sim function in simulation_with_input.py"
#
#    assert N.abs(x2_sim.x[-1] - 0.0) < 1e-3, \
#            "Wrong value of x2_sim function in simulation_with_input.py"  
#
#    assert N.abs(u_sim.x[-1] - 0.0) < 1e-3, \
#            "Wrong value of u_sim function in simulation_with_input.py"
#            
#    # Generate input
#    t = N.linspace(0.,10.,100) 
#    u = N.cos(t)
#    u = N.array([u])
#    u = N.transpose(u)
#    u_traj = TrajectoryLinearInterpolation(t,u)
#
#    model.set_value('u',u_traj.eval(0.)[0])
#
#    (model,res) = jmodelica.simulate(model,final_time=30.0,input=u_traj)
#    
#    x1_sim = res.get_variable_data('x1')
#    x2_sim = res.get_variable_data('x2')
#    u_sim = res.get_variable_data('u')
#    
#    assert N.abs(x1_sim.x[-1]*1.e1 - (-8.3999640)) < 1e-3, \
#            "Wrong value of x1_sim function in simulation_with_input.py"
#
#    assert N.abs(x2_sim.x[-1]*1.e1 - (-5.0691179)) < 1e-3, \
#            "Wrong value of x2_sim function in simulation_with_input.py"  
#
#    assert N.abs(u_sim.x[-1]*1.e1 - (-8.3907153)) < 1e-3, \
#            "Wrong value of u_sim function in simulation_with_input.py"
#            
#@testattr(stddist=True)
#def test_simulate_3():
#    """ Test simulate without initialize."""
#    mofile = os.path.join("files", "Pendulum_pack_no_opt.mo")
#    fpath = os.path.join(jm_home, path_to_examples, mofile)
#    cpath = "Pendulum_pack.Pendulum"
#    
#    (model,res) = jmodelica.simulate(cpath, fpath, do_initialize=False)
#
#    theta = res.get_variable_data('theta')
#    assert N.abs(theta.x[-1] -  6.0979443) < 1e-3, \
#            "Wrong value of x1_sim function in simulation_with_input.py"
#            
#@testattr(stddist = True)
#def test_exception_raised():
#    """ Test compact functions without passing mofile raises exception."""
#    cpath = "Pendulum_pack.Pendulum"
#    nose.tools.assert_raises(Exception, jmodelica.initialize, cpath)
#    
#    nose.tools.assert_raises(Exception, jmodelica.simulate, cpath)
#
#    nose.tools.assert_raises(Exception, jmodelica.optimize, cpath)
    

   
    

  