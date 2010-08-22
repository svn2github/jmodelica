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
from jmodelica import initialize
from jmodelica import simulate
from jmodelica import optimize

import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler

import numpy as N
import matplotlib.pyplot as plt

def run_demo(with_plots=True):
    """ Example demonstrating how to use index reduction.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Create a Modelica compiler instance
    oc = OptimicaCompiler()
    oc.set_boolean_option("index_reduction",True)

    # Compile model
    pend = oc.compile_model("Pendulum_pack.PlanarPendulum", curr_dir+"/files/Pendulum_pack.mo", target='ipopt')
