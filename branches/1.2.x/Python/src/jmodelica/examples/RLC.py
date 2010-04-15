#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import os
import numpy as N
import pylab as p
import matplotlib

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.tests import get_example_path
try:
    from jmodelica.simulation.assimulo import JMIDAE, write_data
    from Assimulo.Implicit_ODE import IDA
except:
    raise ImportError('Could not find Assimulo package.')
from jmodelica.compiler import ModelicaCompiler


def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the DAE simulator. The
    result can be compared with that of sim_rlc.py which has solved the
    same problem using dymola. Also writes information to a file.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'RLC_Circuit'
    mofile = curr_dir+'/files/RLC_Circuit.mo'
    
    
    mc = ModelicaCompiler()
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    mc.compile_model(model_name,mofile,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(model_name)
    
    global RLC_mod
    global RLC_sim
    
    RLC_mod = JMIDAE(model)
    RLC_sim = IDA(RLC_mod)
    RLC_sim.simulate(30) #Simulate 30 seconds

    write_data(RLC_sim)

    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('RLC_Circuit_result.txt')
    sine_y = res.get_variable_data('sine.y')
    resistor_v = res.get_variable_data('resistor.v')
    inductor1_i = res.get_variable_data('inductor1.i')

    assert N.abs(resistor_v.x[-1] - 0.159255008028) < 1e-3, \
           "Wrong value in simulation result in RLC.py"
    assert RLC_sim.stats['Number of F-Eval During Jac-Eval         '] == 0
    
    if with_plots:
        fig = p.figure()
        p.plot(sine_y.t, sine_y.x, resistor_v.t, resistor_v.x, inductor1_i.t, inductor1_i.x)
        p.legend(('sine.y','resistor.v','inductor1.i'))
        p.show()


if __name__=="__main__":
    run_demo()
