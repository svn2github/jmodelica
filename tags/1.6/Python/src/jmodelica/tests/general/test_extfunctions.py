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
import os

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.tests import testattr
from jmodelica.tests import get_files_path

@testattr(stddist = True)
def test_ModelicaUtilities():
    """ 
    Test that it is possible to compile a model with external functions 
    using the functions in ModelicaUtilities.
    """
    fpath = os.path.join(get_files_path(), 'Modelica', "ExtFunctionTests.mo")
    cpath = "ExtFunctionTests.ExtFunctionTest3"
    jmu_name = compile_jmu(cpath, fpath, target='model_noad')
    model = JMUModel("ExtFunctionTests_ExtFunctionTest3.jmu")
    #model.simulate()
