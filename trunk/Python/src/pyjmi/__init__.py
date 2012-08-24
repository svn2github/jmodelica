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
The JModelica.org Python package for working with simulation and optimization of
JMUs <http:/www.jmodelica.org/>
"""

__all__ = ['common', 'initialization', 'optimization', 'simulation', 'examples', 'casadi_interface', 'linearization', 'jmi', 'jmi_algorithm_drivers']

__version__=''

import os
import logging

try:
    _p = os.environ['JMODELICA_HOME']
    if not os.path.exists(_p):
        raise IOError
except (KeyError, IOError):
    raise EnvironmentError('The environment variable JMODELICA_HOME is not set \
or points to a non-existing location.')
    
# set version
f= None
try:
    _fpath=os.path.join(os.environ['JMODELICA_HOME'],'version.txt')
    f = open(_fpath)
    __version__=f.readline().strip()
except IOError:
    logging.warning('Version file not found. Environment may be corrupt.')
finally:
    if f is not None:
        f.close()   

try:
    _f = os.path.join(os.environ['JMODELICA_HOME'],'startup.py')
    execfile(_f)
except IOError:
    logging.warning('Startup script ''%s'' not found. Environment may be corrupt'
                  % _f)


import numpy as N

import pyjmi

int = N.int32
N.int = N.int32

try:
    ipopt_present = pyjmi.environ['IPOPT_HOME']
except:
    ipopt_present = False
    
#Import the model class allowing for users to type: from pyjmi import JMUModel
from jmi import JMUModel
#Import the model class allowing for users to type: from pyjmi import CasadiModel
from casadi_interface import CasadiModel

def check_packages():
    import sys, time
    le=30
    startstr = "Performing pyjmi package check"
    sys.stdout.write("\n")
    sys.stdout.write(startstr+" \n")
    sys.stdout.write("="*len(startstr))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)

    # check os
    platform = sys.platform
    sys.stdout.write(
        "%s %s" %("Platform".ljust(le,'.'),(str(platform)).ljust(le)+"\n\n"))
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check python version
    pyversion = sys.version.partition(" ")[0]
    sys.stdout.write(
        "%s %s" % ("Python version:".ljust(le,'.'),pyversion.ljust(le)))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check pyjmi version
    pyjmiversion = pyjmi.__version__
    sys.stdout.write(
        "%s %s" % ("pyjmi version:".ljust(le,'.'),pyjmiversion.ljust(le)))
    sys.stdout.write("\n")
    sys.stdout.flush()
    time.sleep(0.25)
    
    import imp
    # Test dependencies
    sys.stdout.write("\n\n")
    sys.stdout.write("Dependencies: \n\n".rjust(0))
    modstr="Package"
    verstr="Version"
    sys.stdout.write("%s %s" % (modstr.ljust(le), verstr.ljust(le)))
    sys.stdout.write("\n")
    sys.stdout.write(
        "%s %s" % (("-"*len(modstr)).ljust(le), ("-"*len(verstr)).ljust(le)))
    sys.stdout.write("\n")
    
    packages=["numpy", "scipy", "matplotlib", "jpype", "lxml", "nose", 
        "assimulo","wxPython", "cython", "casadi"]
    assimulo_path=os.path.join(pyjmi.environ['JMODELICA_HOME'],'Python',
        'assimulo')
    
    if platform == "win32":
        packages.append("pyreadline")
        packages.append("setuptools")
    
    error_packages=[]
    warning_packages=[]
    fp = None
    for package in packages:
        try:
            vers="n/a"
            if package=='assimulo':
                fp, path, desc = imp.find_module('problem', [assimulo_path])
                mod = imp.load_module('problem', fp, path, desc)
            else:    
                fp, path, desc = imp.find_module(package)
                mod = imp.load_module(package, fp, path, desc)
                
            try:
                if package == "pyreadline":
                    vers = mod.release.version
                elif package == "lxml":
                    from lxml import etree
                    vers = etree.__version__
                else:
                    vers = mod.__version__
            except AttributeError as e:
                pass
            sys.stdout.write("%s %s %s" %(package.ljust(le,'.'), vers.ljust(le), "Ok".ljust(le)))
        except ImportError as e:
            if package == "nose" or package == "assimulo" or package == "casadi" or package == "wxPython":
                sys.stdout.write("%s %s %s" % (package.ljust(le,'.'), vers.ljust(le), "Package missing - Warning issued, see details below".ljust(le)))
                warning_packages.append(package)
            else:
                sys.stdout.write("%s %s %s " % (package.ljust(le,'.'), vers.ljust(le), "Package missing - Error issued, see details below.".ljust(le)))
                error_packages.append(package)
            pass
        finally:
            if fp:
                fp.close()
        sys.stdout.write("\n")
        sys.stdout.flush()
        time.sleep(0.25)

        
    # Write errors and warnings
    # are there any errors?
    if len(error_packages) > 0:
        sys.stdout.write("\n")
        errtitle = "Errors"
        sys.stdout.write("\n")
        sys.stdout.write(errtitle+" \n")
        sys.stdout.write("-"*len(errtitle))
        sys.stdout.write("\n\n")
        sys.stdout.write("The packages: \n\n")
        
        for er in error_packages:
            sys.stdout.write("   - "+str(er))
            sys.stdout.write("\n")
        sys.stdout.write("\n")
        sys.stdout.write("could not be found. It is not possible to run \
        the pyjmi package without them.\n")
    
    if len(warning_packages) > 0:
        sys.stdout.write("\n")
        wartitle = "Warnings"
        sys.stdout.write("\n")
        sys.stdout.write(wartitle+" \n")
        sys.stdout.write("-"*len(wartitle))
        sys.stdout.write("\n\n")
        
        for w in warning_packages:
            if w == 'assimulo':
                sys.stdout.write("** The package assimulo could not be found. \n  \
 This package is needed to be able to use: \n\n   \
- pyjmi.simulate with default argument \"algorithm\" = AssimuloAlg \n   \
- The pyjmi.simulation package \n   \
- Some of the examples in the pyjmi.examples package")
            elif w == 'nose':
                sys.stdout.write("** The package nose could not be found. \n   \
This package is needed in the tests_jmodelica package. \
You will not be able to run any tests.")
            elif w == 'casadi':
                sys.stdout.write("** The package casadi could not be found.\n \
This package is needed to be able to use:\n\n \
- The casadi_interface module.\n \
- Some of the examples in the pyjmi.examples package")
            elif w == 'wxPython':
                sys.stdout.write("** The package wxPython could not be found.\n \
This package is needed to be able to use the plot-GUI.")
		
            sys.stdout.write("\n\n")

def get_files_path():
    """Get the absolute path to the example files directory."""
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, 'Python', 'pyjmi', 'examples', 'files')
