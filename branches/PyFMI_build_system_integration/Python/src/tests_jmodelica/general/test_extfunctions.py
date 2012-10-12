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
"""
Module for testing external function support.
"""
import os, subprocess, shutil

from os.path import join as path

from pymodelica import compile_jmu, compile_fmu
from pymodelica.common.core import get_platform_dir, create_temp_dir
from pyjmi import JMUModel
from pyfmi import FMUModel
from tests_jmodelica import testattr, get_files_path

@testattr(stddist = True)
def test_ModelicaUtilities():
    """ 
    Test compiling a model with external functions using the functions in ModelicaUtilities.
    """
    fpath = path(get_files_path(), 'Modelica', "ExtFunctionTests.mo")
    cpath = "ExtFunctionTests.ExtFunctionTest3"
    jmu_name = compile_jmu(cpath, fpath, target='model_noad')
    model = JMUModel(jmu_name)
    #model.simulate()

@testattr(stddist = True)
def test_ExtFuncStatic():
    """ 
    Test compiling a model with external functions in a static library.
    """
    dir = build_ext('add_static')
    fpath = path(dir, "ExtFunctionTests.mo")
    cpath = "ExtFunctionTests.ExtFunctionTest1"
    fmu_name = compile_fmu(cpath, fpath)
    shutil.rmtree(dir, True)
    model = FMUModel(fmu_name)

@testattr(stddist = True)
def test_ExtFuncShared():
    """ 
    Test compiling a model with external functions in a shared library.
    """
    dir = build_ext('add_shared')
    fpath = path(dir, "ExtFunctionTests.mo")
    cpath = "ExtFunctionTests.ExtFunctionTest1"
    fmu_name = compile_fmu(cpath, fpath)
    shutil.rmtree(dir, True)
    model = FMUModel(fmu_name)

def build_ext(target):
    """
    Build a library for an external function.
    """
    platform = get_platform_dir()
    if platform[:-2] == 'win':
        bin = path(os.environ['MINGW_HOME'],'bin')
        make = '%s CC=%s AR=%s' % (path(bin,'mingw32-make'), path(bin,'gcc'), path(bin,'ar'))
    else:
        make = 'make'
    cmd = '%s PLATFORM=%s clean %s' % (make, platform, target)
    
    src = path(get_files_path(), 'Modelica')
    dst = create_temp_dir()
    shutil.copytree(path(src, 'Resources'), path(dst, 'Resources'))
    shutil.copy(path(src, 'ExtFunctionTests.mo'), dst)
    old = os.getcwd()
    os.chdir(path(dst, 'Resources', 'src'))
    subprocess.call(cmd, shell=True)
    os.chdir(old)
    
    return dst
