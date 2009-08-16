#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import library for path manipulations
import os.path

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler as oc

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt

import scipy.integrate as int

#def run_demo():
#    """Demonstrate how to solve a minimum time
#    dynamic optimization problem based on a
#    Van der Pol oscillator system."""

curr_dir = os.path.dirname(os.path.abspath(__file__));
    
# Compile the Optimica model first to C code and
# then to a dynamic library
oc.compile_model(curr_dir+"/files/QuadTank.mo",
                 "QuadTank_pack.QuadTank_Opt",
                 target='ipopt')

# Load the dynamic library and XML data
qt=jmi.Model("QuadTank_pack_QuadTank_Opt")

x_A = N.array([7.e-2, 12e-2, 3.1720e-2,6.3169e-2,0])
u_A = N.array([2.8870,2.4321])

x_B = N.array([9.e-2, 12e-2, 4.9060e-2, 5.2061e-2])
u_B = N.array([2.6209,3.0247])

x_C = N.array([7.e-2,14.e-2,2.7689e-2,8.1416e-2])
u_C = N.array([3.2776,2.2723])

def res(y,t):
    for i in range(4):
        qt.getX()[i] = y[i]
    qt.jmimodel.ode_f()
    return qt.getDX()[0:4]

qt.setU(u_A)

t_sim = N.linspace(0.,200.,500)
y_sim = int.odeint(res,x_A,t_sim)

# Plot
plt.figure(1)
plt.clf()
plt.subplot(311)
plt.plot(t_sim,y_sim[:,0:4])
plt.grid()

qt.setU(u_B)

t_sim = N.linspace(0.,200.,500)
y_sim = int.odeint(res,x_B,t_sim)

# Plot
plt.figure(1)
plt.subplot(312)
plt.plot(t_sim,y_sim[:,0:4])
plt.grid()

qt.setU(u_C)

t_sim = N.linspace(0.,200.,500)
y_sim = int.odeint(res,x_C,t_sim)

# Plot
plt.figure(1)
plt.subplot(313)
plt.plot(t_sim,y_sim[:,0:4])
plt.grid()
plt.show()

qt.getPI()[13] = x_A[0]
qt.getPI()[14] = x_A[1]
qt.getPI()[15] = x_A[2]
qt.getPI()[16] = x_A[3]

qt.getPI()[17] = x_B[0]
qt.getPI()[18] = x_B[1]
qt.getPI()[19] = x_B[2]
qt.getPI()[20] = x_B[3]
qt.getPI()[21] = u_B[0]
qt.getPI()[22] = u_B[1]

# Initialize the mesh
n_e = 150 # Number of elements 
hs = N.ones(n_e)*1./n_e # Equidistant points
n_cp = 3; # Number of collocation points in each element

# Create an NLP object
nlp = jmi.SimultaneousOptLagPols(qt,n_e,hs,n_cp)

# Create an Ipopt NLP object
nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)

#nlp_ipopt.opt_sim_ipopt_set_string_option("derivative_test","first-order")
nlp_ipopt.opt_sim_ipopt_set_int_option("max_iter",500)

# Solve the optimization problem
nlp_ipopt.opt_sim_ipopt_solve()

# Retreive the number of points in each column in the
# result matrix
n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
n_points = n_points.value

# Create result data vectors
p_opt = N.zeros(1)
t_ = N.zeros(n_points)
dx_ = N.zeros(5*n_points)
x_ = N.zeros(5*n_points)
u_ = N.zeros(2*n_points)
w_ = N.zeros(n_points)

# Get the result
nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)

# Plot
plt.figure(2)
plt.clf()
plt.subplot(411)
plt.plot(t_,x_[0:n_points])
plt.grid()
plt.ylabel('x1')

plt.subplot(412)
plt.plot(t_,x_[n_points:n_points*2])
plt.grid()
plt.ylabel('x2')

plt.subplot(413)
plt.plot(t_,x_[n_points*2:n_points*3])
plt.grid()
plt.ylabel('x3')

plt.subplot(414)
plt.plot(t_,x_[n_points*3:n_points*4])
plt.grid()
plt.ylabel('x4')
plt.show()

plt.figure(3)
plt.clf()
plt.subplot(211)
plt.plot(t_,u_[0:n_points])
plt.grid()
plt.ylabel('u1')

plt.subplot(212)
plt.plot(t_,u_[n_points:n_points*2])
plt.grid()
plt.ylabel('u2')


# if __name__ == "__main__":
#     run_demo()
