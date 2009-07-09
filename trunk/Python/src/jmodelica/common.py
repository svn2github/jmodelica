""" Holds all common variables for this package. """
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


import os
import sys

_jm_home = os.environ.get('JMODELICA_HOME')
if _jm_home is None:
	raise EnvironmentError('The environment variable JMODELICA_HOME needs to'
						   ' be set in order to run JModelica.')

#get paths to external directories: OptimicaCompiler, ModelicaCompiler, Beaver
_oc_jar = _jm_home+os.sep+'lib'+os.sep+'OptimicaCompiler.jar'
_mc_jar = _jm_home+os.sep+'lib'+os.sep+'ModelicaCompiler.jar'
_beaver_lib = _jm_home+os.sep+'ThirdParty'+os.sep+'Beaver'+os.sep+'lib'
# JVM dir and class paths
_dir_path="-Djava.ext.dirs=%s" %_beaver_lib
if sys.platform == 'win32':
    _class_path="-Djava.class.path=%s;%s" %(_oc_jar,_mc_jar)
else:
    _class_path="-Djava.class.path=%s:%s" %(_oc_jar,_mc_jar)
_jvm_mem_args="-Xmx1024M"

#user options dict
user_options = {}
