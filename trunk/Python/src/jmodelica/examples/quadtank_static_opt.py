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

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
from jmodelica import jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica import initialize

# Import numerical libraries
import numpy as N
import matplotlib.pyplot as plt

import scipy.integrate as int

def run_demo(with_plots=True):
    """Static calibration of the quad tank model."""

    oc = OptimicaCompiler()

    curr_dir = os.path.dirname(os.path.abspath(__file__));
    
    oc.compile_model("QuadTank_pack.QuadTank_Static",
                     curr_dir+"/files/QuadTank.mo",
                     target='ipopt')

    # Load static calibration model
    qt_static=jmi.Model("QuadTank_pack_QuadTank_Static")

    # Set control inputs
    qt_static.set_value("u1",2.5)
    qt_static.set_value("u2",2.5)

    # Save nominal values
    a1_nom = qt_static.get_value("a1")
    a2_nom = qt_static.get_value("a2")

    init_res = initialize(qt_static, alg_args={'stat':1})

    print "Optimal parameter values:"
    print "a1: %2.2e (nominal: %2.2e)" % (qt_static.get_value("a1"),a1_nom)
    print "a2: %2.2e (nominal: %2.2e)" % (qt_static.get_value("a2"),a2_nom)

    assert N.abs(qt_static.get_value("a1") - 7.95797110936e-06) < 1e-3, \
           "Wrong value of parameter a1 function in quadtank_static_opt.py"  

    assert N.abs(qt_static.get_value("a2") - 7.73425542448e-06) < 1e-3, \
           "Wrong value of parameter a2 function in quadtank_static_opt.py"  

    if __name__ == "__main__":
        run_demo()
