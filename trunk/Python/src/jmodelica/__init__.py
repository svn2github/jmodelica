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


import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
from jmodelica.optimization import ipopt
from jmodelica.simulation.sundials import SundialsDAESimulator
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer

import numpy as N

    
def optimize(model, file="", compiler_options={}, n_e=50, n_cp=3, max_iter=-1, result_mesh='default', n_interpolation_points=20):
    """ Compact function for model optimization.
    
    Path to mo-file and model class must be provided. There are default values 
    for all other settings. These can be changed in function call.
    
    """
    recompile = True
    if isinstance(model, jmodelica.jmi.Model):
        #don't recompile
        recompile = False

    if recompile:
        model = _compile(model, file, compiler='optimica', compiler_options=compiler_options)
        
    # Create an NLP object
    hs = N.ones(n_e)*1./n_e # Equidistant points
    nlp = ipopt.NLPCollocationLagrangePolynomials(model,n_e,hs,n_cp)
    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)
    if max_iter > 0:
        nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",max_iter)
    # Solve the optimization problem                                       )
    nlp_ipopt.opt_sim_ipopt_solve()
    # Write to file.
    if result_mesh=='element_interpolation':
        nlp.export_result_dymola_element_interpolation(n_interpolation_points)
    else:
        nlp.export_result_dymola()

    res = jmodelica.io.ResultDymolaTextual(model.get_name()+'_result.txt')
    
    return (model,res)

def simulate(model, file="", compiler='modelica', compiler_options={}, do_initialize=True,
             verbosity=3, start_time=0.0,final_time=10.0, abstol=1.0e-6, reltol=1.0e-6, 
             time_step=0.01, return_last=False, sensitivity_analysis=False, input=None):
    """ Compact function for model simulation.
    
    Pass a jmi.Model object or path to mo-file and model class if model 
    should be (re)compiled. There are default values for all other settings. 
    These can be changed in function call.
    
    """
    recompile = True
    if isinstance(model, jmodelica.jmi.Model):
        #don't recompile
        recompile = False
    
    if recompile:
        # model class and mo-file must be set
         model = _compile(model, file, compiler, compiler_options)
    
    if do_initialize:
        model = initialize(model)
         
    simulator = SundialsDAESimulator(model, verbosity=verbosity, start_time=start_time, 
                                     final_time=final_time, abstol=abstol, reltol=reltol,
                                     time_step=time_step, return_last=return_last, 
                                     sensitivity_analysis=sensitivity_analysis, input=input)
    simulator.run()
    simulator.write_data()
    res = jmodelica.io.ResultDymolaTextual(model.get_name()+'_result.txt')
    
    return (model,res)

def initialize(model, file="", compiler='modelica',compiler_options={}):
    """ Compact function for model initialization.
    
    """
    recompile = True
    if isinstance(model, jmodelica.jmi.Model):
        #don't recompile
        recompile = False
    
    if recompile:
        # model class and mo-file must be set
        model = _compile(model, file, compiler, compiler_options)
             
    # Create DAE initialization object.
    init_nlp = NLPInitialization(model)
    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)
    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    return model


def _compile(model_name, file, compiler='modelica', compiler_options={}):
    if isinstance(model_name, str) and file.strip():
        comp=None
        if compiler.lower() == 'modelica':
            comp = ModelicaCompiler()
        else:
            comp = OptimicaCompiler()
        # set compiler options
        for key, value in compiler_options.iteritems():
            try:
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
            except UnknownOptionError, e:
                warnings.warn("Unknown compiler option: %s. " %key)
                
        #compile model
        comp.compile_model(file, model_name, target='ipopt')
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
