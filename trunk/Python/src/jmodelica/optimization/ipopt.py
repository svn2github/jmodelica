# -*- coding: utf-8 -*-
""" The IPOPT solver module. """
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

import ctypes as ct
from ctypes import byref
import numpy as N

from jmodelica import jmi
from jmodelica import io

class CollocationOptimizer(object):
    """ An interface to the NLP solver Ipopt. """
    
    def __init__(self, nlp_collocation):
        
        """ 
        Constructor where main data structure is created. Needs a 
        NLPCollocation implementation instance, for example a 
        NLPCollocationLagrangePolynomials object. The underlying model must 
        have been compiled with support for ipopt.
        
        Parameters:
            nlp_collocation -- NLPCollocation object.
        
        """
        
        self._nlp_collocation = nlp_collocation
        self._ipopt_opt = ct.c_voidp()
        
        try:
            assert self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_new(byref(self._ipopt_opt), 
                                                                                 self._nlp_collocation._jmi_opt_sim) == 0, \
                   "jmi_opt_sim_ipopt_new returned non-zero"
        except AttributeError, e:
            raise jmi.JMIException("Can not create JMISimultaneousOptIPOPT object. Please recompile model with target='ipopt")
        
        assert self._ipopt_opt.value is not None, \
               "jmi struct not returned correctly"
               
    def opt_sim_ipopt_solve(self):
        """ Solve the NLP problem."""
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_solve(self._ipopt_opt) is not 0:
            raise jmi.JMIException("Solving IPOPT failed.")
    
    def opt_sim_ipopt_set_string_option(self, key, val):
        """
        Set Ipopt string option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_string_option(self._ipopt_opt, key, val) is not 0:
            raise jmi.JMIException("Setting string option failed.")
        
    def opt_sim_ipopt_set_int_option(self, key, val):
        """
        Set Ipopt integer option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """        
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_int_option(self._ipopt_opt, key, val) is not 0:
            raise jmi.JMIException("Setting int option failed.")

    def opt_sim_ipopt_set_num_option(self, key, val):
        """
        Set Ipopt double option.
        
        Parameters:
            key -- Name of option.
            val -- Value of option.
            
        """
        if self._nlp_collocation._model.jmimodel._dll.jmi_opt_sim_ipopt_set_num_option(self._ipopt_opt, key, val) is not 0:
            raise jmi.JMIException("Setting num option failed.")

class NLPCollocation(object):
    """
    NLP interface for a dynamic optimization problem. Abstract class which 
    provides some methods but can not be instantiated. Use together with 
    an implementation of an algorithm by extending this class.
    
    """    

    def __init__(self):
        raise jmi.JMIException("This class can not be instantiated. ")
    
    def _initialize(self, model):
        self._model = model
        self._jmi_opt_sim = ct.c_voidp()
        
    def get_result(self):
        """
        Get the optimization results.
        
        Returns:
        p_opt --
            A vector containing the values of the optimized parameters.
        data --
            A two dimensional array of variable trajectory data. The
            first column represents the time vector. The following
            colums contain, in order, the derivatives, the states,
            the inputs and the algebraic variables. The ordering is
            according to increasing value references.
        """

        n_points = self.opt_sim_get_result_variable_vector_length()
        n_points = n_points.value

        sizes = self._model.get_sizes()
        n_dx = sizes[4]
        n_x = sizes[5]
        n_u = sizes[6]
        n_w = sizes[7]
        n_popt = self._model.jmimodel.opt_get_n_p_opt()
        
        # Create result data vectors
        p_opt = N.zeros(n_popt)
        t_ = N.zeros(n_points)
        dx_ = N.zeros(n_dx*n_points)
        x_ = N.zeros(n_x*n_points)
        u_ = N.zeros(n_u*n_points)
        w_ = N.zeros(n_w*n_points)
        
        # Get the result
        self.opt_sim_get_result(p_opt,t_,dx_,x_,u_,w_)
        
        data = N.zeros((n_points,1+n_dx+n_x+n_u+n_w))
        data[:,0] = t_
        for i in range(n_dx):
            data[:,i+1] = dx_[i*n_points:(i+1)*n_points]
        for i in range(n_x):
            data[:,n_dx+i+1] = x_[i*n_points:(i+1)*n_points]
        for i in range(n_u):
            data[:,n_dx+n_x+i+1] = u_[i*n_points:(i+1)*n_points]
        for i in range(n_w):
            data[:,n_dx+n_x+n_u+i+1] = w_[i*n_points:(i+1)*n_points]

        return p_opt, data
    
    def export_result_dymola(self, format='txt'):
        """
        Export the opitimization result on Dymola format.

        Parameters:
            format --
                A string equal either to 'txt' for output to Dymola textual
                format or 'mat' for output to Dymola binary Matlab format.

        Limitations:
            Only format='txt' is currently supported.
        """

        # Get results
        p_opt, data = self.get_result()
        
        # Write result
        io.export_result_dymola(self._model,data)

    def set_initial_from_dymola(self,res, hs_init, start_time_init, final_time_init):
        """
        Initialize the optimization vector from an object of either ResultDymolaTextual
        or ResultDymolaBinary.

        Parameters:
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
            hs_init -- A vector of length n_e containing initial guesses of the
                normalized lengths of the finite elements. This argument is
                neglected if the problem does not have free element lengths.
            start_time_init --
                Initial guess of interval start time. This argument is neglected
                if the start time is fixed.
            final_time_init --
                Initial guess of interval final time. This argument is neglected
                if the final time is fixed.
        """

        # Obtain the names
        dx_names = self._model.get_derivative_names()
        dx_name_value_refs = dx_names.keys()
        dx_name_value_refs.sort(key=int)

        x_names = self._model.get_differentiated_variable_names()
        x_name_value_refs = x_names.keys()
        x_name_value_refs.sort(key=int)

        u_names = self._model.get_input_names()
        u_name_value_refs = u_names.keys()
        u_name_value_refs.sort(key=int)

        w_names = self._model.get_algebraic_variable_names()
        w_name_value_refs = w_names.keys()
        w_name_value_refs.sort(key=int)

        p_opt_names = self._model.get_p_opt_names()
        p_opt_name_value_refs = p_opt_names.keys()
        p_opt_name_value_refs.sort(key=int)

        #print(dx_names)
        #print(x_names)
        #print(u_names)
        #print(w_names)
        
        # Obtain vector sizes
        n_points = 0
        if len(dx_names) > 0:
            traj = res.get_variable_data(dx_names.get(dx_name_value_refs[0]))
        elif len(x_names) > 0:
            traj = res.get_variable_data(x_names.get(x_name_value_refs[0]))
        elif len(u_names) > 0:
            traj = res.get_variable_data(u_names.get(u_name_value_refs[0]))
        elif len(w_names) > 0:
            for ref in w_name_value_refs:
                traj = res.get_variable_data(w_names.get(ref))
                if N.size(traj.x)>2:
                    break
        else:
            return

        #print(traj.t)

        n_points = N.size(traj.t,0)
        n_cols = 1+len(dx_names)+len(x_names)+len(u_names)+len(w_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = traj.t;

        p_opt_data = N.zeros(len(p_opt_names))

        # Get the parameters
        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()

            for ref in p_opt_name_value_refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_pi = z_i - self._model._offs_pi.value
                i_pi_opt = p_opt_indices.index(i_pi)
                traj = res.get_variable_data(p_opt_names.get(ref))
                p_opt_data[i_pi_opt] = traj.x[0]

        #print(N.size(var_data))

        # Initialize variable names
        # Loop over all the names
        col_index = 1;
        for ref in dx_name_value_refs:
            #print(dx_names.get(ref))
            #print(col_index)
            traj = res.get_variable_data(dx_names.get(ref))
            var_data[:,col_index] = traj.x
            col_index = col_index + 1
        for ref in x_name_value_refs:
            #print(x_names.get(ref))
            #print(col_index)
            traj = res.get_variable_data(x_names.get(ref))
            var_data[:,col_index] = traj.x
            col_index = col_index + 1
        for ref in u_name_value_refs:
            #print(u_names.get(ref))
            #print(col_index)
            traj = res.get_variable_data(u_names.get(ref))
            var_data[:,col_index] = traj.x
            col_index = col_index + 1
        for ref in w_name_value_refs:
            #print(w_names.get(ref))
            #print(col_index)
            traj = res.get_variable_data(w_names.get(ref))
            if N.size(traj.x)==2:
                var_data[:,col_index] = N.ones(n_points)*traj.x[0]
            else:
                var_data[:,col_index] = traj.x
            col_index = col_index + 1

        #print(var_data)
        #print(N.reshape(var_data,(n_cols*n_points,1),order='F')[:,0])
            
        self.opt_sim_set_initial_from_trajectory(p_opt_data,N.reshape(var_data,(n_cols*n_points,1),order='F')[:,0],N.size(var_data,0),
                                                 hs_init,start_time_init,final_time_init)
        
    def opt_sim_get_dimensions(self):
        """ 
        Get the number of variables and the number of constraints in the 
        problem.
        
        Returns:
            Tuple with the number of variables in the NLP problem, inequality 
            constraints, equality constraints, non-zeros in the Jacobian of 
            the inequality constraints and non-zeros in the Jacobian of the 
            equality constraints respectively. 
            
        """
        n_x = ct.c_int()
        n_g = ct.c_int()
        n_h = ct.c_int()
        dg_n_nz = ct.c_int()
        dh_n_nz = ct.c_int()
        if self._model.jmimodel._dll.jmi_opt_sim_get_dimensions(self._jmi_opt_sim, byref(n_x), byref(n_g), 
                                                        byref(n_h), byref(dg_n_nz), byref(dh_n_nz)) is not 0:
            raise jmi.JMIException("Getting the number of variables and constraints failed.")
        return n_x.value, n_g.value, n_h.value, dg_n_nz.value, dh_n_nz.value

    def opt_sim_get_interval_spec(self, start_time, start_time_free, final_time, final_time_free):
        """ 
        Get data that specifies the optimization interval.
        
        Parameters:
            start_time -- Optimization interval start time. (Return)
            start_time_free -- 0 if start time should be fixed or 1 if free. (Return)
            final_time -- Optimization final time. (Return)
            final_time_free -- 0 if start time should be fixed or 1 if free. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_interval_spec(self._jmi_opt_sim, start_time, start_time_free, final_time, final_time_free) is not 0:
            raise jmi.JMIException("Getting the optimization interval data failed.")
        
    def opt_sim_get_x(self):
        """ Return the x vector of the NLP. """
        return self._model.jmimodel._dll.jmi_opt_sim_get_x(self._jmi_opt_sim)

    def opt_sim_get_initial(self, x_init):
        """ 
        Get the initial point of the NLP.
        
        Parameters:
            x_init -- The initial guess vector. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_initial(self._jmi_opt_sim, x_init) is not 0:
            raise jmi.JMIException("Getting the initial point failed.")

    def opt_sim_set_initial(self, x_init):
        """ Set the initial point of the NLP.

        Parameters:
            x_init --- The initial guess vector.
        """
        if self._model.jmimodel._dll.jmi_opt_sim_set_initial(self._jmi_opt_sim, x_init) is not 0:
            raise jmi.JMIException("Setting the initial point failed.")
 
    def opt_sim_set_initial_from_trajectory(self, p_opt_init, trajectory_data_init, traj_n_points,
                                            hs_init, start_time_init, final_time_init):
        """
        Set the initial point based on time series trajectories of the
        variables of the problem.

        Also, initial guesses for the optimization interval and element lengths
        are provided.

        Parameters:
        p_opt_init --
            A vector of size n_p_opt containing initial values for the
            optimized parameters.
        trajectory_data_init --
            A matrix stored in column major format. The
            first column contains the time vector. The following column
            contains, in order, the derivative, state, input, and algebraic
            variable profiles.
        traj_n_points --
            Number of time points in trajectory_data_init.
        hs_init --
            A vector of length n_e containing initial guesses of the
            normalized lengths of the finite elements. This argument is neglected
            if the problem does not have free element lengths.
        start_time_init --
            Initial guess of interval start time. This argument is neglected if
            the start time is fixed.
        final_time_init --
            Initial guess of interval final time. This argument is neglected if
            the final time is fixed.
        """
        if self._model.jmimodel._dll.jmi_opt_sim_set_initial_from_trajectory(self._jmi_opt_sim, \
                                                                        p_opt_init, \
                                                                        trajectory_data_init, \
                                                                        traj_n_points, \
                                                                        hs_init, \
                                                                        start_time_init, \
                                                                        final_time_init) is not 0:
            raise jmi.JMIException("Setting the initial point failed.")

    def opt_sim_get_bounds(self, x_lb, x_ub):
        """ 
        Get the upper and lower bounds of the optimization variables.
        
        Parameters:
            x_lb -- The lower bounds vector. (Return)
            x_ub -- The upper bounds vector. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_bounds(self._jmi_opt_sim, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of the optimization variables failed.")

    def opt_sim_set_bounds(self, x_lb, x_ub):
        """ 
        Set the upper and lower bounds of the optimization variables.
        
        Parameters:
            x_lb -- The lower bounds vector. (Return)
            x_ub -- The upper bounds vector. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_set_bounds(self._jmi_opt_sim, x_lb, x_ub) is not 0:
            raise jmi.JMIException("Getting upper and lower bounds of the optimization variables failed.")
        
    def opt_sim_f(self, f):
        """ 
        Get the cost function value at a given point in search space.
        
        Parameters:
            f -- Value of the cost function. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_f(self._jmi_opt_sim, f) is not 0:
            raise jmi.JMIException("Getting the cost function failed.")
        
    def opt_sim_df(self, df):
        """ 
        Get the gradient of the cost function value at a given point in search 
        space.
        
        Parameters:
            df -- Value of the gradient of the cost function. (Return)
            
        """
        if self._model.jmimodel._dll.jmi_opt_sim_df(self._jmi_opt_sim, df) is not 0:
            raise jmi.JMIException("Getting the gradient of the cost function value failed.")
        
    def opt_sim_g(self, res):
        """ 
        Get the residual of the inequality constraints h.
        
        Parameters:
            res -- Residual of the inequality constraints. (Return)
            
        """
        if self._model.jmimodel._dll.jmi_opt_sim_g(self._jmi_opt_sim, res) is not 0:
            raise jmi.JMIException("Getting the residual of the inequality constraints failed.")
        
    def opt_sim_dg(self, jac):
        """ 
        Get the Jacobian of the residual of the inequality constraints.
        
        Parameters:
            jac -- The Jacobian of the residual of the inequality constraints. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dg(self._jmi_opt_sim, jac) is not 0:
            raise jmi.JMIException("Getting the Jacobian of the residual of the inequality constraints failed.")
        
    def opt_sim_dg_nz_indices(self, irow, icol):
        """ 
        Get the indices of the non-zeros in the inequality constraint Jacobian.
        
        Parameters:
            irow -- 
                Row indices of the non-zero entries in the Jacobian of the 
                residual of the inequality constraints. (Return)
            icol --- 
                Column indices of the non-zero entries in the Jacobian of 
                the residual of the inequality constraints. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dg_nz_indices(self._jmi_opt_sim, irow, icol) is not 0:
            raise jmi.JMIException("Getting the indices of the non-zeros in the equality constraint Jacobian failed.")
        
    def opt_sim_h(self, res):
        """ 
        Get the residual of the equality constraints h.
        
        Parameters:
            res -- The residual of the equality constraints. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_h(self._jmi_opt_sim, res) is not 0:
            raise jmi.JMIException("Getting the residual of the equality constraints failed.")
        
    def opt_sim_dh(self, jac):
        """ 
        Get the Jacobian of the residual of the equality constraints.
        
        Parameters:
            jac -- The Jacobian of the residual of the equality constraints. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dh(self._jmi_opt_sim, jac) is not 0:
            raise jmi.JMIException("Getting the Jacobian of the residual of the equality constraints.")
        
    def opt_sim_dh_nz_indices(self, irow, icol):
        """ 
        Get the indices of the non-zeros in the equality constraint Jacobian.
        
        Parameters:
            irow -- 
                Row indices of the non-zero entries in the Jacobian of the 
                residual of the equality constraints. (Return)
            icol -- 
                Column indices of the non-zero entries in the Jacobian of the 
                residual of the equality constraints. (Return)
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_dh_nz_indices(self._jmi_opt_sim, irow, icol) is not 0:
            raise jmi.JMIException("Getting the indices of the non-zeros in the equality constraint Jacobian failed.")
        
    def opt_sim_write_file_matlab(self, file_name):
        """ 
        Write the optimization result to file in Matlab format.
        
        Parameters:
            file_name -- Name of file to write to.
        
        """
        if self._model.jmimodel._dll.jmi_opt_sim_write_file_matlab(self._jmi_opt_sim, file_name) is not 0:
            raise jmi.JMIException("Writing the optimization result to file in Matlab format failed.")
        
    def opt_sim_get_result_variable_vector_length(self):
        """ Return the length of the result variable vectors. """
        n = ct.c_int()
        if self._model.jmimodel._dll.jmi_opt_sim_get_result_variable_vector_length(self._jmi_opt_sim, byref(n)) is not 0:
            raise jmi.JMIException("Getting the length of the result variable vectors failed.")
        return n
        
    def opt_sim_get_result(self, p_opt, t, dx, x, u, w):
        """ 
        Get the results, stored in column major format.
        
        Parameters:
            p_opt -- Vector containing optimal parameter values. (Return)
            t -- The time vector. (Return)
            dx -- The derivatives. (Return)
            x -- The states. (Return)
            u -- The inputs. (Return)
            w -- The algebraic variables. (Return)
             
        """
        if self._model.jmimodel._dll.jmi_opt_sim_get_result(self._jmi_opt_sim, p_opt, t, dx, x, u, w) is not 0:
            raise jmi.JMIException("Getting the results failed.")


class NLPCollocationLagrangePolynomials(NLPCollocation):
    """ 
    An implementation of a transcription method based on Lagrange polynomials 
    and Radau points. Extends the abstract class NLPCollocation. 
    """

    
    def __init__(self, model, n_e, hs, n_cp):
        """
        Constructor where main data structure is created. 
        
        Initial guesses, lower and upper bounds and linearity information is 
        set for optimized parameters, derivatives, states, inputs and 
        algebraic variables. These values are taken from the XML files created 
        at compilation.
        
        Parameters:
            model -- The Model object.
            n_e -- Number of finite elements.
            hs -- Vector containing the normalized element lengths.
            n_cp -- Number of collocation points. 
        
        """
        NLPCollocation._initialize(self, model)

        # Initialization
        _p_opt_init = N.zeros(model.jmimodel.opt_get_n_p_opt())
        _dx_init = N.zeros(model._n_dx.value)
        _x_init = N.zeros(model._n_x.value)
        _u_init = N.zeros(model._n_u.value)
        _w_init = N.zeros(model._n_w.value)
    
        # Bounds
        _p_opt_lb = -1.0e20*N.ones(model.jmimodel.opt_get_n_p_opt())
        _dx_lb = -1.0e20*N.ones(model._n_dx.value)
        _x_lb = -1.0e20*N.ones(model._n_x.value)
        _u_lb = -1.0e20*N.ones(model._n_u.value)
        _w_lb = -1.0e20*N.ones(model._n_w.value)
        _t0_lb = 0.; # not yet supported
        _tf_lb = 0.; # not yet supported
        _hs_lb = N.zeros(n_e); # not yet supported
        
        _p_opt_ub = 1.0e20*N.ones(model.jmimodel.opt_get_n_p_opt())
        _dx_ub = 1.0e20*N.ones(model._n_dx.value)
        _x_ub = 1.0e20*N.ones(model._n_x.value)
        _u_ub = 1.0e20*N.ones(model._n_u.value)
        _w_ub = 1.0e20*N.ones(model._n_w.value)
        _t0_ub = 0.; # not yet supported
        _tf_ub = 0.; # not yet supported
        _hs_ub = N.zeros(n_e); # not yet supported
                
        # default values
        hs_free = 0
        
        self._set_initial_values(_p_opt_init, _dx_init, _x_init, _u_init, _w_init)
        self._set_lb_values(_p_opt_lb, _dx_lb, _x_lb, _u_lb, _w_lb)
        self._set_ub_values(_p_opt_ub, _dx_ub, _x_ub, _u_ub, _w_ub)

        _linearity_information_provided = 1;
        _p_opt_lin = N.ones(model.jmimodel.opt_get_n_p_opt(),dtype=int)
        _dx_lin = N.ones(model._n_dx.value,dtype=int)
        _x_lin = N.ones(model._n_x.value,dtype=int)
        _u_lin = N.ones(model._n_u.value,dtype=int)        
        _w_lin = N.ones(model._n_w.value,dtype=int)
        _dx_tp_lin = N.ones(model._n_dx.value*model._n_tp.value,dtype=int)
        _x_tp_lin = N.ones(model._n_x.value*model._n_tp.value,dtype=int)
        _u_tp_lin = N.ones(model._n_u.value*model._n_tp.value,dtype=int)        
        _w_tp_lin = N.ones(model._n_w.value*model._n_tp.value,dtype=int)

        self._set_lin_values(_p_opt_lin, _dx_lin, _x_lin, _u_lin, _w_lin, _dx_tp_lin, _x_tp_lin, _u_tp_lin, _w_tp_lin)

        try:       
            assert model.jmimodel._dll.jmi_opt_sim_lp_new(byref(self._jmi_opt_sim), model.jmimodel._jmi, n_e,
                                      hs, hs_free,
                                     _p_opt_init, _dx_init, _x_init,
                                     _u_init, _w_init,
                                     _p_opt_lb, _dx_lb, _x_lb,
                                     _u_lb, _w_lb, _t0_lb,
                                     _tf_lb, _hs_lb,
                                     _p_opt_ub, _dx_ub, _x_ub,
                                     _u_ub, _w_ub, _t0_ub,
                                     _tf_ub, _hs_ub,
                                     _linearity_information_provided,                
                                     _p_opt_lin, _dx_lin, _x_lin, _u_lin, _w_lin,
                                     _dx_tp_lin, _x_tp_lin, _u_tp_lin, _w_tp_lin,                
                                     n_cp,jmi.JMI_DER_CPPAD) is 0, \
                                     " jmi_opt_lp_new returned non-zero."
        except AttributeError,e:
             raise jmi.JMIException("Can not create NLPCollocationLagrangePolynomials object. Try recompiling model with target='algorithms'")
        
        assert self._jmi_opt_sim.value is not None, \
            "jmi_opt_sim_lp struct has not returned correctly."
            
    def __del__(self):
        """ Free jmi_opt_sim data structure. """
        try:
            assert self._model.jmimodel._dll.jmi_opt_sim_lp_delete(self._jmi_opt_sim) == 0, \
                   "jmi_delete failed"
        except AttributeError, e:
            pass

    def opt_sim_lp_get_pols(self, n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, Lp_dot_coeffs, Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals):
        """
        Get the Lagrange polynomials of a specified order.
        
        Parameters:
            n_cp -- 
                Number of collocation points.
            cp -- 
                Radau collocation points for polynomials of order n_cp-1. (Return)
            cpp -- 
                Radau collocation points for polynomials of order n_cp. (Return)
            Lp_coeffs -- 
                Polynomial coefficients for polynomials based on the points 
                given by cp. (Return)
            Lp_dot_coeffs -- 
                Polynomial coefficients for polynomials based on the points 
                given by cpp. (Return) 
            Lpp__dot_coeffs -- 
                Polynomial coefficients for the derivatives of the polynomials 
                based on the cp points. (Return)
            Lp_dot_vals -- 
                Values of the derivatives of the cp polynomials when evaluated 
                at the Radau collocation points.(Return)
            Lpp_dot_vals --  
                Values of the derivatives of the cpp polynomials when evaluated 
                at the collocation points. (Return)
            
        """
        if self._model.jmimodel._dll.jmi_opt_sim_lp_get_pols(n_cp, cp, cpp, Lp_coeffs, Lpp_coeffs, Lp_dot_coeffs, 
                                                        Lpp_dot_coeffs, Lp_dot_vals, Lpp_dot_vals) is not 0:
            raise jmi.JMIException("Getting sim lp pols failed.")

    def _set_initial_values(self, p_opt_init, dx_init, x_init, u_init, w_init):
        
        """ 
        Set initial guess values from the XML variables meta data file. 
        
        Parameters:
            p_opt_init -- The optimized parameters initial guess vector.
            dx_init -- The derivatives initial guess vector.
            x_init -- The states initial guess vector.
            u_init -- The input initial guess vector.
            w_init -- The algebraic variables initial guess vector.
        
        """
        
        xmldoc = self._model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)

        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()
            
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_pi = z_i - self._model._offs_pi.value
                i_pi_opt = p_opt_indices.index(i_pi)
                p_opt_init[i_pi_opt] = values.get(ref)
        
        # dx: derivative
        values = xmldoc.get_dx_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_dx = z_i - self._model._offs_dx.value
            dx_init[i_dx] = values.get(ref)
        
        # x: differentiate
        values = xmldoc.get_x_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_x = z_i - self._model._offs_x.value
            x_init[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_u = z_i - self._model._offs_u.value
            u_init[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_initial_guess_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_w = z_i - self._model._offs_w.value
            w_init[i_w] = values.get(ref) 

    def _set_lb_values(self, p_opt_lb, dx_lb, x_lb, u_lb, w_lb):
        
        """ 
        Set lower bounds from the XML variables meta data file. 
        
        Parameters:
            p_opt_lb -- The optimized parameters lower bounds vector.
            dx_lb -- The derivatives lower bounds vector.
            x_lb -- The states lower bounds vector.
            u_lb -- The input lower bounds vector.
            w_lb -- The algebraic variables lower bounds vector.        
        
        """
        
        xmldoc = self._model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)

        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()
            
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_pi = z_i - self._model._offs_pi.value
                i_pi_opt = p_opt_indices.index(i_pi)
                p_opt_lb[i_pi_opt] = values.get(ref)

        # dx: derivative
        values = xmldoc.get_dx_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_dx = z_i - self._model._offs_dx.value
            dx_lb[i_dx] = values.get(ref) 
        
        # x: differentiate
        values = xmldoc.get_x_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_x = z_i - self._model._offs_x.value
            x_lb[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_u = z_i - self._model._offs_u.value
            u_lb[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_lb_values()
        
        refs = values.keys()
        refs.sort(key=int)

        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_w = z_i - self._model._offs_w.value
            #print("%d, %d" %(z_i,i_w))
            w_lb[i_w] = values.get(ref) 

    def _set_ub_values(self, p_opt_ub, dx_ub, x_ub, u_ub, w_ub):
        
        """ 
        Set upper bounds from the XML variables meta data file. 
        
        Parameters:
            p_opt_ub -- The optimized parameters upper bounds vector.
            dx_ub -- The derivatives upper bounds vector.
            x_ub -- The states upper bounds vector.
            u_ub -- The input upper bounds vector.
            w_ub -- The algebraic variables upper bounds vector.        
        
        """
        
        xmldoc = self._model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)

        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()
            
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_pi = z_i - self._model._offs_pi.value
                i_pi_opt = p_opt_indices.index(i_pi)
                p_opt_ub[i_pi_opt] = values.get(ref)

        # dx: derivative
        values = xmldoc.get_dx_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)

        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_dx = z_i - self._model._offs_dx.value
            dx_ub[i_dx] = values.get(ref) 
        
        # x: differentiate
        values = xmldoc.get_x_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_x = z_i - self._model._offs_x.value
            x_ub[i_x] = values.get(ref)
            
        # u: input
        values = xmldoc.get_u_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_u = z_i - self._model._offs_u.value
            u_ub[i_u] = values.get(ref)
        
        # w: algebraic
        values = xmldoc.get_w_ub_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_w = z_i - self._model._offs_w.value
            w_ub[i_w] = values.get(ref) 

    def _set_lin_values(self, p_opt_lin, dx_lin, x_lin, u_lin, w_lin, dx_tp_lin, x_tp_lin, u_tp_lin, w_tp_lin):
        
        """ 
        Set linearity information from the XML variables meta data file. 
        
        For the linearity vectors, a "1" indicates that the variable appears 
        linearly and a "0" otherwise. The same convention is used for the 
        linear time point vectors. 
        
        For the linear time point vectors, the information about the first 
        time point is stored in the first n positions in the vector, where 
        n is equal to the number of parameters/derivatives/states/inputs or 
        variables, followed by the second time point and so on for all time 
        points.
                
        Parameters:
            p_opt_lin -- The optimized parameters linear information vector.
            dx_lin -- The derivatives linear information vector.
            x_lin -- The states linear information vector.
            u_lin -- The input linear information vector.
            w_lin -- The algebraic variables linear information vector.        
            dx_tp_lin -- The derivatives linear time point vector.
            x_tp_lin -- The states linear time point vector.
            u_tp_lin -- The input linear time point vector.
            w_tp_lin -- The algebraic variables linear time point vector.        
        
        """
        
        
        xmldoc = self._model._get_XMLvariables_doc()

        # p_opt: free variables
        values = xmldoc.get_p_opt_lin_values()
        
        refs = values.keys()
        refs.sort(key=int)

        n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()

            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_pi = z_i - self._model._offs_pi.value
                i_pi_opt = p_opt_indices.index(i_pi)
                p_opt_lin[i_pi_opt] = int(values.get(ref))

        # dx: derivative
        values = xmldoc.get_dx_lin_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_dx = z_i - self._model._offs_dx.value
            dx_lin[i_dx] = int(values.get(ref))
        
        # x: differentiate
        values = xmldoc.get_x_lin_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_x = z_i - self._model._offs_x.value
            x_lin[i_x] = int(values.get(ref))
            
        # u: input
        values = xmldoc.get_u_lin_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_u = z_i - self._model._offs_u.value
            u_lin[i_u] = int(values.get(ref))
        
        # w: algebraic
        values = xmldoc.get_w_lin_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for ref in refs:
            (z_i, ptype) = jmi._translate_value_ref(ref)
            i_w = z_i - self._model._offs_w.value
            w_lin[i_w] = int(values.get(ref))


        # number of timepoints
        no_of_tp = self._model._n_tp.value

        # timepoints dx: derivative
        values = xmldoc.get_dx_lin_tp_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for no_tp in range(no_of_tp):
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_dx = z_i - self._model._offs_dx.value
                dx_tp_lin[i_dx+no_tp*len(refs)] = int(values.get(ref)[no_tp])
        
        # timepoints x: differentiate
        values = xmldoc.get_x_lin_tp_values()
        
        refs = values.keys()
        refs.sort(key=int)       
        
        for no_tp in range(no_of_tp):
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_x = z_i - self._model._offs_x.value
                
                x_tp_lin[i_x+no_tp*len(refs)] = int(values.get(ref)[no_tp])
            
        # timepoints u: input
        values = xmldoc.get_u_lin_tp_values()
        
        refs = values.keys()
        refs.sort(key=int)
        
        for no_tp in range(no_of_tp):
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_u = z_i - self._model._offs_u.value
                
                u_tp_lin[i_u+no_tp*len(refs)] = int(values.get(ref)[no_tp])
        
        # timepoints w: algebraic
        values = xmldoc.get_w_lin_tp_values()
        
        refs = values.keys()
        refs.sort(key=int)

        for no_tp in range(no_of_tp):
            for ref in refs:
                (z_i, ptype) = jmi._translate_value_ref(ref)
                i_w = z_i - self._model._offs_w.value
                w_tp_lin[i_w+no_tp*len(refs)] = int(values.get(ref)[no_tp])                
