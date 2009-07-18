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

#set/get environment variables
try:
	_jm_sdk_home = os.environ['JMODELICA_SDK_HOME']
except KeyError:
	_jm_sdk_home = None

try:
	_jm_home = os.environ['JMODELICA_HOME']
except KeyError:
	_jm_home = None

if _jm_sdk_home is None and _jm_home is None:
	raise EnvironmentError('The environment variable JMODELICA_SDK_HOME or JMODELICA_HOME needs to'
						   ' be set in order to run JModelica.')
if _jm_home is None:
	_jm_home=os.path.join(_jm_sdk_home,'install')
	os.environ['JMODELICA_HOME'] = _jm_home

cppad_h = os.path.join(_jm_home,'ThirdParty','CppAD')
os.environ['CPPAD_HOME'] = cppad_h

ipopt_h = os.path.join(_jm_sdk_home,'Ipopt-MUMPS')
os.environ['IPOPT_HOME'] = ipopt_h

if sys.platform == 'win32':
    path = os.environ.get('PATH')
    mingw = os.path.join(_jm_sdk_home,'mingw','bin')
    path = mingw + ';' + path
    os.environ['PATH'] = path

#get paths to external directories: OptimicaCompiler, ModelicaCompiler, Beaver
_oc_jar = os.path.join(_jm_home,'lib','OptimicaCompiler.jar')
_mc_jar = os.path.join(_jm_home,'lib','ModelicaCompiler.jar')
_beaver_lib = os.path.join(_jm_home,'ThirdParty','Beaver','lib')

# JVM dir and class paths
_dir_path="-Djava.ext.dirs=%s" %_beaver_lib
if sys.platform == 'win32':
    _class_path="-Djava.class.path=%s;%s" %(_oc_jar,_mc_jar)
else:
    _class_path="-Djava.class.path=%s:%s" %(_oc_jar,_mc_jar)

#user options dict
user_options = {}

def _parse_jvm_args(args):
	""" Parse string of JVM arguments and return list. """
	result = []
	if args:
		args = args.strip()
		list = args.split(' ')
		for l in list:
			if l:
				result.append(l)
	return result
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
