#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
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
import sys

import casadi
from collections import OrderedDict, Iterable
from pyjmi.common.core import TrajectoryLinearInterpolation

try:
    import modelicacasadi_wrapper
    modelicacasadi_present = True
except ImportError:
    modelicacasadi_present = False
    
if modelicacasadi_present:
    from modelicacasadi_wrapper import OptimizationProblem as CI_OP
    from modelicacasadi_wrapper import Model as CI_Model
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
    model = Model() # no wrapper exists for Model yet
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
    op = OptimizationProblem()
    _transfer_optimization_problem(op, class_name=class_name, file_name=file_name,
                                   compiler_options=compiler_options,
                                   compiler_log_level=compiler_log_level,
                                   accept_model=accept_model)
    return op

def transfer_to_casadi_interface(*args, **kwargs):
    return transfer_optimization_problem(*args, **kwargs)
def linearize_dae_with_point(optProblem,t0,z0):


    """
    Linearize a DAE represented by an OptimizationProblem object. The DAE is 
    represented by
    
      F(dx,x,u,w,t) = 0

    and the linearized model is given by

      E*(dx-dx0) = A*(x-x0) + B*(u-u0) + C*(w-w0) + D*(t-t0) + G*(p-p0) + h

    where E, A, B, C, D ,G , and h are constant coefficient matrices. The 
    linearization is done around the reference point z0 specified by the user.
    
    The matrices are computed by evaluating Jacobians with CasADi. 
    (That is, no numerical finite differences are used in the linearization.)
    
    Parameters::
    
        z0 -- 
            Dictionary with the reference point around which 
            the linearization is done. 
            z0['variable_type']= [("variable_name",value),("name",z_r)]
            z0['x']= [("x1",v1),("x2",v2)...]
            z0['dx']= [("der(x1)",dv1),("der(x2)",dv2)...]
            z0['u']= [("u1",uv1),("u2",uv2)...]
            z0['w']= [("w1",wv1),("w2",wv2)...]
            z0['p_opt']= [("p1",pv1),("p2",pv2)...]
            
        t0 -- 
            Time for which the linearization is done.

    Returns::
    
        E -- 
            n_eq_F x n_dx matrix corresponding to dF/ddx.
            
        A -- 
            n_eq_F x n_x matrix corresponding to -dF/dx.
            
        B -- 
            n_eq_F x n_u matrix corresponding to -dF/du.
            
        C -- 
            n_eq_F x n_w matrix corresponding to -dF/dw.
            
        D --
            n_eq_F x 1  matrix corresponding to -dF/dt
            
        G --
            n_eq_F x n_p_opt  matrix corresponding to -dF/dp
            
        h -- 
            n_eq_F x 1 matrix corresponding to F(dx0,x0,u0,w0,t0)
            
        
    """
    
    # Get model variable vectors
    var_kinds = {'dx': optProblem.DERIVATIVE,
                 'x': optProblem.DIFFERENTIATED,
                 'u': optProblem.REAL_INPUT,
                 'w': optProblem.REAL_ALGEBRAIC} 
    mvar_vectors = {'dx': N.array([var for var in
                                   optProblem.getVariables(var_kinds['dx'])
                                   if not var.isAlias()]),
                    'x': N.array([var for var in
                                  optProblem.getVariables(var_kinds['x'])
                                  if not var.isAlias()]),
                    'u': N.array([var for var in
                                  optProblem.getVariables(var_kinds['u'])
                                  if not var.isAlias()]),
                    'w': N.array([var for var in
                                  optProblem.getVariables(var_kinds['w'])
                                  if not var.isAlias()])}
    # Count variables (uneliminated inputs and free parameters are counted
    # later)
    n_var = {'dx': len(mvar_vectors["dx"]),
             'x': len(mvar_vectors["x"]),
             'u': len(mvar_vectors["u"]),
             'w': len(mvar_vectors["w"])}
    
    # Sort parameters
    par_kinds = [optProblem.BOOLEAN_CONSTANT,
                 optProblem.BOOLEAN_PARAMETER_DEPENDENT,
                 optProblem.BOOLEAN_PARAMETER_INDEPENDENT,
                 optProblem.INTEGER_CONSTANT,
                 optProblem.INTEGER_PARAMETER_DEPENDENT,
                 optProblem.INTEGER_PARAMETER_INDEPENDENT,
                 optProblem.REAL_CONSTANT,
                 optProblem.REAL_PARAMETER_INDEPENDENT,
                 optProblem.REAL_PARAMETER_DEPENDENT]
    pars = reduce(list.__add__, [list(optProblem.getVariables(par_kind)) for
                                 par_kind in par_kinds])
    mvar_vectors['p_fixed'] = [par for par in pars
                               if not optProblem.get_attr(par, "free")]
    mvar_vectors['p_opt'] = [par for par in pars
                             if optProblem.get_attr(par, "free")]
    n_var['p_opt'] = len(mvar_vectors['p_opt'])   
    
    # Create named symbolic variable structure
    named_mvar_struct = OrderedDict()
    named_mvar_struct["time"] = [optProblem.getTimeVariable()]
    named_mvar_struct["dx"] = \
        [mvar.getVar() for mvar in mvar_vectors['dx']]    
    named_mvar_struct["x"] = \
        [mvar.getVar() for mvar in mvar_vectors['x']]
    named_mvar_struct["w"] = \
        [mvar.getVar() for mvar in mvar_vectors['w']]
    named_mvar_struct["u"] = \
        [mvar.getVar() for mvar in mvar_vectors['u']]    
    named_mvar_struct["p_opt"] = \
        [mvar.getVar() for mvar in mvar_vectors['p_opt']]
    
    # Get parameter values
    par_vars = [par.getVar() for par in mvar_vectors['p_fixed']]
    par_vals = [optProblem.get_attr(par, "_value")
                for par in mvar_vectors['p_fixed']]
    
    # Substitute non-free parameters in expressions for their values
    dae = casadi.substitute([optProblem.getDaeResidual()], par_vars, par_vals)
    
    # Substitute named variables with vector variables in expressions
    named_vars = reduce(list.__add__, named_mvar_struct.values()) 
    mvar_struct = OrderedDict()
    mvar_struct["time"] = casadi.MX.sym("time")
    mvar_struct["dx"] = casadi.MX.sym("dx", n_var['dx'])
    mvar_struct["x"] = casadi.MX.sym("x", n_var['x'])
    mvar_struct["w"] = casadi.MX.sym("w", n_var['w'])
    mvar_struct["u"] = casadi.MX.sym("u", n_var['u'])
    mvar_struct["p_opt"] = casadi.MX.sym("p_opt", n_var['p_opt'])
    svector_vars=[mvar_struct["time"]]
    
    
    # Create map from name to variable index and type
    name_map = {}
    for vt in ["dx","x", "w", "u", "p_opt"]:
        i = 0
        for var in mvar_vectors[vt]:
            name = var.getName()
            name_map[name] = (i, vt)
            svector_vars.append(mvar_struct[vt][i])
            i = i + 1

    # DAEResidual in terms of the substituted variables
    DAE = casadi.substitute(dae,
                            named_vars, 
                            svector_vars)    
    
    # Defines the DAEResidual Function
    Fdae = casadi.MXFunction([mvar_struct["time"], mvar_struct["dx"],
                           mvar_struct["x"], mvar_struct["w"],
                           mvar_struct["u"], mvar_struct["p_opt"]],
                          DAE)
    
    Fdae.init()
    # Define derivatives
    dF_dt = Fdae.jacobian(0,0)
    dF_dt.init()
    dF_dxdot = Fdae.jacobian(1,0)
    dF_dxdot.init()
    dF_dx = Fdae.jacobian(2,0)
    dF_dx.init()
    dF_dw = Fdae.jacobian(3,0)
    dF_dw.init()
    dF_du = Fdae.jacobian(4,0)
    dF_du.init()
    dF_dp = Fdae.jacobian(5,0)
    dF_dp.init()    
    
    # Compute reference point for the linearization [t0, dotx0, x0, w0, u0, p0]
    RefPoint=dict()
    var_kinds = ["dx","x", "w", "u", "p_opt"]            
    
    RefPoint["time"] = t0 
    
    #Sort Values for reference point
    stop=False
    for vt in z0.keys():
        RefPoint[vt] = N.zeros(n_var[vt])
        passed_indices = list()
        for var_tuple in z0[vt]:
            index = name_map[var_tuple[0]][0]
            value = var_tuple[1]
            RefPoint[vt][index] = value
            passed_indices.append(index)
        missing_indices = [i for i in range(n_var[vt]) \
                           if i not in passed_indices]
        if len(missing_indices)!=0:
            if not stop:
                sys.stderr.write("Error: Please provide the value for the following variables in z0:\n")
            for j in missing_indices:
                v = mvar_vectors[vt][j]
                name = v.getName()
                sys.stderr.write(name+"\n")
            stop=True

    if stop:
        sys.exit()
                
    missing_types = [vt for vt in var_kinds \
                     if vt not in z0.keys() and n_var[vt]!=0]
    if len(missing_types) !=0:
        sys.stderr.write("Error: Please provide the following types in z0:\n")
        for j in missing_types:
            sys.stderr.write(j + "\n")
        sys.exit() 
           
    for vk in var_kinds:
        if n_var[vk]==0:
            RefPoint[vk] = N.zeros(n_var[vk])
            
    #for vk in var_kinds:    
    #    print "RefPoint[ "+vk+" ]= ", RefPoint[vk]
        
    # Set inputs
    var_kinds = ["time"] + var_kinds
    for i,varType in enumerate(var_kinds):
        dF_dt.setInput(RefPoint[varType],i)
        dF_dxdot.setInput(RefPoint[varType],i)
        dF_dx.setInput(RefPoint[varType],i)
        dF_dw.setInput(RefPoint[varType],i)
        dF_du.setInput(RefPoint[varType],i)
        dF_dp.setInput(RefPoint[varType],i)
        Fdae.setInput(RefPoint[varType],i)
    
    # Evaluate derivatives
    dF_dt.evaluate()
    dF_dxdot.evaluate()
    dF_dx.evaluate()
    dF_dw.evaluate()
    dF_du.evaluate()
    dF_dp.evaluate()
    Fdae.evaluate()
    
    # Store result in Matrices
    D = -dF_dt.getOutput()
    E = dF_dxdot.getOutput()
    A = -dF_dx.getOutput()
    B = -dF_du.getOutput()
    C = -dF_dw.getOutput()
    h = Fdae.getOutput()
    G = -dF_dp.getOutput()
    
    return E, A, B, C, D, G, h
    
  
