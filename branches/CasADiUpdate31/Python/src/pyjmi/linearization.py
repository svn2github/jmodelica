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

# References:
#     http://www.python.org/doc/2.5.2/lib/module-ctypes.html
#     http://starship.python.net/crew/theller/ctypes/tutorial.html
#     http://www.scipy.org/Cookbook/Ctypes 

import numpy as N
from collections import OrderedDict, Iterable
import pyjmi.jmi as jmi
from pyjmi.common.core import TrajectoryLinearInterpolation

int = N.int32
N.int = N.int32

def linearize_dae(model):
    """ 
    Linearize a DAE represented by a pyjmi.jmi.JMUModel object. The DAE is 
    represented by

      F(dx,x,u,w,t) = 0

    and the linearized model is given by

      E*dx = A*x + B*u + F*w + g

    where E, A, B, F and g are constant coefficient matrices. The linearization 
    is done around the current values of the dx, x, u, w, and t values in the 
    JMUModel object.

    The matrices are computed by evaluating Jacobians with the AD package CppAD 
    which provides derivatives with machine precision. (That is, no numerical 
    finite differences are used in the linearization.)
    
    Parameters::
    
        model --
            The jmi.JMUModel object representing the model.

    Returns::
    
        E -- 
            n_eq_F x n_dx matrix corresponding to dF/ddx.
            
        A -- 
            n_eq_F x n_x matrix corresponding to -dF/dx.
            
        B -- 
            n_eq_F x n_u matrix corresponding to -dF/du.
            
        F -- 
            n_eq_F x n_w matrix corresponding to -dF/dw.
            
        g -- 
            n_eq_F x 1 matrix corresponding to F(dx0,x0,u0,w0,t0)
            
        state_names -- 
            Names of the differential variables.
            
        input_names -- 
            Names of the input variables.
            
        algebraic_names -- 
            Names of the algebraic variables.
            
        dx0 -- 
            Derivative variable vector around which the linearization is done.
            
        x0 -- 
            Differential variable vector around which the linearization is done.
            
        u0 -- 
            Input variable vector around which the linearization is done.
            
        w0 -- 
            Algebraic variable vector around which the linearization is done.
            
        t0 -- 
            Time for which the linearization is done.  

    Limitations::
    
        Currently only dense matrix format supported. Sparse format to be added.
    """
    n_x = model._n_real_x.value
    n_u = model._n_real_u.value
    n_w = model._n_real_w.value
    n_z = model._n_z.value
    n_eq = n_x+n_w
    sc = model.jmimodel.get_variable_scaling_factors()
    
    if model.jmimodel.get_scaling_method() == jmi.JMI_SCALING_VARIABLES:
        sc_dx = []
        for var in model.get_dx_variable_names():
            if not model._get_XMLDoc().is_alias(var[1]):
                sc_dx.append(var[0])
        sc_dx = N.diag([1.0/sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set(sc_dx))])
        sc_x = []
        for var in model.get_x_variable_names():
            if not model._get_XMLDoc().is_alias(var[1]):
                sc_x.append(var[0])
        sc_x = N.diag([1.0/sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set(sc_x))])
        sc_w = []
        for var in model.get_w_variable_names():
            if not model._get_XMLDoc().is_alias(var[1]):
                sc_w.append(var[0])
        sc_w = N.diag([1.0/sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set(sc_w))])
        sc_u = []
        for var in model.get_u_variable_names():
            if not model._get_XMLDoc().is_alias(var[1]):
                sc_u.append(var[0])
        sc_u = N.diag([1.0/sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set(sc_u))])
    else:
        sc_dx = N.diag([1.0]*n_x)
        sc_x = N.diag([1.0]*n_x)
        sc_w = N.diag([1.0]*n_w)
        sc_u = N.diag([1.0]*n_u)
    #sc_dx = N.diag([sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set([var[0] for var in model.get_dx_variable_names()]))])
    #sc_x  = N.diag([sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set([var[0] for var in model.get_x_variable_names()]))])
    #sc_w  = N.diag([sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set([var[0] for var in model.get_w_variable_names()]))])
    #sc_u  = N.diag([sc[jmi._translate_value_ref(ref)[0]] for ref in sorted(set([var[0] for var in model.get_u_variable_names()]))])
    
    E = N.zeros((n_eq*n_x))

    model.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,
                          jmi.JMI_DER_DENSE_ROW_MAJOR,
                          jmi.JMI_DER_DX,
                          N.ones(n_z,dtype=int),
                          E)
    
    E = N.dot(N.reshape(E,(n_eq,n_x)),sc_dx)
    
    A = N.zeros((n_eq*n_x))
    
    model.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,
                          jmi.JMI_DER_DENSE_ROW_MAJOR,
                          jmi.JMI_DER_X,
                          N.ones(n_z,dtype=int),
                          A)
    
    A = N.dot(-N.reshape(A,(n_eq,n_x)),sc_x)
    
    B = N.zeros((n_eq*n_u))
    
    model.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,
                          jmi.JMI_DER_DENSE_ROW_MAJOR,
                          jmi.JMI_DER_U,
                          N.ones(n_z,dtype=int),
                          B)
    
    B = N.dot(-N.reshape(B,(n_eq,n_u)),sc_u)
    
    F = N.zeros((n_eq*n_w))
    
    model.jmimodel.dae_dF(jmi.JMI_DER_CPPAD,
                          jmi.JMI_DER_DENSE_ROW_MAJOR,
                          jmi.JMI_DER_W,
                          N.ones(n_z,dtype=int),
                          F)
    
    F = N.dot(-N.reshape(F,(n_eq,n_w)),sc_w)
    
    g = N.zeros(n_eq)
    
    model.jmimodel.dae_F(g)
    
    g = -N.transpose(N.matrix(g))

    state_names = model.get_x_variable_names(include_alias=False)
    #state_names = sorted([(v,k) for k,v in state_names.items()])
    state_names = sorted(state_names)
    state_names = [state_names[i][1] for i in range(len(state_names))]
    algebraic_names = model.get_w_variable_names(include_alias=False)
    #algebraic_names = sorted([(v,k) for k,v in algebraic_names.items()])
    algebraic_names = sorted(algebraic_names)
    algebraic_names = [algebraic_names[i][1] for i in range(len(algebraic_names))]
    input_names = model.get_u_variable_names(include_alias=False)
    input_names = sorted(input_names)
    #input_names = sorted([(v,k) for k,v in input_names.items()])
    input_names = [input_names[i][1] for i in range(len(input_names))]

    dx0 = N.zeros(n_x)
    x0 = N.zeros(n_x)
    u0 = N.zeros(n_u)
    w0 = N.zeros(n_w)
    t0 = N.zeros(1)

    dx0[:] = model.jmimodel.get_real_dx()*1/N.diag(sc_dx)#model.variable_scaling_factors[model._offs_real_dx.value:model._offs_real_dx.value+n_x]
    x0[:] = model.jmimodel.get_real_x()*1/N.diag(sc_x)#model.variable_scaling_factors[model._offs_real_x.value:model._offs_real_x.value+n_x]
    u0[:] = model.jmimodel.get_real_u()*1/N.diag(sc_u)#*model.variable_scaling_factors[model._offs_real_u.value:model._offs_real_u.value+n_u]
    w0[:] = model.jmimodel.get_real_w()*1/N.diag(sc_w)#*model.variable_scaling_factors[model._offs_real_w.value:model._offs_real_w.value+n_w]
    t0[:] = model.jmimodel.get_t()
    t0 = t0[0]
    
    return E,A,B,F,g,state_names,input_names,algebraic_names,dx0,x0,u0,w0,t0

