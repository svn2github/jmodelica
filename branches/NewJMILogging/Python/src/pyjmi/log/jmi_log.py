#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2013 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
"""
Utilities to postprocess and analyze JMI logs
"""

def get_solves(log):
    """Attempts to emulate the old structured log.

    Takes a log root node and returns a list of solves, marked up with a block_solves list.
    Each block_solve is marked up with an iterations list.
    """
    solves = log.children('equationSolve')
    for solve in solves:
        block_solves = solve.children('newtonSolve')
        solve['block_solves'] = block_solves
        for block_solve in block_solves:
            iterations = [node for node in block_solve.children('kinsol_info') if 'newtonIteration' in node]
            block_solve['iterations'] = iterations
    return solves
