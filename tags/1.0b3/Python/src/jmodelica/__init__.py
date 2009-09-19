# -*- coding: utf-8 -*-
"""The JModelica.org Python package <http:/www.jmodelica.org/>
"""
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


__all__ = ['jmi', 'xmlparser', 'compiler', 'optimicacompiler','optimization',
           'examples', 'tests','io']

import os, os.path
import warnings

try:
    _p = os.environ['JMODELICA_HOME']
    if not os.path.exists(_p):
        raise IOError
except KeyError, IOError:
    raise EnvironmentError('The environment variable JMODELICA_HOME is not '
                           'set or points to a non-existing location.')

try:
    _f = os.path.join(os.environ['JMODELICA_HOME'],'startup.py')
    execfile(_f)
except IOError:
    warnings.warn('Startup script ''%s'' not found. Environment may be corrupt'
                  % _f)


