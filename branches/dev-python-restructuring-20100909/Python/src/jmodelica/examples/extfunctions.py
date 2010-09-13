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


from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
import pylab as p
import numpy as N
import os


def run_demo(with_plots=True):
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));
    class_name = 'ExtFunctions.addTwo'
    mofile = curr_dir+'/files/ExtFunctions.mo'
    
    jmu_name = compile_jmu(class_name, mofile, target='model_noad')
    model = JMUModel(jmu_name)

    #simulate
    simres = model.simulate()
    
    res = simres.result_data
    sim_a = res.get_variable_data('a')
    sim_b = res.get_variable_data('b')
    sim_c = res.get_variable_data('c')

    assert N.abs(sim_a.x[-1] - 1) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py" 
    assert N.abs(sim_b.x[-1] - 2) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py"
    assert N.abs(sim_c.x[-1] - 3) < 1e-6, \
           "Wrong value in simulation result in extfunctions.py"

    if with_plots:
        fig = p.figure()
        p.clf()
        p.subplot(3,1,1)
        p.plot(sim_a.t, sim_a.x)
        p.subplot(3,1,2) 
        p.plot(sim_b.t, sim_b.x) 
        p.subplot(3,1,3)
        p.plot(sim_c.t, sim_c.x)
        p.show()

if __name__=="__main__":
    run_demo()

