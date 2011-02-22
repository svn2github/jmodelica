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
import os

import numpy as N
import matplotlib.pyplot as plt

from jmodelica.io import ResultDymolaTextual

from jmodelica.optimization.casadi_collocation import XMLOCP
from jmodelica.optimization.casadi_collocation import BackwardEulerCollocator
from jmodelica.optimization.casadi_collocation import RadauCollocator

from jmodelica.core import unzip_unit
from jmodelica.jmi import compile_jmu

def run_demo(with_plots=True):
    """
    Demonstrate how the CasADi collocation algorithm can be used.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    jn = compile_jmu("CSTR.CSTR_Opt2", curr_dir+"/files/CSTR.mop",compiler_options={'generate_xml_equations':True})

    #xml_file_name = unzip_unit(archive='./CSTR_CSTR_Opt2.jmu')[1]
    os.system("unzip ./CSTR_CSTR_Opt2.jmu")
    xmlmodel = XMLOCP("modelDescription.xml")
    be_colloc = RadauCollocator(xmlmodel,100,3)
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

if __name__=="__main__":
    run_demo()