def linearize_dae_with_simresult(optProblem, t0, sim_result):


    """
    Linearize a DAE represented by an OptimizationProblem object. The DAE is 
    represented by
    
      F(t,dx,x,u,w,p) = 0

    and the linearized model is given by

      E*(dx-dx0) = A*(x-x0) + B*(u-u0) + C*(w-w0) + D*(t-t0) + G*(p-p0) + h

    where E, A, B, C, D ,G , and h are constant coefficient matrices. The 
    linearization is done around the reference point z0 specified by the user.
    
    The matrices are computed by evaluating Jacobians with CasADi. 
    (That is, no numerical finite differences are used in the linearization.)
    
    Parameters::
    
        sim_result -- 
            Variable trajectory data use to determine the reference point 
            around which the linearization is done 
            
            Type: None or pyjmi.common.io.ResultDymolaTextual or
                  pyjmi.common.algorithm_drivers.JMResultBase
            
        t0 -- 
            Time for which the linearization is done.

    Returns::
    
        E -- 
            n_eq_F x n_dx matrix corresponding to dF/ddx.
            
        A -- 
            n_eq_F x n_x matrix corresponding to -dF/dx.
            
        B -- 
            n_eq_F x n_u matrix corresponding to -dF/du.
            
        C -- 
            n_eq_F x n_w matrix corresponding to -dF/dw.
            
        D --
            n_eq_F x 1  matrix corresponding to -dF/dt
            
        G --
            n_eq_F x n_p_opt  matrix corresponding to -dF/dp
            
        h -- 
            n_eq_F x 1 matrix corresponding to F(dx0,x0,u0,w0,t0)
            
        RefPoint --
            dictionary with the values for the reference point 
            around which the linearization is done
    """
    
    # Get model variable vectors
    var_kinds = {'dx': optProblem.DERIVATIVE,
                 'x': optProblem.DIFFERENTIATED,
                 'u': optProblem.REAL_INPUT,
                 'w': optProblem.REAL_ALGEBRAIC} 
    mvar_vectors = {'dx': N.array([var for var in
                                   optProblem.getVariables(var_kinds['dx'])
                                   if not var.isAlias()]),
                    'x': N.array([var for var in
                                  optProblem.getVariables(var_kinds['x'])
                                  if not var.isAlias()]),
                    'u': N.array([var for var in
                                  optProblem.getVariables(var_kinds['u'])
                                  if not var.isAlias()]),
                    'w': N.array([var for var in
                                  optProblem.getVariables(var_kinds['w'])
                                  if not var.isAlias()])}
    # Count variables (uneliminated inputs and free parameters are counted
    # later)
    n_var = {'dx': len(mvar_vectors["dx"]),
             'x': len(mvar_vectors["x"]),
             'u': len(mvar_vectors["u"]),
             'w': len(mvar_vectors["w"])}
    
    # Sort parameters
    par_kinds = [optProblem.BOOLEAN_CONSTANT,
                 optProblem.BOOLEAN_PARAMETER_DEPENDENT,
                 optProblem.BOOLEAN_PARAMETER_INDEPENDENT,
                 optProblem.INTEGER_CONSTANT,
                 optProblem.INTEGER_PARAMETER_DEPENDENT,
                 optProblem.INTEGER_PARAMETER_INDEPENDENT,
                 optProblem.REAL_CONSTANT,
                 optProblem.REAL_PARAMETER_INDEPENDENT,
                 optProblem.REAL_PARAMETER_DEPENDENT]
    pars = reduce(list.__add__, [list(optProblem.getVariables(par_kind)) for
                                 par_kind in par_kinds])
    mvar_vectors['p_fixed'] = [par for par in pars
                               if not optProblem.get_attr(par, "free")]
    mvar_vectors['p_opt'] = [par for par in pars
                             if optProblem.get_attr(par, "free")]
    n_var['p_opt'] = len(mvar_vectors['p_opt'])   
    
    # Create named symbolic variable structure
    named_mvar_struct = OrderedDict()
    named_mvar_struct["time"] = [optProblem.getTimeVariable()]
    named_mvar_struct["dx"] = \
        [mvar.getVar() for mvar in mvar_vectors['dx']]    
    named_mvar_struct["x"] = \
        [mvar.getVar() for mvar in mvar_vectors['x']]
    named_mvar_struct["w"] = \
        [mvar.getVar() for mvar in mvar_vectors['w']]
    named_mvar_struct["u"] = \
        [mvar.getVar() for mvar in mvar_vectors['u']]    
    named_mvar_struct["p_opt"] = \
        [mvar.getVar() for mvar in mvar_vectors['p_opt']]
    
    # Get parameter values
    par_vars = [par.getVar() for par in mvar_vectors['p_fixed']]
    par_vals = [optProblem.get_attr(par, "_value")
                for par in mvar_vectors['p_fixed']]
    
    # Substitute non-free parameters in expressions for their values
    dae = casadi.substitute([optProblem.getDaeResidual()], par_vars, par_vals)
    
    # Substitute named variables with vector variables in expressions
    named_vars = reduce(list.__add__, named_mvar_struct.values()) 
    mvar_struct = OrderedDict()
    mvar_struct["time"] = casadi.MX.sym("time")
    mvar_struct["dx"] = casadi.MX.sym("dx", n_var['dx'])
    mvar_struct["x"] = casadi.MX.sym("x", n_var['x'])
    mvar_struct["w"] = casadi.MX.sym("w", n_var['w'])
    mvar_struct["u"] = casadi.MX.sym("u", n_var['u'])
    mvar_struct["p_opt"] = casadi.MX.sym("p_opt", n_var['p_opt'])
    svector_vars=[mvar_struct["time"]]
    
    
    # Create map from name to variable index and type
    name_map = {}
    for vt in ["dx","x", "w", "u", "p_opt"]:
        i = 0
        for var in mvar_vectors[vt]:
            name = var.getName()
            name_map[name] = (i, vt)
            svector_vars.append(mvar_struct[vt][i])
            i = i + 1

    # DAEResidual in terms of the substituted variables
    DAE = casadi.substitute(dae,
                            named_vars, 
                            svector_vars)    
    
    # Defines the DAEResidual Function
    Fdae = casadi.MXFunction([mvar_struct["time"], mvar_struct["dx"],
                           mvar_struct["x"], mvar_struct["w"],
                           mvar_struct["u"], mvar_struct["p_opt"]],
                          DAE)
    
    Fdae.init()
    # Define derivatives
    dF_dt = Fdae.jacobian(0,0)
    dF_dt.init()
    dF_dxdot = Fdae.jacobian(1,0)
    dF_dxdot.init()
    dF_dx = Fdae.jacobian(2,0)
    dF_dx.init()
    dF_dw = Fdae.jacobian(3,0)
    dF_dw.init()
    dF_du = Fdae.jacobian(4,0)
    dF_du.init()
    dF_dp = Fdae.jacobian(5,0)
    dF_dp.init()    
    
    # Compute reference point for the linearization [t0, dotx0, x0, w0, u0, p0]
    RefPoint=dict()
    var_kinds = ["dx","x", "w", "u", "p_opt"]
    
    traj = {}
    for vt in ["dx", "x", "w", "u", "p_opt"]:
        for var in mvar_vectors[vt]:
            name = var.getName()
            try:
                data = sim_result.result_data.get_variable_data(name)
            except VariableNotFoundError:
                print("Warning: Could not find initial " +
                      "trajectory for variable " + name +
                      ". Using initialGuess attribute value " +
                      "instead.")
                ordinates = N.array([[
                    op.get_attr(var, "initialGuess")]])
                abscissae = N.array([0])
            else:
                abscissae = data.t
                ordinates = data.x.reshape([-1, 1])
            traj[var] = TrajectoryLinearInterpolation(
                abscissae, ordinates)
            
    RefPoint["time"] = t0 
    
    
    for vk in var_kinds: 
        RefPoint[vk] = N.zeros(n_var[vk])
        for j in range(len(mvar_vectors[vk])):
            RefPoint[vk][j] = traj[mvar_vectors[vk][j]].eval(t0)[0][0]
            #print mvar_vectors[vk][j], "---->", RefPoint[vk][j]               
    
    #for vk in var_kinds:
    #    print "RefPoint[ "+vk+" ]= ", RefPoint[vk]
        
    
    # Set inputs
    var_kinds = ["time"] + var_kinds
    for i,varType in enumerate(var_kinds):
        dF_dt.setInput(RefPoint[varType],i)
        dF_dxdot.setInput(RefPoint[varType],i)
        dF_dx.setInput(RefPoint[varType],i)
        dF_dw.setInput(RefPoint[varType],i)
        dF_du.setInput(RefPoint[varType],i)
        dF_dp.setInput(RefPoint[varType],i)
        Fdae.setInput(RefPoint[varType],i)
    
    # Evaluate derivatives
    dF_dt.evaluate()
    dF_dxdot.evaluate()
    dF_dx.evaluate()
    dF_dw.evaluate()
    dF_du.evaluate()
    dF_dp.evaluate()
    Fdae.evaluate()
    
    # Store result in Matrices
    D = -dF_dt.getOutput()
    E = dF_dxdot.getOutput()
    A = -dF_dx.getOutput()
    B = -dF_du.getOutput()
    C = -dF_dw.getOutput()
    h = Fdae.getOutput()
    G = -dF_dp.getOutput()   
    
    return E, A , B ,C ,D , G, h, RefPoint
    
    

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
    class CI_Model:
        pass

class Model(CI_Model):

    """
    Python wrapper for the CasADi Interface class Model.
    """

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

class OptimizationProblem(Model, CI_OP, ModelBase):

    """
    Python wrapper for the CasADi Interface class OptimizationProblem.
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
    
class CasadiModel(ModelBase):
    
    """
    This class is obsolete.
    """
    
    def __init__(self, name, path='.', verbose=True, ode=False):
        raise NotImplementedError('CasadiModel is obsolete. \n \
        The CasadiPseudoSpectralAlg and LocalDAECollocationAlgOld \n \
        are no longer supported. To solve an optimization problem \n \
        with CasADi use pyjmi.transfer_optimization_problem instead.')
