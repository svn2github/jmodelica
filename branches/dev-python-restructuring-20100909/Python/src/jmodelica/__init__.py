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


__all__ = ['jmi', 'xmlparser', 'compiler','optimization',
           'examples', 'tests','io','initialization','simulation','core',
           'linearization', 'algorithm_drivers']

__version__=''

import os
import warnings

try:
    _p = os.environ['JMODELICA_HOME']
    if not os.path.exists(_p):
        raise IOError
except KeyError, IOError:
    raise EnvironmentError('The environment variable JMODELICA_HOME is not '
                           'set or points to a non-existing location.')
    
# set version
f= None
try:
    _fpath=os.path.join(os.environ['JMODELICA_HOME'],'version.txt')    
    f = open(_fpath)
    __version__=f.readline().strip()
except IOError:
    warnings.warn('Version file not found. Environment may be corrupt.')
finally:
    if f is not None:
        f.close()   

try:
    _f = os.path.join(os.environ['JMODELICA_HOME'],'startup.py')
    execfile(_f)
except IOError:
    warnings.warn('Startup script ''%s'' not found. Environment may be corrupt'
                  % _f)


import jmodelica

import numpy as N

int = N.int32
N.int = N.int32

try:
    ipopt_present = jmodelica.environ['IPOPT_HOME']
except:
    ipopt_present = False

def check_packages():
    import sys, time
    le=30
    startstr = "Performing JModelica package check"
    sys.stdout.write("\n")
    sys.stdout.write(startstr+" \n")
    sys.stdout.write("="*len(startstr))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)

    # check os
    platform = sys.platform
    sys.stdout.write("%s %s" %("Platform".ljust(le,'.'),(str(platform)).ljust(le)+"\n\n"))
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check python version
    pyversion = sys.version.partition(" ")[0]
    sys.stdout.write("%s %s" % ("Python version:".ljust(le,'.'),pyversion.ljust(le)))
    sys.stdout.write("\n\n")
    sys.stdout.flush()
    time.sleep(0.25)
    
    #check jmodelica version
    jmversion = jmodelica.__version__
    sys.stdout.write("%s %s" % ("JModelica version:".ljust(le,'.'),jmversion.ljust(le)))
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
    sys.stdout.write("%s %s" % (("-"*len(modstr)).ljust(le), ("-"*len(verstr)).ljust(le)))
    sys.stdout.write("\n")
    
    packages=["numpy", "scipy", "matplotlib", "jpype", "lxml", "nose", "assimulo"]
    assimulo_path=os.path.join(jmodelica.environ['JMODELICA_HOME'],'Python','assimulo')
    
    if platform == "win32":
        packages.append("pyreadline")
    
    error_packages=[]
    warning_packages=[]
    fp = None
    for package in packages:
        try:
            vers="--"
            if package=='assimulo':
                fp, path, desc = imp.find_module('problem', [assimulo_path])
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
            except AttributeError, e:
                pass
            sys.stdout.write("%s %s %s" %(package.ljust(le,'.'), vers.ljust(le), "Ok".ljust(le)))
        except ImportError, e:
            if package == "nose" or package == "assimulo":
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
        the jmodelica package without them.\n")
    
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
- jmodelica.simulate with default argument \"algorithm\" = AssimuloAlg \n   \
- The jmodelica.simulation package \n   \
- Some of the examples in the jmodelica.examples package")
            elif w == 'nose':
                sys.stdout.write("** The package nose could not be found. \n   \
This package is needed in the jmodelica.tests package. \
You will not be able to run any tests.")
		
            sys.stdout.write("\n\n")


