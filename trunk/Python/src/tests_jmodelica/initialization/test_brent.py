#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2014 Modelon AB
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
from nose.tools import assert_raises

from pyfmi import load_fmu
from pymodelica import compile_fmu
from pyfmi.fmi import FMUException
from tests_jmodelica import testattr, get_files_path

fpath = os.path.join(get_files_path(), 'Modelica', 'TestBrent.mo')

def load_model(classname):
    options = {'block_solver_experimental_mode':4, 'use_Brent_in_1d':True,
               'generate_only_initial_system': True}
    log_level = 2
    use_logging = False
    options['log_level'] = log_level
    options['runtime_log_to_file'] = use_logging
    name = compile_fmu(classname, fpath, compiler_options=options)

    fmu = load_fmu(name)
    fmu.set_debug_logging(use_logging)
    fmu.set_log_level(log_level)
    fmu.set('_log_level', log_level)
    return fmu

@testattr(fmi = True)
def test_cubic():
    model = load_model('TestBrent.Cubic')
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

@testattr(fmi = True)
def test_logarithmic():
    model = load_model('TestBrent.Logarithmic')
    for t in N.linspace(0,1,101):
        model.reset()        
        model.time = t
        model.initialize()
            
        x = model.get('x')
        y = model.get('y')
        assert abs(y - (-2+4*t)) < 1e-6
        yy = N.log(1+x)
        relativeDiff = (yy - y)/((abs(yy + y) + 1e-16)/2)
        assert abs(relativeDiff) < 1e-6

@testattr(fmi = True)
def test_xlogx():
    model = load_model('TestBrent.XLogX')

    for t in N.linspace(0,1,101):
        model.reset()        
        model.time = t

        if (-2+4*t) <= -0.36:
            assert_raises(FMUException, model.initialize)
            continue

        if (-2+4*t) <= -0.31:
            try:
                model.initialize()
            except FMUException:
                continue
        else:
            model.initialize()
            
        x = model.get('x')
        y = model.get('y')
        assert abs(y - (-2+4*t)) < 1e-6
        yy = (1+x)*N.log(1+x)
        relativeDiff = (yy - y)/((abs(yy + y) + 1e-16)/2)
        assert abs(relativeDiff) < 1e-6

@testattr(fmi = True)
def test_xlogx_neg():
    model = load_model('TestBrent.XLogXNeg')

    for t in N.linspace(0,1,101):
        model.reset()        
        model.time = t

        if (-2+4*t) <= -0.36:
            assert_raises(FMUException, model.initialize)
            continue
        
        if (-2+4*t) <= -0.31:
            try:
                model.initialize()
            except FMUException:
                continue
        else:
            model.initialize()
            
        x = model.get('x')
        y = model.get('y')
        assert abs(y - (-2+4*t)) < 1e-6
        yy = (1-x)*N.log(1-x)
        relativeDiff = (yy - y)/((abs(yy + y) + 1e-16)/2)
        assert abs(relativeDiff) < 1e-6

@testattr(fmi = True)
def test_arcsin():
    model = load_model('TestBrent.Arcsin')

    for t in N.linspace(0,1,101):
        model.reset()        
        model.time = t

        if abs(-2+4*t) > N.pi/2:
            assert_raises(FMUException, model.initialize)
            continue
        
        model.initialize()
            
        x = model.get('x')
        y = model.get('y')
        assert abs(y - (-2+4*t)) < 1e-6
        yy = N.arcsin(x)
        relativeDiff = (yy - y)/((abs(yy + y) + 1e-16)/2)
        assert abs(relativeDiff) < 1e-6

