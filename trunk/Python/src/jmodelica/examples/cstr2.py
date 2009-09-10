# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt
import scipy.integrate as integr
import scipy as S
import scipy.optimize as opt
import numpy.ctypeslib as Nct

# This example is based on a system composed of two
# Continously Stirred Tank Reactors (CSTRs) in series.
# The example demonstrates the following steps:
#
# 1. How to solve a DAE initialization problem. The initialization
#    model have equations specifying that all derivatives
#    should be identically zero, which implies that a
#    stationary solution is obtained. Two stationary points,
#    corresponding to different inputs, are computed. We call
#    the stationary points A and B respectively. For more information
#    about the DAE initialization algorithm, see
#    http://www.jmodelica.org/page/10.
#
# 2. An optimal control problem is solved where the objective
#    Is to transfer the state of the system from stationary
#    point A to point B. Here, it is also demonstrated how
#    to set parameter values in a model. More information
#    about the simultaneous optimization algorithm can be
#    found at http://www.jmodelica.org/page/10.
#
# 3. The optimization result is saved to file and then
#    the important variables are plotted.
#

curr_dir = os.path.dirname(os.path.abspath(__file__));

# Create a Modelica compiler instance
mc = ModelicaCompiler()

# Don't generate initial equations for states if fixed=false
mc.set_boolean_option('state_start_values_fixed',False)

# Compile the stationary initialization model into a DLL
mc.compile_model(curr_dir+"/files/CSTRLib.mo", "CSTRLib.Components.Two_CSTRs_stat_init", target='ipopt')
#mc.compile_dll("CSTRLib_Components_Two_CSTRs_stat_init",target='ipopt')

# Load a model instance into Python
init_model = jmi.Model("CSTRLib_Components_Two_CSTRs_stat_init")

# Create DAE initialization object.
init_nlp = jmi.DAEInitializationOpt(init_model)

# Create an Ipopt solver object for the DAE initialization system
init_nlp_ipopt = jmi.JMIDAEInitializationOptIPOPT(init_nlp)

# Set inputs for Stationary point A
u1_0_A = 1
u2_0_A = 1
init_model.set_value('u1',u1_0_A)
init_model.set_value('u2',u2_0_A)

# init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
#init_nlp_ipopt.init_opt_ipopt_set_int_option("max_iter",5)

# Solve the DAE initialization system with Ipopt
init_nlp_ipopt.init_opt_ipopt_solve()

# Store stationary point A
CA1_0_A = init_model.get_value('CA1')
CA2_0_A = init_model.get_value('CA2')
T1_0_A = init_model.get_value('T1')
T2_0_A = init_model.get_value('T2')

# Print some data for stationary point A
print(' *** Stationary point A ***')
print('u = [%f,%f]' % (u1_0_A,u2_0_A))
print('CAi = [%f,%f]' % (CA1_0_A,CA2_0_A))
print('Ti = [%f,%f]' % (T1_0_A,T2_0_A))

# Set inputs for stationary point B
u1_0_B = 1.1
u2_0_B = 0.9
init_model.set_value('u1',u1_0_B)
init_model.set_value('u2',u2_0_B)

# init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
#init_nlp_ipopt.init_opt_ipopt_set_int_option("max_iter",5)  

# Solve the DAE initialization system with Ipopt
init_nlp_ipopt.init_opt_ipopt_solve()

# Stationary point B
CA1_0_B = init_model.get_value('CA1')
CA2_0_B = init_model.get_value('CA2')
T1_0_B = init_model.get_value('T1')
T2_0_B = init_model.get_value('T2')

# Print some data for stationary point B
print(' *** Stationary point B ***')
print('u = [%f,%f]' % (u1_0_B,u2_0_B))
print('CAi = [%f,%f]' % (CA1_0_B,CA2_0_B))
print('Ti = [%f,%f]' % (T1_0_B,T2_0_B))

## Set up and solve an optimal control problem. 

# Create an OptimicaCompiler instance
oc = OptimicaCompiler()

