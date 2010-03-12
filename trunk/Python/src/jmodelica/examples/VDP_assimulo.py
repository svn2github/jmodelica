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

import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
try:
    from Assimulo.Explicit_ODE import CVode
    from jmodelica.simulation.assimulo import JMIExplicit, write_data
except:
    pass

def run_demo(with_plots=True):
    """
    An example on how to simulate a model using the ODE simulator.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'VDP_pack.VDP_Opt'
    mofile = curr_dir+'/files/VDP.mo'
    package = 'VDP_pack_VDP_Opt'
    
    
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    
    # Comile the Modelica model first to C code and
    # then to a dynamic library
    oc.compile_model(mofile,model_name)

    # Load the dynamic library and XML data
    model=jmi.Model(package)
    
    VDP_mod = JMIExplicit(model)
    
    VDP_sim = CVode(VDP_mod)
    VDP_sim.discr = 'BDF' #discretication method, default Adams
    VDP_sim.iter = 'Newton' #iteration method, default FixedPoint
    VDP_sim(20) #Runs the simulation
    VDP_sim.print_statistics() #Prints the integration statistics
    
    write_data(VDP_sim)
    
    # Load the file we just wrote to file
    res = jmodelica.io.ResultDymolaTextual('VDP_pack_VDP_Opt_result.txt')
    
    x1=res.get_variable_data('x1')
    x2=res.get_variable_data('x2')
    
    if with_plots:
        fig = p.figure()
        p.plot(x1.t, x1.x, x2.t, x2.x)
        p.legend(('x1','x2'))
        p.show()
        

if __name__=="__main__":
    run_demo()
