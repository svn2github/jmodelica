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
from jmodelica.simulation.assimulo import JMIODE
from jmodelica.compiler import OptimicaCompiler
from jmodelica.optimization.assimulo_shooting import Multiple_Shooting
from Assimulo.Explicit_ODE import CVode

def run_demo(with_plots=True):
    """
    An example on how to optimize a model using the Assimulo simulation package
    with multiple shooting.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    model_name = 'QuadTank_pack.QuadTank_Opt'
    mofile = curr_dir+'/files/QuadTank.mo'
    package = 'QuadTank_pack_QuadTank_Opt'
    
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    
    # Compile the Modelica model first to C code and
    # then to a dynamic library
    oc.compile_model(model_name,mofile,target='ipopt')

    # Load the dynamic library and XML data
    model=jmi.Model(package)
    Quad_mod = JMIODE(model)
    
    Quad_sim = CVode(Quad_mod)
    Quad_sim.discr = 'BDF'
    Quad_sim.iter = 'Newton'
    Quad_sim.atol = Quad_sim.rtol = 1e-6

    Quad_shoot = Multiple_Shooting(Quad_sim, gridsize=10, initial_u=[2.5,2.5])
    Quad_shoot.verbosity = Multiple_Shooting.SCREAM
    Quad_shoot.optMethod = 'scipy_slsqp'

    sol = Quad_shoot.run(True)
    
    print sol.xf
    Quad_shoot.plot()

if __name__=="__main__":
    run_demo()
