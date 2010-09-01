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
           'linearization', 'algorithm_drivers']

__version__='1.3b1'

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
import jmodelica.jmi as jmi
import jmodelica.fmi as fmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica.algorithm_drivers import *

import numpy as N

int = N.int32
N.int = N.int32

try:
    ipopt_present = jmodelica.environ['IPOPT_HOME']
except:
    ipopt_present = False

def optimize(model, 
             file_name='', 
             compiler_target='ipopt', 
             compiler_options={}, 
             algorithm=CollocationLagrangePolynomialsAlg, 
             alg_args={}, 
             solver_args={}):
    """ Compact function for model optimization.
    
    The intention with this function is to wrap model compilation, creation of 
    a model object and optimization in one function call. The optimization 
    method depends on which algorithm is used, this can be set with the 
    function argument 'algorithm'. Arguments for the algorithm and solver are 
    passed as dicts. Which arguments that are valid depends on which algorithm 
    is used, see the algorithm implementation in algorithm_drivers.py for details.
    
    The default algorithm for this function is CollocationLagrangePolynomialsAlg. 
    
    The simplest way of using the function is to pass the model name and path 
    to the model file (a jmi.Model is enough if model is already compiled) and 
    use the default values for all other arguments.
    
    Parameters::
    
        model -- 
            Model object or model name (supply model name if model should be 
            (re)compiled, then mo-file(s) must also be provided)
        file_name --
            Path to model file or list of paths to model files. 
            Default: empty string (no compilation)
        compiler_target --
            Target argument to compiler. 
            Default: 'ipopt'
        compiler_options --
            Dict with options for the compiler (see options.xml for possible 
            values). 
            Default: empty dict
        algorithm --
            The algorithm which will be used for the simulation is 
            specified by passing the algorithm class in this argument. The 
            algorithm class can be any class which implements the abstract 
            class AlgorithmBase (found in algorithm_drivers.py). In this way 
            it is possible to write own algorithms and use them with this 
            function.
            Default: CollocationLagrangePolynomialsAlg
        alg_args --
            All arguments for the chosen algorithm should be listed in this dict.
            Valid arguments depend on the algorithm chosen, see algorithm 
            implementation in algorithm_drivers.py for details.      
            Default: empty dict
        solver_args --
            All arguments for the chosen solver should be listed in this dict.
            Valid arguments depend on the chosen algorithm and possibly which 
            solver has been selected for the algorithm. See algorithm 
            implementation in algorithm_drivers.py for details.
            Default: empty dict
    
    Returns::
    
        Result object, subclass of algorithm_drivers.ResultBase.
    
    
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
    
    The intention with this function is to wrap model compilation, creation of 
    a model object and simulation in one function call. The simulation 
    method depends on which algorithm is used, this can be set with the 
    function argument 'algorithm'. Arguments for the algorithm and solver are 
    passed as dicts. Which arguments that are valid depends on which algorithm 
    is used, see the algorithm implementation in algorithm_drivers.py for details.
    
    The default algorithm for this function is AssimuloAlg. 
    
    The simplest way of using the function is to pass the model name and path 
    to the model file (a jmi.Model is enough if model is already compiled) and 
    use the default values for all other arguments.
    
    Parameters::
    
        model -- 
            Model object or model name (supply model name if model should be 
            (re)compiled, then mo-file must also be provided)
        file_name --
            Path to model file or list of paths to model files.
            Default: empty string (no compilation)
        compiler --
            Set compiler that model should be compiled with, 'modelica' or 
            'optimica'.
            Default: 'modelica'
        compiler_target --
            Target argument to compiler. 
            Default: 'ipopt'
        compiler_options --
            Dict with options for the compiler (see options.xml for possible 
            values). 
            Default: empty dict
        algorithm --
            The algorithm which will be used for the simulation is 
            specified by passing the algorithm class in this argument. The 
            algorithm class can be any class which implements the abstract 
            class AlgorithmBase (found in algorithm_drivers.py). In this way 
            it is possible to write own algorithms and use them with this 
            function.
            Default: AssimuloAlg
        alg_args --
            All arguments for the chosen algorithm should be listed in this dict.
            Valid arguments depend on the algorithm chosen, see algorithm 
            implementation in algorithm_drivers.py for details.      
            Default: empty dict
        solver_args --
            All arguments for the chosen solver should be listed in this dict.
            Valid arguments depend on the chosen algorithm and possibly which 
            solver has been selected for the algorithm. See algorithm 
            implementation in algorithm_drivers.py for details.
            Default: empty dict
    
    Returns::
    
        Result object, subclass of algorithm_drivers.ResultBase.
    
    """
    return _exec_algorithm(model, 
                           file_name,
                           compiler,
                           compiler_options,
                           compiler_target,
                           algorithm,
                           alg_args,
                           solver_args)