def linear_dae_to_ode(E_dae,A_dae,B_dae,F_dae,g_dae):
    """ 
    Transform a linear constant coefficient index-1 DAE to ODE form. The DAE is 
    given by the system

      E_dae*dx = A_dae*x + B_dae*u + F_dae*w + g_dae

    where the matrix [E_dae,F_dae] is assumed to have full rank.

    The DAE is transformed into the ODE system

      dx = A*x + B*u + g
       w = H*x + M*u + q
       
    Parameters::
    
        E_dae -- 
        
        A_dae -- 
        
        B_dae -- 
        
        F_dae -- 
        
        g_dae -- 

    Returns::
    
        A -- 
            n_x x n_x matrix of constant coefficients.
            
        B -- 
            n_x x n_u matrix of constant coefficients.
            
        g -- 
            n_x x 1 matrix of constant coefficients.
            
        H -- 
            n_w x n_x matrix of constant coefficients.
            
        M -- 
            n_w x n_u matrix of constant coefficients.
            
        q -- 
            n_w x 1 matrix of constant coefficients
        
    Limitations::
    
        Outputs in the Modelica model are currently not taken into account - all 
        algebraic variables are provided as outputs. 
    """
    
    n_x = N.size(A_dae,1)
    n_u = N.size(B_dae,1)
    n_w = N.size(F_dae,1)

    EE = N.hstack((E_dae,-F_dae))
    AH = N.linalg.solve(EE,A_dae)
    BM = N.linalg.solve(EE,B_dae)
    gq = N.linalg.solve(EE,g_dae)

    A = AH[0:n_x,:]
    H = AH[n_x:,:]
    B = BM[0:n_x,:]
    M = BM[n_x:,:]
    g = gq[0:n_x,:]
    q = gq[n_x:,:]

    return A,B,g,H,M,q

