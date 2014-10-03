#!/usr/bin/env python 
# -*- coding: utf-8 -*-

#    Copyright (C) 2011 Modelon AB
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

"""
Module containing the CasADi interface Python wrappers.
"""

import os.path
import numpy as N

import casadi

try:
    import modelicacasadi_wrapper
    modelicacasadi_present = True
except ImportError:
    modelicacasadi_present = False
    
if modelicacasadi_present:
    from modelicacasadi_wrapper import OptimizationProblem as CI_OP
    from modelicacasadi_transfer import transfer_model as _transfer_model
    from modelicacasadi_transfer import transfer_optimization_problem as _transfer_optimization_problem 

def transfer_model(class_name, file_name=[],
                   compiler_options={}, compiler_log_level='warning'):
    """ 
    Compiles and transfers a model to the ModelicaCasADi interface. 
    
    A model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
        
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.
                        
        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

                  
    Returns::
    
        A Model representing the class given by class_name.

"""
    model = modelicacasadi_wrapper.Model() # no wrapper exists for Model yet
    _transfer_model(model, class_name=class_name, file_name=file_name,
                    compiler_options=compiler_options,
                    compiler_log_level=compiler_log_level)
    return model

def transfer_optimization_problem(class_name, file_name=[],
                                  compiler_options={}, compiler_log_level='warning',
                                  accept_model=False):
    """ 
    Compiles and transfers an optimization problem to the ModelicaCasADi interface. 
    
    A  model class name must be passed, all other arguments have default values. 
    The different scenarios are:
    
    * Only class_name is passed: 
        - Class is assumed to be in MODELICAPATH.
    
    * class_name and file_name is passed:
        - file_name can be a single path as a string or a list of paths 
          (strings). The paths can be file or library paths.
    
    Library directories can be added to MODELICAPATH by listing them in a 
    special compiler option 'extra_lib_dirs', for example:
    
        compiler_options = 
            {'extra_lib_dirs':['c:\MyLibs1','c:\MyLibs2']}
        
    Other options for the compiler should also be listed in the compiler_options 
    dict.
    
        
    Parameters::
    
        class_name -- 
            The name of the model class.
            
        file_name -- 
            A path (string) or paths (list of strings) to model files and/or 
            libraries.
            Default: Empty list.

        compiler_options --
            Options for the compiler.
            Note that MODELICAPATH is set to the standard for this
            installation if not given as an option.
            Default: Empty dict.
            
        compiler_log_level --
            Set the logging for the compiler. Valid options are:
            'warning'/'w', 'error'/'e', 'info'/'i' or 'debug'/'d'. 
            Default: 'warning'

        accept_model --
            If true, allows to transfer a model. Only the model parts of the
            OptimizationProblem will be initialized.


    Returns::
    
        An OptimizationProblem representing the class given by class_name.

    """
    model = OptimizationProblem()
    _transfer_optimization_problem(model, class_name=class_name, file_name=file_name,
                                   compiler_options=compiler_options,
                                   compiler_log_level=compiler_log_level,
                                   accept_model=accept_model)
    return model

def transfer_to_casadi_interface(*args, **kwargs):
    return transfer_optimization_problem(*args, **kwargs)

from pyjmi.common.core import ModelBase, get_temp_location
from pyjmi.common import xmlparser
from pyjmi.common.xmlparser import XMLException
from pyfmi.common.core import (unzip_unit, get_platform_suffix,
                               get_files_in_archive, rename_to_tmp, load_DLL)

def convert_casadi_der_name(name):
    n = name.split('der_')[1]
    qnames = n.split('.')
    n = ''
    for i in range(len(qnames)-1):
        n = n + qnames[i] + '.'
    return n + 'der(' + qnames[len(qnames)-1] + ')' 

def unzip_fmux(archive, path='.'):
    """
    Unzip an FMUX.
    
    Looks for a model description XML file and returns the result in a dict with 
    the key words: 'model_desc'. If the file is not found an exception will be 
    raised.
    
    Parameters::
        
        archive --
            The archive file name.
            
        path --
            The path to the archive file.
            Default: Current directory.
            
    Raises::
    
        IOError the model description XML file is missing in the FMU.
    """
    tmpdir = unzip_unit(archive, path)
    fmux_files = get_files_in_archive(tmpdir)
    
    # check if all files have been found during unzip
    if fmux_files['model_desc'] == None:
        raise IOError('ModelDescription.xml not found in FMUX archive: '+str(archive))
    
    return fmux_files