# Compil the Model
oc.compile_model((curr_dir+"/files/CSTRLib.mo",
                  curr_dir+"/files/CSTR2_Opt.mo"), "CSTR2_Opt", target='ipopt')

# Load the dynamic library and XML data
model = jmi.Model("CSTR2_Opt")

# Initialize the model with parameters

# Initialize the model to stationary point A
model.set_value('two_CSTRs_Series.CA1_0',CA1_0_A)
model.set_value('two_CSTRs_Series.CA2_0',CA2_0_A)
model.set_value('two_CSTRs_Series.T1_0',T1_0_A)
model.set_value('two_CSTRs_Series.T2_0',T2_0_A)

# Set the target values to stationary point B
model.set_value('u1_ref',u1_0_B)
model.set_value('u2_ref',u2_0_B)
model.set_value('CA1_ref',CA1_0_B)
model.set_value('CA2_ref',CA2_0_B)

# Initialize the optimization mesh
n_e = 30 # Number of elements 
hs = N.ones(n_e)*1./n_e # Equidistant points
n_cp = 3; # Number of collocation points in each element

# Create an NLP object representing the discretized problem
nlp = jmi.SimultaneousOptLagPols(model,n_e,hs,n_cp)

# Create an Ipopt NLP object
nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)

#nlp_ipopt.opt_sim_ipopt_set_string_option("derivative_test","first-order")

# The convergence is slow, for some reason, increasing tolerance.
nlp_ipopt.opt_sim_ipopt_set_num_option("tol",0.0001)

#Solve the optimization problem
nlp_ipopt.opt_sim_ipopt_solve()

# Write to file. The resulting file (CSTR2_Opt_result.txt) can be
# loaded into Dymola.
nlp.export_result_dymola()

# Load the file we just wrote
res = jmodelica.io.ResultDymolaTextual('CSTR2_Opt_result.txt')

# Extract variable profiles
CA1_res=res.get_variable_data('two_CSTRs_Series.CA1')
CA2_res=res.get_variable_data('two_CSTRs_Series.CA2')
T1_res=res.get_variable_data('two_CSTRs_Series.T1')
T2_res=res.get_variable_data('two_CSTRs_Series.T2')
u1_res=res.get_variable_data('two_CSTRs_Series.u1')
u2_res=res.get_variable_data('two_CSTRs_Series.u2')

CA1_ref_res=res.get_variable_data('CA1_ref')
CA2_ref_res=res.get_variable_data('CA2_ref')

u1_ref_res=res.get_variable_data('u1_ref')
u2_ref_res=res.get_variable_data('u2_ref')

# Plot the results
plt.figure(1)
plt.clf()
plt.hold(True)
plt.subplot(211)
plt.plot(CA1_res.t,CA1_res.x)
plt.plot(CA1_ref_res.t,CA1_ref_res.x,'--')
plt.ylabel('Concentration reactor 1 [J/l]')
plt.grid()
plt.subplot(212)
plt.plot(CA2_res.t,CA2_res.x)
plt.plot(CA2_ref_res.t,CA2_ref_res.x,'--')
plt.ylabel('Concentration reactor 2 [J/l]')
plt.xlabel('t [s]')
plt.grid()
plt.show()

plt.figure(2)
plt.clf()
plt.hold(True)
plt.subplot(211)
plt.plot(T1_res.t,T1_res.x)
plt.ylabel('Temperature reactor 1 [K]')
plt.grid()
plt.subplot(212)
plt.plot(T2_res.t,T2_res.x)
plt.ylabel('Temperature reactor 2 [K]')
plt.grid()
plt.xlabel('t [s]')
plt.show()

plt.figure(3)
plt.clf()
plt.hold(True)
plt.subplot(211)
plt.plot(u1_res.t,u1_res.x)
plt.ylabel('Input 1')
plt.plot(u1_ref_res.t,u1_ref_res.x,'--')
plt.grid()
plt.subplot(212)
plt.plot(u2_res.t,u2_res.x)
plt.ylabel('Input 2')
plt.plot(u2_ref_res.t,u2_ref_res.x,'--')
plt.xlabel('t [s]')
plt.grid()
plt.show()

