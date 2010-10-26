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

import numpy as N
import matplotlib.pyplot as plt

from jmodelica.jmi import compile_jmu

def run_demo(with_plots=True):
    """ 
    Example demonstrating how to use BLT.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Compile model
    jmu_name = compile_jmu("BLT_Example", curr_dir+"/files/BLT_Example.mo", 
        compiler_options={"equation_sorting":True})
