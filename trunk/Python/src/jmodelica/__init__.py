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
           'examples', 'tests','io','initialization','simulation']

__version__=''

import os, os.path
import warnings

try:
    _p = os.environ['JMODELICA_HOME']
    if not os.path.exists(_p):
        raise IOError
except KeyError, IOError:
    raise EnvironmentError('The environment variable JMODELICA_HOME is not '
                           'set or points to a non-existing location.')
    
# set version
try:
    _fpath=os.path.join(os.environ['JMODELICA_HOME'],'version.txt')
    f = open(_fpath)
    __version__=f.readline()
except IOError:
    warnings.warn('Version file not found. Environment may be corrupt.')
finally:
    f.close()    

try:
    _f = os.path.join(os.environ['JMODELICA_HOME'],'startup.py')
    execfile(_f)
except IOError:
    warnings.warn('Startup script ''%s'' not found. Environment may be corrupt'
                  % _f)

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
    sys.stdout.write("\n")
    sys.stdout.flush()
    time.sleep(0.25)    
    import imp
    # Test dependencies
    sys.stdout.write("\n\n")
    sys.stdout.write("Dependencies: \n\n".rjust(0))
    modstr="Module"
    verstr="Version"
    sys.stdout.write("%s %s" % (modstr.ljust(le), verstr.ljust(le)))
    sys.stdout.write("\n")
    sys.stdout.write("%s %s" % (("-"*len(modstr)).ljust(le), ("-"*len(verstr)).ljust(le)))
    sys.stdout.write("\n")
    
    modules=["numpy", "scipy", "matplotlib", "jpype", "lxml", "nose", "pysundials"]
    if platform == "win32":
        modules.append("pyreadline")
        
    for module in modules:
        try:
            vers="--"            
            fp, path, desc = imp.find_module(module)
            mod = imp.load_module(module, fp, path, desc)
            try:
                if module == "pyreadline":
                    vers = mod.release.version
                elif module == "lxml":
                    from lxml import etree
                    vers = etree.__version__
                else:
                    vers = mod.__version__
            except AttributeError, e:
                pass
            sys.stdout.write("%s %s %s" %(module.ljust(le,'.'), vers.ljust(le), "Ok".ljust(le)))
        except ImportError, e:
            if module != "nose":
                sys.stdout.write("%s %s %s " % (module.ljust(le,'.'), vers.ljust(le), "Error (Module required but not found)".ljust(le)))
            else:
                sys.stdout.write("%s %s %s" % (module.ljust(le,'.'), vers.ljust(le), "Warning (Module required to run tests)".ljust(le)))
            pass
        finally:
            if fp:
                fp.close()
        sys.stdout.write("\n")
        sys.stdout.flush()
        time.sleep(0.25)
