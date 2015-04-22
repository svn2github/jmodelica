#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2015 Modelon AB
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

"""Tests back tracking from collocated NLP to original equations and variables."""

import os
import numpy as N
from tests_jmodelica import testattr, get_files_path
from pyjmi import transfer_optimization_problem
from pyjmi.optimization.casadi_collocation import BlockingFactors

@testattr(casadi = True)
def test_nlp_variable_indices():
    file_path = os.path.join(get_files_path(), 'Modelica', 'TestBackTracking.mop')
    op = transfer_optimization_problem("TestVariableTypes", file_path)

    n_e = 10

    opts = op.optimize_options()
    opts['n_e'] = n_e
    opts['variable_scaling'] = False
    opts['blocking_factors'] = BlockingFactors({'u_bf':[1]*n_e})

    res = op.optimize(options = opts)

    t = res['time']
    solver = res.get_solver()
    xx = solver.collocator.primal_opt

    var_names = ['x', 'x2', 'w', 'w2', 'u_cont', 'u_bf', 'p']
    for name in var_names:
        inds, tv, i, k = solver.get_nlp_variable_indices(name)
        tinds = N.searchsorted((t[:-1]+t[1:])/2, tv)
        assert N.max(N.abs(t[tinds] - tv)) < 1e-12
        if name == 'u_bf':
            # workaround for the fact that res uses the left value of u_bf
            # at the discontinuity point, and back tracking uses the right
            tinds += 1
        assert N.max(N.abs(res[name][tinds] - xx[inds])) < 1e-12
