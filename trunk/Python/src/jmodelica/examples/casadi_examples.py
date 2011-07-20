#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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
Script for running all examples that use CasADi code. Should be converted to a
proper test.
"""

from jmodelica.examples import *

casadi_examples = [cstr_casadi, cstr_casadi_radau2, vdp_casadi, vdp_casadi_ps,
                   vdp_casadi_radau2]

example_graphs = {cstr_casadi: ["SX"],
                  cstr_casadi_radau2: ["SX", "MX", "expanded_MX"],
                  vdp_casadi: ["SX"],
                  vdp_casadi_ps: ["SX"],
                  vdp_casadi_radau2: ["SX", "MX", "expanded_MX"]}

for example in casadi_examples:
    for graph in example_graphs[example]:
        example.run_demo(with_plots=False, graph=graph)
    
parameter_estimation_algorithms = ["CasadiRadau", "CasadiRadau2"]
for algorithm in parameter_estimation_algorithms:
    parameter_estimation_1_casadi.run_demo(with_plots=False,
                                           algorithm=algorithm)
