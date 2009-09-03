""" Test module for testing the jmi module
"""

import os
import os.path

import nose

import jmodelica.jmi as jmi
from jmodelica.compiler import OptimicaCompiler
import jmodelica.xmlparser as xp
import jmodelica.io
import matplotlib.pyplot as plt

import numpy as N

sep = os.path.sep

jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = sep + "Python" + sep + "jmodelica" + sep + "examples"
path_to_tests = sep + "Python" + sep + "jmodelica" + sep + "tests"

oc = OptimicaCompiler()

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)

def test_jmi_opt_sim_set_initial_from_trajectory():
    """ Test of 'jmi_opt_sim_set_initial_from_trajectory'.

    An optimization problem is solved and then the result
    is used to reinitialize the NLP. The variable profiles
    are then retrieved and a check is performed wheather
    they match.
    """
    
    model = sep + "files" + sep + "VDP.mo"
    fpath = jm_home+path_to_examples+model
    cpath = "VDP_pack.VDP_Opt_Min_Time"
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

    vdp.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory(nlp.jmi_simoptlagpols._jmi_opt_sim,p_opt,z_,n_points,hs,0.,0.)
    
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
    
    model = sep + "files" + sep + "VDP.mo"
    fpath = jm_home+path_to_examples+model
    cpath = "VDP_pack.VDP_Opt_Min_Time"
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


def test_init_opt():
    """ Test of DAE initialization optimization problem

    """
    
    model = sep + "files" + sep + "DAEInitTest.mo"
    fpath = jm_home+path_to_tests+model
    cpath = "DAEInitTest"
    fname = cpath.replace('.','_',1)

    oc.compile_model(fpath, cpath, target='ipopt')

    # Load the dynamic library and XML data
    dae_init_test = jmi.Model(fname)

    init_nlp = jmi.DAEInitializationOpt(dae_init_test)

    # Test init_opt_get_dimensions
    res_n_x = 8
    res_n_h = 8
    res_dh_n_nz = 17

    n_x, n_h, dh_n_nz = init_nlp.init_opt_get_dimensions()

    assert N.abs(res_n_x-n_x) + N.abs(res_n_h-n_h) + \
           N.abs(res_dh_n_nz-dh_n_nz)==0, \
           "test_jmi.py: test_init_opt: init_opt_get_dimensions returns wrong problem dimensions." 

    # Test init_opt_get_x_init
    res_x_init = N.array([0,0,3,4,1,0,0,0])
    x_init = N.zeros(n_x)
    init_nlp.init_opt_get_initial(x_init)
    assert N.sum(N.abs(res_x_init-x_init))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_x_init returns wrong values." 

    # Test init_opt_set_x_init
    res_x_init = N.ones(n_x)
    x_init = N.ones(n_x)
    init_nlp.init_opt_set_initial(x_init)
    init_nlp.init_opt_get_initial(x_init)
    assert N.sum(N.abs(res_x_init-x_init))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_x_init returns wrong values after setting the initial values with init_opt_get_x_init." 

    # Test init_opt_get_bounds
    res_x_lb = -1e20*N.ones(n_x)
    res_x_ub = 1e20*N.ones(n_x)
    x_lb = N.zeros(n_x)
    x_ub = N.zeros(n_x)
    init_nlp.init_opt_get_bounds(x_lb,x_ub)
    assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong lower bounds." 
    assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong upper bounds." 

    # Test init_opt_set_bounds
    res_x_lb = -5000*N.ones(n_x)
    res_x_ub = 5000*N.ones(n_x)
    x_lb = -5000*N.ones(n_x)
    x_ub = 5000*N.ones(n_x)
    init_nlp.init_opt_set_bounds(x_lb,x_ub)
    init_nlp.init_opt_get_bounds(x_lb,x_ub)
    assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong lower bounds after calling init_opt_set_bounds." 
    assert N.sum(N.abs(res_x_lb-x_lb))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_get_bounds returns wrong upper bounds after calling init_opt_set_bounds." 

    # Test init_opt_f
    res_f = N.array([0.])
    f = N.zeros(1)
    init_nlp.init_opt_f(f)
    assert N.sum(N.abs(res_f-f))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_f returns wrong value" 

    # Test init_opt_df
    res_df = N.array([0.,0,0,0,0,0,0,0])
    df = N.ones(n_x)
    init_nlp.init_opt_df(df)
    assert N.sum(N.abs(res_df-df))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_df returns wrong value" 

    # Test init_opt_h
    res_h = N.array([ -1.98158529e+02,  -2.43197505e-01,   5.12000000e+02,   5.00000000e+00,
                      1.41120008e-01,   0.00000000e+00,   0.00000000e+00,   0.00000000e+00])
    h = N.zeros(n_h)
    init_nlp.init_opt_h(h)
    assert N.sum(N.abs(res_h-h))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_h returns wrong value" 

    # Test init_opt_dh
    res_dh = N.array([  -1.,           -1.,         -135.,          192.,           -0.9899925,    -1.,
  -48.,            0.65364362,   -1.,            0.54030231,   -2.,           -1.,
   -1.,            0.9899925,   192.,           -1.,           -1.,        ])
    dh = N.ones(dh_n_nz)
    init_nlp.init_opt_dh(dh)
    assert N.sum(N.abs(res_dh-dh))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_dh returns wrong value" 

    # Test init_opt_dh_nz_inidices
    res_dh_irow = N.array([1, 2, 1, 3, 5, 7, 1, 2, 8, 1, 2, 6, 3, 5, 3, 4, 5])
    res_dh_icol = N.array([1, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8])
    dh_irow = N.zeros(dh_n_nz,dtype=N.int32)
    dh_icol = N.zeros(dh_n_nz,dtype=N.int32)
    init_nlp.init_opt_dh_nz_indices(dh_irow,dh_icol)
    assert N.sum(N.abs(res_dh_irow-dh_irow))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_dh_nz_indices returns wrong values for the row indices." 
    assert N.sum(N.abs(res_dh_icol-dh_icol))<1e-3, \
           "test_jmi.py: test_init_opt: init_opt_dh_nz_indices returns wrong values for the column indices" 

    # Test optimization of initialization system
    init_nlp_ipopt = jmi.JMIDAEInitializationOptIPOPT(init_nlp)

    # init_nlp_ipopt.init_opt_ipopt_set_string_option("derivative_test","first-order")
    
    init_nlp_ipopt.init_opt_ipopt_solve()

    res_Z = N.array([5.,
                     -198.1585290151921,
                     -0.2431975046920718,
                     3.0,
                     4.0,
                     1.0,
                     2197.0,
                     5.0,
                     -0.92009689684513785,
                     0.])

    assert max(N.abs(res_Z-dae_init_test.getZ()))<1e-3, \
           "test_jmi.py: test_init_opt: Wrong solution to initialization system." 
    
    #print(dae_init_test.getZ())
    #print(dae_init_test.getPI())
    #print(dae_init_test.getDX())
    #print(dae_init_test.getX())
    #print(dae_init_test.getU())
    #print(dae_init_test.getW())