if not modelicacasadi_present:
    # Dummy class so that OptimizationProblem won't give an error.
    # todo: exclude OptimizationProblem instead?
    class CI_OP:
        pass

class OptimizationProblem(CI_OP, ModelBase):

    """
    Python wrapper for the CasADi interface class OptimizationProblem.
    """
        
    def _default_options(self, algorithm):
        """ 
        Help method. Gets the options class for the algorithm specified in 
        'algorithm'.
        """
        base_path = 'pyjmi.jmi_algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'jmi_algorithm_drivers')
        algorithm = getattr(algdrive, algorithm)
        return algorithm.get_default_options()

    def optimize_options(self, algorithm='LocalDAECollocationAlg'):
        """
        Returns an instance of the optimize options class containing options 
        default values. If called without argument then the options class for 
        the default optimization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be returned. 
                Possible values are: 'LocalDAECollocationAlg' and
                'CasadiPseudoSpectralAlg'
                Default: 'LocalDAECollocationAlg'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)

    def get_attr(self, var, attr):
        """
        Helper method for getting values of variable attributes.

        Parameters::

            var --
                Variable object to get attribute value from.

                Type: Variable

            attr --
                Attribute whose value is sought.

                If var is a parameter and attr == "_value", the value of the
                parameter is returned.

                Type: str

        Returns::

            Value of attribute attr of Variable var.
        """
        if attr == "_value":
            val = var.getAttribute('evaluatedBindingExpression')
            if val is None:
                val = var.getAttribute('bindingExpression')
                if val is None:
                    if var.getVariability() != var.PARAMETER:
                        raise ValueError("%s is not a parameter." %
                                         var.getName())
                    else:
                        raise RuntimeError("BUG: Unable to evaluate " +
                                           "value of %s." % var.getName())
            return val.getValue()
        elif attr == "comment":
            var_desc = var.getAttribute("comment")
            if var_desc is None:
                return ""
            else:
                return var_desc.getName()
        elif attr == "nominal":
            if var.isDerivative():
                var = var.getMyDifferentiatedVariable()
            val_expr = var.getAttribute(attr)
            return self.evaluateExpression(val_expr)
        else:
            val_expr = var.getAttribute(attr)
            if val_expr is None:
                if attr == "free":
                    return False
                elif attr == "initialGuess":
                    return self.get_attr(var, "start")
                else:
                    raise ValueError("Variable %s does not have attribute %s."
                                     % (var.getName(), attr))
            return self.evaluateExpression(val_expr)
    
    def optimize(self, algorithm='LocalDAECollocationAlg', options={}):
        """
        Solve an optimization problem.
            
        Parameters::
            
            algorithm --
                The algorithm which will be used for the optimization is 
                specified by passing the algorithm class name as string or class 
                object in this argument. 'algorithm' can be any class which 
                implements the abstract class AlgorithmBase (found in 
                algorithm_drivers.py). In this way it is possible to write 
                custom algorithms and to use them with this function.

                The following algorithms are available:
                - 'LocalDAECollocationAlg'. This algorithm is based on direct
                  collocation on finite elements and the algorithm IPOPT is
                  used to obtain a numerical solution to the problem.
                Default: 'LocalDAECollocationAlg'
                
            options -- 
                The options that should be used in the algorithm. The options
                documentation can be retrieved from an options object:
                
                    >>> myModel = CasadiModel(...)
                    >>> opts = myModel.optimize_options(algorithm)
                    >>> opts?

                Valid values are: 
                - A dict that overrides some or all of the algorithm's default
                  values. An empty dict will thus give all options with default
                  values.
                - An Options object for the corresponding algorithm, e.g.
                  LocalDAECollocationAlgOptions for LocalDAECollocationAlg.
                Default: Empty dict
            
        Returns::
            
            A result object, subclass of algorithm_drivers.ResultBase.
        """
        if algorithm != "LocalDAECollocationAlg":
            raise ValueError("LocalDAECollocationAlg is the only supported " +
                             "algorithm.")
        return self._exec_algorithm('pyjmi.jmi_algorithm_drivers',
                                    algorithm, options)