def linearize_ode(model):
    """ 
    Linearize a DAE represented by a pyjmi.jmi.JMUModel object. The DAE is 
    represented by

      F(dx,x,u,w,t) = 0

    and the linearized model is given by

      dx = A*x + B*u + g
       w = H*x + M*u + q

    The linearization is performed performed by first linearizing the DAE using 
    pyjmi.linearization.linearize_dae and the resulting linear DAE is then 
    transformed into an ODE by the function 
    pyjmi.linearization.linear_dae_to_ode.

    Notice that the conversion into ODE form works only if the linear DAE has 
    index 1.
    
    Parameters::
    
        model --
            The jmi.JMUModel object representing the model.

    Returns::
    
        A -- 
            n_x x n_x matrix of constant coefficients.
            
        B -- 
            n_x x n_u matrix of constant coefficients.
            
        g -- 
            n_x x 1 matrix of constant coefficients.
            
        H -- 
            n_w x n_x matrix of constant coefficients.
            
        M -- 
            n_w x n_u matrix of constant coefficients.
            
        q -- 
            n_w x 1 matrix of constant coefficients.
            
        state_names -- 
            Names of the differential variables.
            
        input_names -- 
            Names of the input variables.
            
        algebraic_names -- 
            Names of the algebraic variables.
            
        dx0 -- 
            Derivative variable vector around which the linearization is done.
            
        x0 -- 
            Differential variable vector around which the linearization is done.
            
        u0 -- 
            Input variable vector around which the linearization is done.
            
        w0 -- 
            Algebraic variable vector around which the linearization is done.
            
        t0 -- 
            Time for which the linearization is done.  

    Limitations::
    
        Outputs in the Modelica model are currently not taken into account - all 
        algebraic variables are provided as outputs.         
    """

    E_dae_jmi,A_dae_jmi,B_dae_jmi,F_dae_jmi,g_dae_jmi,\
    state_names,input_names,algebraic_names,\
    dx0,x0,u0,w0,t0 = linearize_dae(model)

    A,B,g,H,M,q = linear_dae_to_ode(
        E_dae_jmi,A_dae_jmi,B_dae_jmi,F_dae_jmi,g_dae_jmi)

    return A,B,g,H,M,q,state_names,input_names,algebraic_names,dx0,x0,u0,w0,t0



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
    import casadi #Import in function since this module can be used without casadi
    
    optProblem.calculateValuesForDependentParameters()
    
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
    import casadi #Import in function since this module can be used without casadi
    
    optProblem.calculateValuesForDependentParameters()
    
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
    Fdae = casadi.Function('Fdae', [mvar_struct["time"], mvar_struct["dx"],
                           mvar_struct["x"], mvar_struct["w"],
                           mvar_struct["u"], mvar_struct["p_opt"]],
                          DAE)
    
    # Define derivatives
    dF_dt = Fdae.jacobian(0,0)
    dF_dxdot = Fdae.jacobian(1,0)
    dF_dx = Fdae.jacobian(2,0)
    dF_dw = Fdae.jacobian(3,0)
    dF_du = Fdae.jacobian(4,0)
    dF_dp = Fdae.jacobian(5,0)   
    
    # Compute reference point for the linearization [t0, dotx0, x0, w0, u0, p0]
    RefPoint=dict()
    var_kinds = ["dx","x", "w", "u", "p_opt"]
    
    traj = {}
    for vt in ["dx", "x", "w", "u", "p_opt"]:
        for var in mvar_vectors[vt]:
            name = var.getName()
            try:
                data = sim_result.result_data.get_variable_data(name)
            except (pyfmi.common.io.VariableNotFoundError, pyjmi.common.io.VariableNotFoundError):
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

    #~ for i,varType in enumerate(var_kinds):    
        #~ dF_dt.setInput(RefPoint[varType],i)
        #~ dF_dxdot.setInput(RefPoint[varType],i)
        #~ dF_dx.setInput(RefPoint[varType],i)
        #~ dF_dw.setInput(RefPoint[varType],i)
        #~ dF_du.setInput(RefPoint[varType],i)
        #~ dF_dp.setInput(RefPoint[varType],i)
        #~ Fdae.setInput(RefPoint[varType],i)
    
    #~ # Evaluate derivatives
    #~ dF_dt.evaluate()
    #~ dF_dxdot.evaluate()
    #~ dF_dx.evaluate()
    #~ dF_dw.evaluate()
    #~ dF_du.evaluate()
    #~ dF_dp.evaluate()
    #~ Fdae.evaluate()
    
    #~ # Store result in Matrices
    #~ D = -dF_dt.getOutput()[0]
    #~ E = dF_dxdot.getOutput()
    #~ A = -dF_dx.getOutput()
    #~ B = -dF_du.getOutput()
    #~ C = -dF_dw.getOutput()
    #~ h = Fdae.getOutput()
    #~ G = -dF_dp.getOutput() 
    
    input_list = []
    for i,varType in enumerate(var_kinds):
        input_list.append(RefPoint[varType])
    
    D = -dF_dt.call(input_list)[0]
    
    E = dF_dxdot.call(input_list)[0]
    A = -dF_dx.call(input_list)[0]
    B = -dF_du.call(input_list)[0]
    C = -dF_dw.call(input_list)[0]
    h = Fdae.call(input_list)[0]
    G = -dF_dp.call(input_list)[0]  
    
    return E, A , B ,C ,D , G, h, RefPoint
