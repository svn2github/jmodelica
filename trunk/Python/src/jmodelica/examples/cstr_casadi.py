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

import os.path

import numpy as N
import matplotlib.pyplot as plt

from jmodelica.io import ResultDymolaTextual

from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler

from jmodelica.optimization.casadi_collocation import XMLOCP
from jmodelica.optimization.casadi_collocation import BackwardEulerCollocator

def run_demo(with_plots=True):
    """
    Demonstrate how the CasADi collocation algorithm can be used.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    oc = OptimicaCompiler()
    oc.set_boolean_option('generate_xml_equations',True)
    #oc.set_boolean_option('eliminate_alias_variables',False)

    oc.compile_model("CSTR.CSTR_Opt2", curr_dir+"/files/CSTR.mop")
    xmlmodel = XMLOCP("CSTR_CSTR_Opt2.xml")
    be_colloc = BackwardEulerCollocator(xmlmodel,100)
    be_colloc.solve()
    be_colloc.write_result()
    res = ResultDymolaTextual('CSTR.CSTR_Opt2'+'_result.txt')

    c = res.get_variable_data('cstr.c')
    T = res.get_variable_data('cstr.T')
    Tc = res.get_variable_data('cstr.Tc')

    # Plot
    if with_plots:    
        plt.figure(1)
        plt.clf()
        plt.subplot(3,1,1)
        plt.plot(c.t,c.x,'x-')
        plt.grid(True)
        plt.subplot(3,1,2)
        plt.plot(T.t,T.x,'x-')
        plt.grid(True)
        plt.subplot(3,1,3)
        plt.plot(Tc.t,Tc.x,'x-')
        plt.grid(True)
        plt.show()

    return be_colloc
