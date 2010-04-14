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
           'examples', 'tests','io','initialization','simulation',
           'linearization']

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


import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica.algorithm_drivers import *

import numpy as N

int = N.int32
N.int = N.int32


def optimize(model, 
             file_name='', 
             compiler_target='ipopt', 
             compiler_options={}, 
             algorithm=CollocationLagrangePolynomialsAlg, 
             alg_args={}, 
             solver_args={}):
    """ Compact function for model optimization.
    
    Pass a jmi.Model object or path to mo-file and model class if model 
    should be (re)compiled. There are default values for all other settings. 
    These can be changed in function call.
    
    Parameters:
        model -- 
            Model object or model class name (if class name then mo-file must be provided)
        file_name --
            Name of mo-file. 
            Default: empty string
        compiler_target --
            Target argument to compiler. 
            Default: 'ipopt'
        compiler_options --
            Dict with compiler options listed. 
            Default: empty dict
        algorithm --
            The optimization algorithm to use is specified by passing class name in 
            this argument. The algorithm class can be any class which implements the 
            abstract class algorithm_drivers.AlgorithmBase.
            Default: CollocationLagrangePolynomialsAlg
        alg_args --
            All arguments for the chosen algorithm should be listed in this dict.
            Default: empty dict
        solver_args --
            All arguments for the chosen solver should be listed in this dict.
            Default: empty dict
    
    """
    compiler='optimica'
    return _exec_algorithm(model, 
                           file_name,
                           compiler,
                           compiler_options,
                           compiler_target,
                           algorithm,
                           alg_args,
                           solver_args)

def simulate(model, 
             file_name='', 
             compiler='modelica', 
             compiler_options={}, 
             compiler_target='ipopt', 
             algorithm=AssimuloAlg, 
             alg_args={}, 
             solver_args={}):
    """ Compact function for model simulation.
    
    Pass a jmi.Model object or path to mo-file and model class if model 
    should be (re)compiled. There are default values for all other settings. 
    These can be changed in function call.
    
    Parameters:
        model -- 
            Model object or model class name (if class name then mo-file must be provided)
        file_name --
            Name of mo-file. 
            Default: empty string
        compiler --
            Set compiler that model should be compiled with.
            Default: 'modelica'
        compiler_target --
            Target argument to compiler. 
            Default: 'ipopt'
        compiler_options --
            Dict with compiler options listed. 
            Default: empty dict
        algorithm --
            The simulation algorithm to use is specified by passing class name in 
            this argument. The algorithm class can be any class which implements the 
            abstract class algorithm_drivers.AlgorithmBase.
            Default: AssimuloAlg
        alg_args --
            All arguments for the chosen algorithm should be listed in this dict.
            Default: empty dict
        solver_args --
            All arguments for the chosen solver should be listed in this dict.
            Default: empty dict
            
    Returns:
        model -- The jmi.Model object
        res -- The loaded result file.
    
    """
    return _exec_algorithm(model, 
                           file_name,
                           compiler,
                           compiler_options,
                           compiler_target,
                           algorithm,
                           alg_args,
                           solver_args)
      
def _exec_algorithm(model, 
             file_name, 
             compiler, 
             compiler_options, 
             compiler_target, 
             algorithm, 
             alg_args, 
             solver_args):
    """ Helper function which performs all steps of an algorithm run.
    
    Throws exception if algorithm is not a subclass of algorithm_drivers.AlgorithmBase.
    """

    if not issubclass(algorithm, AlgorithmBase):
        raise Exception(str(algorithm)+
                        " must be a subclass of jmodelica.algorithm_drivers.AlgorithmBase")

    if not isinstance(model, jmodelica.jmi.Model):
        # model class and mo-file must be set
         model = _compile(model, file_name, compiler=compiler, 
                          compiler_options=compiler_options, 
                          compiler_target=compiler_target)
         
    # initialize algorithm
    alg = algorithm(model, alg_args)
    # set arguments to solver, if any
    alg.set_solver_options(solver_args)
    # solve optimization problem/simulate
    alg.solve()
    # write result to file and get file name in return
    result_file_name = alg.write_result()
    # load result file
    res = jmodelica.io.ResultDymolaTextual(result_file_name)
    return (model,res)


def _compile(model_name, file_name, compiler='modelica', compiler_target = "ipopt", compiler_options={}):
    """ Helper function which performs compilation of chosen model.
    
    Returns jmi.Model object.
    """
    if isinstance(model_name, str) and file_name.strip():
        comp=None
        if compiler.lower() == 'modelica':
            comp = ModelicaCompiler()
        else:
            comp = OptimicaCompiler()
        # set compiler options
        for key, value in compiler_options.iteritems():
            if isinstance(value, bool):
                comp.set_boolean_option(key, value)
            elif isinstance(value, str):
                comp.set_string_option(key,value)
            elif isinstance(value, int):
                comp.set_integer_option(key,value)
            elif isinstance(value, float):
                comp.set_real_options(key,value)
            else:
                warnings.warn("Unknown compiler option: %s. " %key)
                
        #compile model
        comp.compile_model(model_name, file_name, target=compiler_target)
        # Load the dynamic library and XML data
        compiled_name = model_name.replace('.','_',1)
        model = jmi.Model(compiled_name)

    else:
        raise Exception("Provide a model name and a mo-file in \
            order for model to be (re)compiled.")
    return model

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
