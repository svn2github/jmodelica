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

def check_environment():
    import sys, time
    le=30
    startstr = "Performing JModelica environment check"
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
    
    if sys.hexversion >= 0x2050000:
        sys.stdout.write("%s %s" % ("Python version:".ljust(le,'.'),pyversion.ljust(le)))
    else:  
        sys.stdout.write("%s %s %s" % ("Python version:".ljust(le,'.'),pyversion.ljust(le),"Error: Required is 2.5.x".ljust(le)))
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
    modules=["IPython", "pyreadline", "numpy", "scipy", "matplotlib", "jpype", "lxml", "nose"]
    for module in modules:
        try:
            fp, path, desc = imp.find_module(module)
            mod = imp.load_module(module, fp, path, desc)
            vers="undef"
            vers_required=""
            try:
                if module == "IPython":
                    vers = mod.__version__
                    vers_required="0.1.0"
                elif module == "pyreadline":
                    vers = mod.release.version
                    vers_required="1.5"
                elif module == "numpy":
                    vers = mod.__version__
                    vers_required="1.2.0"
                elif module == "scipy":
                    vers = mod.__version__
                elif module == "matplotlib":
                    vers = mod.__version__
                elif module == "jpype":
                    vers = mod.__version__                    
                elif module == "lxml":
                    vers = imp.load_module('lxml.etree', fp, path, desc).__version__
                elif module == "nose":
                    vers = mod.__version__
            except AttributeError, e:
                pass
            if vers_required and vers >= vers_required:
                sys.stdout.write("%s %s %s" %(module.ljust(le,'.'), vers.ljust(le), ("Ok (version required is at least %s)"%str(vers_required)).ljust(le)))
            elif vers_required and vers < vers_required:
                sys.stdout.write("%s %s %s" %(module.ljust(le,'.'), vers.ljust(le), ("Error (version required is at least %s)"%str(vers_required)).ljust(le)))
            else:
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
