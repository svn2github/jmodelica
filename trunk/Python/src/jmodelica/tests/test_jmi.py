""" Test module for testing the jmi module
"""

import os
import os.path

import nose

import jmodelica.jmi as jmi
import jmodelica.optimicacompiler as oc
import jmodelica.xmlparser as xp
import jmodelica.io
import matplotlib.pyplot as plt

import numpy as N

sep = os.path.sep

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = sep + "Python" + sep + "jmodelica" + sep + "examples"

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    oc.set_log_level(oc.LOG_ERROR)

def test_jmi_opt_sim_set_initial_from_trajectory():
    """ Test of 'jmi_opt_sim_set_initial_from_trajectory'.

    An optimization problem is solved and then the result
    is used to reinitialize the NLP. The variable profiles
    are then retrieved and a check is performed wheather
    they match.
    """
    
    model = sep + "vdp_minimum_time" + sep + "VDP.mo"
    fpath = jm_home+path_to_examples+model
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(fpath, cpath, target='ipopt')

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)


    # Initialize the mesh
    n_e = 100 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object
    nlp = jmi.SimultaneousOptLagPols(vdp,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)
    
    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()
    
    # Retreive the number of points in each column in the
    # result matrix
    n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
    n_points = n_points.value
    
    # Create result data vectors
    p_opt = N.zeros(1)
    t_ = N.zeros(n_points)
    dx_ = N.zeros(2*n_points)
    x_ = N.zeros(2*n_points)
    u_ = N.zeros(n_points)
    w_ = N.zeros(n_points)
    
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)

    z_ = N.concatenate((t_,dx_,x_,u_))
    hs = N.zeros(1)

    vdp.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory(nlp.jmi_simoptlagpols._jmi_opt_sim,p_opt,z_,hs,0.,0.)
    
    p_opt2 = N.zeros(1)
    t_2 = N.zeros(n_points)
    dx_2 = N.zeros(2*n_points)
    x_2 = N.zeros(2*n_points)
    u_2 = N.zeros(n_points)
    w_2 = N.zeros(n_points)
        
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt2,t_2,dx_2,x_2,u_2,w_2)
    
    assert max(N.abs(x_-x_2))<1e-12, \
           "The values used in initialization does not match the values that were read back after initialization."        


def test_set_initial_from_dymola():
    """ Test of 'jmi_opt_sim_set_initial_from_trajectory'.

    An optimization problem is solved and then the result
    is used to reinitialize the NLP. The variable profiles
    are then retrieved and a check is performed wheather
    they match.
    """
    
    model = sep + "vdp_minimum_time" + sep + "VDP.mo"
    fpath = jm_home+path_to_examples+model
    cpath = "VDP_pack.VDP_Opt"
    fname = cpath.replace('.','_',1)

    oc.compile_model(fpath, cpath, target='ipopt')

    # Load the dynamic library and XML data
    vdp = jmi.Model(fname)


    # Initialize the mesh
    n_e = 100 # Number of elements 
    hs = N.ones(n_e)*1./n_e # Equidistant points
    n_cp = 3; # Number of collocation points in each element
    
    # Create an NLP object
    nlp = jmi.SimultaneousOptLagPols(vdp,n_e,hs,n_cp)
    
    # Create an Ipopt NLP object
    nlp_ipopt = jmi.JMISimultaneousOptIPOPT(nlp.jmi_simoptlagpols)
    
    # Solve the optimization problem
    nlp_ipopt.opt_sim_ipopt_solve()

    # Retreive the number of points in each column in the
    # result matrix
    n_points = nlp.jmi_simoptlagpols.opt_sim_get_result_variable_vector_length()
    n_points = n_points.value

    # Create result data vectors
    p_opt = N.zeros(1)
    t_ = N.zeros(n_points)
    dx_ = N.zeros(2*n_points)
    x_ = N.zeros(2*n_points)
    u_ = N.zeros(n_points)
    w_ = N.zeros(n_points)
    
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)

    # Write to file
    nlp.export_result_dymola()

    # Load the file we just wrote
    res = jmodelica.io.ResultDymolaTextual(fname+'_result.txt')

    nlp.set_initial_from_dymola(res,hs,0.,0.)

    # Create result data vectors
    p_opt_2 = N.zeros(1)
    t_2 = N.zeros(n_points)
    dx_2 = N.zeros(2*n_points)
    x_2 = N.zeros(2*n_points)
    u_2 = N.zeros(n_points)
    w_2 = N.zeros(n_points)
    
    # Get the result
    nlp.jmi_simoptlagpols.opt_sim_get_result(p_opt_2,t_2,dx_2,x_2,u_2,w_2)


    assert max(N.abs(p_opt-p_opt_2))<1e-3, \
           "The values used in initialization does not match the values that were read back after initialization." 
    assert max(N.abs(dx_-dx_2))<1e-3, \
           "The values used in initialization does not match the values that were read back after initialization." 
    assert max(N.abs(x_-x_2))<1e-3, \
           "The values used in initialization does not match the values that were read back after initialization." 
    assert max(N.abs(u_-u_2))<1e-3, \
           "The values used in initialization does not match the values that were read back after initialization." 
    assert max(N.abs(w_-w_2))<1e-3, \
           "The values used in initialization does not match the values that were read back after initialization." 

##     print(p_opt)
##     print(p_opt_2)

##     print(sum(abs(p_opt_2-p_opt)))
##     print(sum(abs(dx_2-dx_)))
##     print(sum(abs(x_2-x_)))
##     print(sum(abs(u_2-u_)))
##     print(sum(abs(w_2-w_)))
    
##     # Plot
##     plt.figure(1)
##     plt.clf()
##     plt.subplot(211)
##     plt.plot(t_,x_[0:n_points])
##     plt.hold(True)
##     plt.plot(t_2,x_2[0:n_points])
##     plt.grid()
##     plt.ylabel('x1')
##     plt.subplot(212)
##     plt.plot(t_,x_[n_points:2*n_points])
##     plt.hold(True)
##     plt.plot(t_2,x_2[n_points:2*n_points])
##     plt.grid()
##     plt.ylabel('x2')
##     plt.show()