def initialize(model, 
               file_name='', 
               compiler='modelica', 
               compiler_options={}, 
               compiler_target='ipopt', 
               algorithm=IpoptInitializationAlg, 
               alg_args={}, 
               solver_args={}):
    """ Compact function for model initialization.
    
    The intention with this function is to wrap model compilation, creation of 
    a model object and initialization in one function call. The initialization 
    method depends on which algorithm is used, this can be set with the 
    function argument 'algorithm'. Arguments for the algorithm and solver are 
    passed as dicts. Which arguments that are valid depends on which algorithm 
    is used, see the algorithm implementation in algorithm_drivers.py for details.
    
    The default algorithm for this function is IpoptInitializationAlg. 
    
    The simplest way of using the function is to pass the model name and path 
    to the model file (a jmi.Model is enough if model is already compiled) and 
    use the default values for all other arguments.
    
    Parameters::
    
        model -- 
            Model object or model name (supply model name if model should be 
            (re)compiled, then mo-file must also be provided)
        file_name --
            Path to model file or list of paths to model files. 
            Default: empty string (no compilation)
        compiler --
            Set compiler that model should be compiled with, 'modelica' or 
            'optimica'.
            Default: 'modelica'
        compiler_target --
            Target argument to compiler. 
            Default: 'ipopt'
        compiler_options --
            Dict with options for the compiler (see options.xml for possible 
            values). 
            Default: empty dict
        algorithm --
            The algorithm which will be used for the initialization is 
            specified by passing the algorithm class in this argument. The 
            algorithm class can be any class which implements the abstract 
            class AlgorithmBase (found in algorithm_drivers.py). In this way 
            it is possible to write own algorithms and use them with this 
            function.
            Default: IpoptInitializationAlg
        alg_args --
            All arguments for the chosen algorithm should be listed in this dict.
            Valid arguments depend on the algorithm chosen, see algorithm 
            implementation in algorithm_drivers.py for details.      
            Default: empty dict
        solver_args --
            All arguments for the chosen solver should be listed in this dict.
            Valid arguments depend on the chosen algorithm and possibly which 
            solver has been selected for the algorithm. See algorithm 
            implementation in algorithm_drivers.py for details.
            Default: empty dict
            
    Returns::
    
        Result object, subclass of algorithm_drivers.ResultBase.
    
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
    """ Helper function which performs all steps of an algorithm run which are 
    common to all algortihms.
    
    Throws exception if algorithm is not a subclass of algorithm_drivers.AlgorithmBase.
    """

    if not issubclass(algorithm, AlgorithmBase):
        raise Exception(str(algorithm)+
                        " must be a subclass of jmodelica.algorithm_drivers.AlgorithmBase")

    if isinstance(model, str) and file_name !='':
        # model class and mo-file must be set
        
        if not ipopt_present and compiler_target=='ipopt':
            raise Exception('Could not find IPOPT. Check jmodelica.check_packages()')
        
        model = _compile(model, file_name, compiler=compiler, 
                          compiler_options=compiler_options, 
                          compiler_target=compiler_target)
    
    if isinstance(model,str) and model.lower().endswith('.fmu') and issubclass(algorithm, AssimuloAlg):
        algorithm = AssimuloFMIAlg
    if isinstance(model,fmi.FMIModel) and issubclass(algorithm, AssimuloAlg):
        algorithm = AssimuloFMIAlg

    # initialize algorithm
    alg = algorithm(model, alg_args)
    # set arguments to solver, if any
    alg.set_solver_options(solver_args)
    # solve optimization problem/simulate
    alg.solve()
    # get and return result
    return alg.get_result()
    
def _compile(model_name, file_name, compiler='modelica', compiler_target = "ipopt", compiler_options={}):
    """ Helper function which performs compilation of chosen model.
    
    Returns jmi.Model object.
    """
    if isinstance(file_name, str):
        file_name = [file_name]
    if isinstance(model_name, str) and len(file_name)>0:
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
        raise Exception("Provide a model name and one or more \
            mo-file(s) in order for model to be (re)compiled.")
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
        sys.stdout.write("could not be found. It is not possible to run the jmodelica package without them.\n")
    
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
This package is needed in the jmodelica.tests package. You will not be able to run any tests.")
		
            sys.stdout.write("\n\n")


