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

""" Tests the Brent 1d solver for initialization. """

import os.path

import numpy as N
import nose.tools

from pyfmi import load_fmu
from pymodelica import compile_fmu
from tests_jmodelica import testattr, get_files_path

fpath = os.path.join(get_files_path(), 'Modelica', 'TestBrent.mo')

@testattr(fmi = True)
def test_cubic():
    options = {'block_solver_experimental_mode':4, 'use_Brent_in_1d':True,
               'generate_only_initial_system': True}
    name = compile_fmu('TestBrent.Cubic', fpath, compiler_options=options)

    model = load_fmu(name)
    for t in N.linspace(0,1,101):
        model.reset()        
        model.time = t
        model.initialize()
            
        x = model.get('x')
        y = model.get('y')
        assert abs(y - (-2+4*t)) < 1e-6
        yy = x*(x-1)*(x+1)
        relativeDiff = (yy - y)/((abs(yy + y) + 1e-16)/2)
        assert abs(relativeDiff) < 1e-6
