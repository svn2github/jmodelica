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

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler
from jmodelica.initialization.ipopt import NLPInitialization
from jmodelica.initialization.ipopt import InitializationOptimizer
from jmodelica.optimization import ipopt

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt
import scipy.integrate as integr
import scipy as S
import scipy.optimize as opt
import numpy.ctypeslib as Nct

def run_demo(with_plots=True):
    """ Load change of a distillation column. The distillation column model
    is documented in the paper:

    @Article{hahn+02,
    title={An improved method for nonlinear model reduction using balancing of empirical gramians},
    author={Hahn, J. and Edgar, T.F.},
    journal={Computers and Chemical Engineering},
    volume={26},
    number={10},
    pages={1379-1397},
    year={2002}
    }
    """
    
    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Create a Modelica compiler instance
    mc = ModelicaCompiler()

    # Compile the stationary initialization model into a DLL
    mc.compile_model(curr_dir+"/files/DISTLib.mo", "DISTLib.Binary_Dist_initial", target='ipopt')

    # Load a model instance into Python
    init_model = jmi.Model("DISTLib_Binary_Dist_initial")

    # Create DAE initialization object.
    init_nlp = NLPInitialization(init_model)

    # Create an Ipopt solver object for the DAE initialization system
    init_nlp_ipopt = InitializationOptimizer(init_nlp)

    # Set inputs for Stationary point A
    u1_0_A = 3.0
    init_model.set_value('u1',u1_0_A)

    # init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
    #init_nlp_ipopt.init_opt_ipopt_set_int_option("max_iter",5)

    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    # Store stationary point A
    y_A = N.zeros(32)
    x_A = N.zeros(32)
    # print(' *** Stationary point A ***')
    print '(Tray index, x_i_A, y_i_A)'
    for i in range(N.size(y_A)):
        y_A[i] = init_model.get_value('y[' + str(i+1) + ']')
        x_A[i] = init_model.get_value('x[' + str(i+1) + ']')
        print '(' + str(i+1) + ', %f, %f)' %(x_A[i], y_A[i])
    
    # Set inputs for stationary point B
    u1_0_B = 3.0 - 1
    init_model.set_value('u1',u1_0_B)

    # init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
    #init_nlp_ipopt.init_opt_ipopt_set_int_option("max_iter",5)  

    # Solve the DAE initialization system with Ipopt
    init_nlp_ipopt.init_opt_ipopt_solve()

    # Store stationary point B
    y_B = N.zeros(32)
    x_B = N.zeros(32)
    # print(' *** Stationary point B ***')
    print '(Tray index, x_i_B, y_i_B)'
    for i in range(N.size(y_B)):
        y_B[i] = init_model.get_value('y[' + str(i+1) + ']')
        x_B[i] = init_model.get_value('x[' + str(i+1) + ']')
        print '(' + str(i+1) + ', %f, %f)' %(x_B[i], y_B[i])

    # ## Set up and solve an optimal control problem. 

    # Create an OptimicaCompiler instance
    oc = OptimicaCompiler()

    # Generate initial equations for states even if fixed=false
    oc.set_boolean_option('state_start_values_fixed',True)

    # Compil the Model
    oc.compile_model((curr_dir+"/files/DISTLib.mo",
                  curr_dir+"/files/DISTLib_Opt.mo"), "DISTLib_Opt.Binary_Dist_Opt1", target='ipopt')

    # Load the dynamic library and XML data
    model = jmi.Model("DISTLib_Opt_Binary_Dist_Opt1")

    # Initialize the model with parameters

    # Initialize the model to stationary point A
    for i in range(N.size(x_A)):
        model.set_value('x_0[' + str(i+1) + ']', x_A[i])

    # Set the target values to stationary point B
    model.set_value('u1_ref',u1_0_B)
    model.set_value('y1_ref',y_B[0])

    # Initialize the optimization mesh
    n_e = 50 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object representing the discretized problem
    nlp = ipopt.NLPCollocationLagrangePolynomials(model,n_e,hs,n_cp)

    # Create an Ipopt NLP object
    nlp_ipopt = ipopt.CollocationOptimizer(nlp)
    
    #nlp_ipopt.opt_sim_ipopt_set_string_option("derivative_test","first-order")

    # If the convergence is slow, may increase tolerance.
    #nlp_ipopt.opt_sim_ipopt_set_num_option("tol",0.0001)

    #Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Write to file. The resulting file  can be
    # loaded into Dymola.
    nlp.export_result_dymola()

    # Load the file we just wrote
    res = jmodelica.io.ResultDymolaTextual('DISTLib_Opt_Binary_Dist_Opt1_result.txt')

    # Extract variable profiles
    u1_res = res.get_variable_data('u1')
    u1_ref_res = res.get_variable_data('u1_ref')
    y1_ref_res = res.get_variable_data('y1_ref')

    x_res = []
    x_ref_res = []
    for i in range(N.size(x_B)):
        x_res.append(res.get_variable_data('x[' + str(i+1) + ']'))

    y_res = []
    for i in range(N.size(x_B)):
        y_res.append(res.get_variable_data('y[' + str(i+1) + ']'))
        
    cost=res.get_variable_data('cost')
    
    assert N.abs(cost.x[-1]/1.e1 - 2.8527469) < 1e-3, \
            "Wrong value of cost function in distillation.py"


    # Plot the results
    if with_plots:
        plt.figure(1)
        plt.clf()
        plt.hold(True)
        plt.subplot(311)
        plt.title('Liquid composition')
        plt.plot(x_res[0].t,x_res[0].x)
        plt.ylabel('x1')
        plt.grid()
        plt.subplot(312)
        plt.plot(x_res[16].t,x_res[16].x)
        plt.ylabel('x17')
        plt.grid()
        plt.subplot(313)
        plt.plot(x_res[31].t,x_res[31].x)
        plt.ylabel('x32')
        plt.grid()
        plt.xlabel('t [s]')
        plt.show()
        
        # Plot the results
        plt.figure(2)
        plt.clf()
        plt.hold(True)
        plt.subplot(311)
        plt.title('Vapor composition')
        plt.plot(y_res[0].t,y_res[0].x)
        plt.plot(y1_ref_res.t,y1_ref_res.x,'--')
        plt.ylabel('y1')
        plt.grid()
        plt.subplot(312)
        plt.plot(y_res[16].t,y_res[16].x)
        plt.ylabel('y17')
        plt.grid()
        plt.subplot(313)
        plt.plot(y_res[31].t,y_res[31].x)
        plt.ylabel('y32')
        plt.grid()
        plt.xlabel('t [s]')
        plt.show()
        
        
        plt.figure(3)
        plt.clf()
        plt.hold(True)
        plt.plot(u1_res.t,u1_res.x)
        plt.ylabel('u')
        plt.plot(u1_ref_res.t,u1_ref_res.x,'--')
        plt.xlabel('t [s]')
        plt.title('Reflux ratio')
        plt.grid()
        plt.show()

if __name__ == "__main__":
    run_demo()

