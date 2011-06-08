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
Module containing the Casadi interface Python wrappers.
"""
import codecs
from operator import itemgetter
import pylab as P

try:
    import casadi
except:
    pass

from jmodelica.optimization.polynomial import *
from jmodelica import xmlparser
from jmodelica.io import VariableNotFoundError

class CasadiCollocatorException(Exception):
    """
    An CasadiCollocator Exception.
    """
    pass

class CasadiCollocator(object):
    # Parameters
    #UPPER = 1e20
    #LOWER = -1e20
    UPPER = N.inf
    LOWER = -N.inf
    
    def __init__(self, model):
        # Store model (casadiModel)
        self.model = model
        
        # Compute bounds
        self._compute_bounds_and_init()
        
        # Create Solver
        self.c = self.get_equality_constraint()+self.get_inequality_constraint()
        self.c_fcn = casadi.SXFunction([self.get_xx()],[self.c])
        
        if self.get_hessian() == None:
            self.solver = casadi.IpoptSolver(self.get_cost(),self.c_fcn)
        else:
            self.solver = casadi.IpoptSolver(self.get_cost(),self.c_fcn, self.get_hessian())
        
    def get_model(self):
        return self.model
        
    def get_model_description(self):
        return self.get_model().get_model_description()
        
    def get_cost(self):
        raise NotImplementedError
        
    def get_var_indices(self):
        return self.var_indices
        
    def get_time_points(self):
        return self.time_points
        
    def get_xx(self):
        return self.xx
        
    def get_xx_lb(self):
        return self.xx_lb
        
    def get_xx_ub(self):
        return self.xx_ub
        
    def get_xx_init(self):
        return self.xx_init
        
    def get_hessian(self):
        return None
        
    def get_inequality_constraint(self):
        """
        Get the inequality constraint g(x) <= 0.0
        """
        return []
        
    def get_constraint_fcn(self):
        """
        Gets the constraint Casadi function.
        """
        return self.c_fcn
        
    def get_equality_constraint(self):
        """
        Get the equality constraint h(x) = 0.0
        """
        return []
        
    def set_ipopt_option(self, k, v):
        """
        Sets IPOPT options.
            
            Parameters::
            
                k - Name of the option
                v - Value of the option (int, double, string)
        """
        self.solver.setOption(k,v)
    
    def export_result_dymola(self, file_name='', format='txt', 
        write_scaled_result = False):
        """
        Export an optimization or simulation result to file in Dymolas result file 
        format. The parameter values are read from the z vector of the model object 
        and the time series are read from the data argument.

        Parameters::
    
            file_name --
                If no file name is given, the name of the model (as defined by 
                casadiModel.get_name()) concatenated with the string '_result' is used. 
                A file suffix equal to the format argument is then appended to the 
                file name.
                Default: Empty string.
            
            format --
                A text string equal either to 'txt' for textual format or 'mat' for 
                binary Matlab format.
                Default: 'txt'
            
            scaled --
                Set this parameter to True to write the result to file without
                taking scaling into account. If the value of scaled is False, then 
                the variable scaling factors of the model are used to reproduced the 
                unscaled variable values.
                Default: False

        Limitations::
    
            Currently only textual format is supported.
        """

        (t,dx_opt,x_opt,u_opt,w_opt,p_opt) = self.get_result()
        #data = N.hstack((N.transpose(N.array([t])),dx_opt,x_opt,u_opt,w_opt))
        data = N.hstack((t,dx_opt,x_opt,u_opt,w_opt))
        
        if (format=='txt'):

            if file_name=='':
                file_name=self.model.get_name() + '_result.txt'

            # Open file
            f = codecs.open(file_name,'w','utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')
            
            md = self.model.get_model_description()
            
            # NOTE: it is essential that the lists 'names', 'aliases', 'descriptions' 
            # and 'variabilities' are sorted in the same order and that this order 
            # is: value reference order AND within the same value reference the 
            # non-alias variable must be before its corresponding aliases. Otherwise 
            # the header-writing algorithm further down will fail.
            # Therefore the following code is needed...
            
            # all lists that we need for later
            vrefs_alias = []
            vrefs = []
            names_alias = []
            names = []
            names_noalias = []
            aliases_alias = []
            aliases = []
            descriptions_alias = []
            descriptions = []
            variabilities_alias = []
            variabilities = []
            variabilities_noalias = []
            
            # go through all variables and split in non-alias/only-alias lists
            for var in md.get_model_variables():
                if var.get_alias() == xmlparser.NO_ALIAS:
                    vrefs.append(var.get_value_reference())
                    names.append(var.get_name())
                    aliases.append(var.get_alias())
                    descriptions.append(var.get_description())
                    variabilities.append(var.get_variability())
                else:
                    vrefs_alias.append(var.get_value_reference())
                    names_alias.append(var.get_name())
                    aliases_alias.append(var.get_alias())
                    descriptions_alias.append(var.get_description())
                    variabilities_alias.append(var.get_variability())
            
            # extend non-alias lists with only-alias-lists
            vrefs.extend(vrefs_alias)
            names.extend(names_alias)
            aliases.extend(aliases_alias)
            descriptions.extend(descriptions_alias)
            variabilities.extend(variabilities_alias)
            
            # start values (used in parameter writing)
            start = md.get_variable_start_attributes()
            start_values = dict([(start[i][0],start[i][1]) for i in range(len(start))])
            
            # if some parameters where optimized, store that value.
            for key in self.model.get_p_vr_map().items():
                try:
                    start_values[key[0]] = p_opt[key[1]]
                except KeyError:
                    pass
            # add and calculate the dependent parameters
            for key in self.model.get_pd_val():
                try:
                    start_values[key[1]] = key[2]
                except KeyError:
                    pass
            
            # zip to list of tuples and sort - non alias variables are now
            # guaranteed to be first in list and all variables are in value reference 
            # order
            names = sorted(zip(
                tuple(vrefs), 
                tuple(names)), 
                key=itemgetter(0))
            aliases = sorted(zip(
                tuple(vrefs), 
                tuple(aliases)), 
                key=itemgetter(0))
            descriptions = sorted(zip(
                tuple(vrefs), 
                tuple(descriptions)), 
                key=itemgetter(0))
            variabilities = sorted(zip(
                tuple(vrefs), 
                tuple(variabilities)), 
                key=itemgetter(0))
            
            num_vars = len(names)
            
            # Find the maximum name and description length
            max_name_length = len('Time')
            max_desc_length = len('Time in [s]')
            
            for i in range(len(names)):
                name = names[i][1]
                desc = descriptions[i][1]
                
                if (len(name)>max_name_length):
                    max_name_length = len(name)
                    
                if (len(desc)>max_desc_length):
                    max_desc_length = len(desc)

            f.write('char name(%d,%d)\n' % (num_vars + 1, max_name_length))
            f.write('time\n')
        
            # write names
            for name in names:
                f.write(name[1] +'\n')

            f.write('\n')

            f.write('char description(%d,%d)\n' % (num_vars + 1, max_desc_length))
            f.write('Time in [s]\n')

            # write descriptions
            for desc in descriptions:
                f.write(desc[1]+'\n')
                
            f.write('\n')

            # Write data meta information
            f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
            f.write('0 1 0 -1 # time\n')

            cnt_1 = 1
            cnt_2 = 1
            
            n_parameters = 0
            params = []
            
            for i, name in enumerate(names):
                if variabilities[i][1] == xmlparser.PARAMETER or \
                    variabilities[i][1] == xmlparser.CONSTANT:
                    if aliases[i][1] == 0: # no alias
                        cnt_1 = cnt_1 + 1
                        n_parameters += 1
                        params += [name]
                        f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                    elif aliases[i][1] == 1: # alias
                        f.write('1 %d 0 -1 # ' % cnt_1 + name[1]+'\n')
                    else: # negated alias
                        f.write('1 -%d 0 -1 # ' % cnt_1 + name[1] +'\n')
                else:
                    if aliases[i][1] == 0: # noalias
                        cnt_2 = cnt_2 + 1   
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    elif aliases[i][1] == 1: # alias
                        f.write('2 %d 0 -1 # ' % cnt_2 + name[1] +'\n')
                    else: #neg alias
                        f.write('2 -%d 0 -1 # ' % cnt_2 + name[1] +'\n')
                
                    
            f.write('\n')

            #sc = model.jmimodel.get_variable_scaling_factors()
            #z = model.z
            sc = N.hstack((N.array([1.0]),self.model.get_dx_sf(),self.model.get_x_sf(),self.model.get_u_sf(),self.model.get_w_sf()))            

            rescale = self.model.enable_scaling

            # Write data
            # Write data set 1
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            f.write("%.14E" % data[0,0])
            str_text = ''
            for i in params:
                if rescale:
                    #str_text += " %.14E" % (z[ref]*sc[ref])
                    raise NotImplementedError
                else:
                    str_text += " %.14E" % (start_values[i[0]])#(0.0)#(z[ref])
                    
            f.write(str_text)
            f.write('\n')
            f.write("%.14E" % data[-1,0])
            f.write(str_text)

            f.write('\n\n')

            # Write data set 2
            n_vars = len(data[0,:])
            n_points = len(data[:,0])
            f.write('float data_2(%d,%d)\n' % (n_points, n_vars))
            for i in range(n_points):
                str = ''
                for ref in range(n_vars):
                    if ref==0: # Don't scale time
                        str = str + (" %.14E" % data[i,ref])
                    else:
                        if rescale:
                            str = str + (" %.14E" % (data[i,ref]*sc[ref]))
                        else:
                            str = str + (" %.14E" % data[i,ref])
                f.write(str+'\n')

            f.write('\n')

            f.close()

        else:
            raise Error('Export on binary Dymola result files not yet supported.')
        
    def get_result(self):
        dx_opt = N.zeros((len(self.get_time_points()),self.model.get_n_x()))
        x_opt = N.zeros((len(self.get_time_points()),self.model.get_n_x()))
        w_opt = N.zeros((len(self.get_time_points()),self.model.get_n_w()))
        u_opt = N.zeros((len(self.get_time_points()),self.model.get_n_u()))
        p_opt  = N.zeros(self.model.get_n_p())
        t_opt = N.zeros((len(self.get_time_points()),1))

        cnt = 0
        for t,i,j in self.get_time_points():
            t_opt[cnt,0] = t
            dx_opt[cnt,:] = self.nlp_opt[self.get_var_indices()[i][j]['dx']][:,0]
            x_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['x']][:,0]
            u_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['u']][:,0]
            w_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['w']][:,0]
            cnt = cnt + 1
        return (t_opt,dx_opt,x_opt,u_opt,w_opt,p_opt)
    
    def ipopt_solve(self):
        # Initialize
        self.solver.init();

        # Initial condition
        self.solver.setInput(self.get_xx_init(),casadi.NLP_X_INIT)
        
        # Bounds on x
        self.solver.setInput(self.get_xx_lb(),casadi.NLP_LBX)
        self.solver.setInput(self.get_xx_ub(),casadi.NLP_UBX)
        
        # Bounds on the constraints
        h = self.get_equality_constraint()
        hublb = len(h)*[0]
        g = self.get_inequality_constraint()
        gub = len(g)*[0]
        glb = len(g)*[self.LOWER]
        self.glub = hublb+gub
        self.gllb = hublb+glb
        
        self.solver.setInput(self.gllb,casadi.NLP_LBG)
        self.solver.setInput(self.glub,casadi.NLP_UBG)
        
        """
        print "Optimal control problem: "
        print self.ocp
        
        print "NLP X: ", len(self.get_xx()), self.get_xx()
        print "NLP X UB: ", len(self.get_xx_ub()), self.get_xx_ub()
        print "NLP X LB: ", len(self.get_xx_lb()), self.get_xx_lb()
        
        print "Equality constraints: ", len(h), h
        print "Inequality constraints: ", len(g), g
        
        print "Cost functional: ", self.get_cost()
        """
        # Solve the problem
        self.solver.solve()
        
        # Get the result
        self.nlp_opt = N.array(self.solver.output(casadi.NLP_X_OPT))
    
    def _compute_bounds_and_init(self):
        # Create lower and upper bounds
        nlp_lb = self.LOWER*N.ones(len(self.get_xx()))
        nlp_ub = self.UPPER*N.ones(len(self.get_xx()))
        nlp_init = N.zeros(len(self.get_xx()))
        
        md = self.get_model_description()
        
        _dx_max = md.get_dx_max(include_alias = False)
        _x_max = md.get_x_max(include_alias = False)
        _u_max = md.get_u_max(include_alias = False)
        _w_max = md.get_w_max(include_alias = False)
        _dx_min = md.get_dx_min(include_alias = False)
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _w_min = md.get_w_min(include_alias = False)
        _dx_start = md.get_dx_initial_guess(include_alias = False)
        _x_start = md.get_x_initial_guess(include_alias = False)
        _u_start = md.get_u_initial_guess(include_alias = False)
        _w_start = md.get_w_initial_guess(include_alias = False)

        dx_max = self.UPPER*N.ones(len(_dx_max))
        x_max = self.UPPER*N.ones(len(_x_max))
        u_max = self.UPPER*N.ones(len(_u_max))
        w_max = self.UPPER*N.ones(len(_w_max))
        dx_min = self.LOWER*N.ones(len(_dx_min))
        x_min = self.LOWER*N.ones(len(_x_min))
        u_min = self.LOWER*N.ones(len(_u_min))
        w_min = self.LOWER*N.ones(len(_w_min))
        dx_start = self.LOWER*N.ones(len(_dx_start))
        x_start = self.LOWER*N.ones(len(_x_start))
        u_start = self.LOWER*N.ones(len(_u_start))
        w_start = self.LOWER*N.ones(len(_w_start))

        for vr, val in _dx_min:
            if val != None:
                dx_min[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]
        for vr, val in _dx_max:
            if val != None:
                dx_max[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]
        for vr, val in _dx_start:
            if val != None:
                dx_start[self.model.get_dx_vr_map()[vr]] = val/self.model.get_dx_sf()[self.model.get_dx_vr_map()[vr]]

        for vr, val in _x_min:
            if val != None:
                x_min[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_max:
            if val != None:
                x_max[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_start:
            if val != None:
                x_start[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]

        for vr, val in _u_min:
            if val != None:
                u_min[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_max:
            if val != None:
                u_max[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_start:
            if val != None:
                u_start[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]

        for vr, val in _w_min:
            if val != None:
                w_min[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]
        for vr, val in _w_max:
            if val != None:
                w_max[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]
        for vr, val in _w_start:
            if val != None:
                w_start[self.model.get_w_vr_map()[vr]] = val/self.model.get_w_sf()[self.model.get_w_vr_map()[vr]]

        for t,i,j in self.get_time_points():
            nlp_lb[self.get_var_indices()[i][j]['dx']] = dx_min
            nlp_ub[self.get_var_indices()[i][j]['dx']] = dx_max
            nlp_init[self.get_var_indices()[i][j]['dx']] = dx_start
            nlp_lb[self.get_var_indices()[i][j]['x']] = x_min
            nlp_ub[self.get_var_indices()[i][j]['x']] = x_max
            nlp_init[self.get_var_indices()[i][j]['x']] = x_start
            nlp_lb[self.get_var_indices()[i][j]['u']] = u_min
            nlp_ub[self.get_var_indices()[i][j]['u']] = u_max
            nlp_init[self.get_var_indices()[i][j]['u']] = u_start
            nlp_lb[self.get_var_indices()[i][j]['w']] = w_min
            nlp_ub[self.get_var_indices()[i][j]['w']] = w_max
            nlp_init[self.get_var_indices()[i][j]['w']] = w_start

        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb,nlp_ub,nlp_init)


class RadauCollocator(CasadiCollocator):

    def __init__(self, model, options):
        
        # Store the model
        self.model = model
        self.ocp = model.get_casadi_ocp()
        
        # Get the options
        self.n_e = options['n_e']
        self.n_cp = options['n_cp']
        self.h = N.ones(self.n_e)/self.n_e;

        self.initial_dae_constraints = []
        self.dae_constraints = {}
        self.collocation_constraints = {}
        self.continuity_constraints = {}
        
        # Create the NLP problem
        self._create_nlp_variables()
        self._create_collocation_constraints()
        self._create_bolza_functional()
        
        # Necessary! (Creating the IPOPT objected, enables setting IPOPT options)
        super(RadauCollocator,self).__init__(model)
        
        
    def _create_nlp_variables(self):
        # Group variables into elements
        self.vars = {}

        # Create variables for the collocation points
        for i in range(1,self.n_e+1):
            for k in range(self.n_cp+1):
                dxi = []
                xi = []
                ui = []
                wi = []
                for j in range(self.model.get_n_x()):
                    dxi.append(casadi.SX(str(self.model.get_dx()[j])+'_'+str(i)+','+str(k)))
                for j in range(self.model.get_n_x()):
                    xi.append(casadi.SX(str(self.model.get_x()[j])+'_'+str(i)+','+str(k)))
                for j in range(self.model.get_n_u()):
                    ui.append(casadi.SX(str(self.model.get_u()[j])+'_'+str(i)+','+str(k)))
                for j in range(self.model.get_n_w()):
                    wi.append(casadi.SX(str(self.model.get_w()[j])+'_'+str(i)+','+str(k)))
                if k==0:
                    self.vars[i] = {}
                self.vars[i][k] = {}
                self.vars[i][k]['x'] = xi
                if (i==1) or (not k==0):
                    self.vars[i][k]['dx'] = dxi
                    self.vars[i][k]['u'] = ui
                    self.vars[i][k]['w'] = wi
                else:
                    self.vars[i][k]['dx'] = []
                    self.vars[i][k]['u'] = []
                    self.vars[i][k]['w'] = []
        # Group variables indices in the global
        # variable vector
        self.var_indices = {}
        self.xx = []

        for i in range(1,self.n_e+1):
            for k in range(self.n_cp+1):
                if k==0:
                    self.var_indices[i] = {}
                self.var_indices[i][k] = {}
                pre_len = len(self.xx)
                self.xx += self.vars[i][k]['dx']
                self.var_indices[i][k]['dx'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][k]['x']
                self.var_indices[i][k]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][k]['u']
                self.var_indices[i][k]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][k]['w']
                self.var_indices[i][k]['w'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        
    def _create_collocation_constraints(self):
        
        n_e = self.n_e
        n_cp = self.n_cp
        
        # Create vector of time points in the collocation problem, and associated
        # variables
        self.time_points = []

        # Equality constraints
        self.g = []

        z = []
        t = self.ocp.t0
        z += self.vars[1][0]['dx']
        z += self.vars[1][0]['x']
        z += self.vars[1][0]['u']
        z += self.vars[1][0]['w']
        #z += [xmlocp.var.t.sx()]
        z += [casadi.SX(t)]
                
        [tmp] = self.model.get_init_F0().eval([z])
        self.g += list(tmp.data())
        [tmp] = self.model.get_dae_F().eval([z])
        self.g += list(tmp.data())

        pol = RadauPol3()
        self.pol = pol

        # Interpolate u_0,0
        for i in range(self.model.get_n_u()):
            u_0_0_resid = self.vars[1][0]['u'][i]
            for k in range(1,self.n_cp+1):
                u_0_0_resid -= self.vars[1][k]['u'][i]*pol.eval_lp(k-1,0)
            self.g.append(u_0_0_resid)
        self.initial_dae_constraints += self.g
        
        self.time_points.append((self.ocp.t0,1,0))
                
        # DAE residual and collocation equations
        for i in range(1,n_e+1):
            for k in range(1,n_cp+1):
                t = self.ocp.t0 + (self.ocp.tf - self.ocp.t0)*(N.sum(self.h[0:i-1]) + self.h[i-1]*pol.p()[k-1])
                self.time_points.append((t,i,k))
                z = []
                z += self.vars[i][k]['dx']
                z += self.vars[i][k]['x']
                z += self.vars[i][k]['u']
                z += self.vars[i][k]['w']
                z += [casadi.SX(t)]
                [tmp] = self.model.get_dae_F().eval([z])
                dae_constr = list(tmp.data())
                self.g += dae_constr
                if k==1:
                    self.dae_constraints[i] = {}
                self.dae_constraints[i][k] = dae_constr

                if k==1:
                    self.collocation_constraints[i] = {}

                colloc_constr = []

                for j in range(self.model.get_n_x()):
                    coll_res = self.vars[i][k]['dx'][j]
                    for l in range(0,n_cp+1):
                        coll_res -= 1/(self.h[i-1]*(self.ocp.tf-self.ocp.t0))*pol.lpp_dot_vals()[l,k]* \
                                    self.vars[i][l]['x'][j]
                    colloc_constr.append(coll_res)
                    
                self.g += colloc_constr
                self.collocation_constraints[i][k] = colloc_constr

            if i<n_e:
                if k==1:
                    self.continuity_constraints[i] = {}
                cont_constr = []

                for j in range(self.model.get_n_x()):
                    cont_constr.append(self.vars[i][k]['x'][j]-self.vars[i+1][0]['x'][j])

                self.g += cont_constr
                self.continuity_constraints[i] = cont_constr

        self.n_g_colloc = len(self.g)

        # Add path constraints
        for t,i,j in self.time_points:
            pass
            
        ## Equality constraint residual
        #self.g_fcn = casadi.SXFunction([self.xx],[self.g])
        
    def _create_bolza_functional(self):
        # Generate cost function
        self.cost_mayer = 0
        self.cost_lagrange = 0
        
        n_e = self.n_e
        n_cp = self.n_cp
        
        if self.model.get_opt_J() != None:
            
            # Assume Mayer cost
            z = []
            t = self.ocp.tf
            z += self.vars[n_e][n_cp]['dx']
            z += self.vars[n_e][n_cp]['x']
            z += self.vars[n_e][n_cp]['u']
            z += self.vars[n_e][n_cp]['w']
            z += [casadi.SX(t)]
            self.cost_mayer = list(self.model.get_opt_J().eval([z])[0])[0]
            

        # Take care of Lagrange cost
        if self.model.get_opt_L() != None:
            for i in range(1,n_e+1):
                for k in range(1,n_cp+1):
                    t = self.ocp.t0 + (self.ocp.tf - self.ocp.t0)*(N.sum(self.h[0:i-1]) + self.h[i-1]*self.pol.p()[k-1])
                    z = []
                    z += self.vars[i][k]['dx']
                    z += self.vars[i][k]['x']
                    z += self.vars[i][k]['u']
                    z += self.vars[i][k]['w']
                    z += [casadi.SX(t)]
                    self.cost_lagrange += (self.h[i-1]*(self.ocp.tf-self.ocp.t0))*self.model.get_opt_L().eval([z])[0][0]*self.pol.w()[k-1];

        self.cost = self.cost_mayer + self.cost_lagrange

        # Objective function
        self.cost_fcn = casadi.SXFunction([self.xx], [[self.cost]])        
        
        # Hessian
        self.sigma = casadi.SX('sigma')

        self.lam = []
        self.Lag = self.sigma*self.cost
        for i in range(len(self.g)):
            self.lam.append(casadi.SX('lambda_' + str(i)))
            self.Lag = self.Lag + self.g[i]*self.lam[i]
            
        self.Lag_fcn = casadi.SXFunction([self.xx, self.lam, [self.sigma]],[[self.Lag]])

        self.H_fcn = self.Lag_fcn.hessian(0,0)
        
    def get_equality_constraint(self):
        return self.g

    def get_cost(self):
        return self.cost_fcn

    def get_hessian(self):
        return self.H_fcn

    def set_initial_from_file(self,res):
        """ 
        Initialize the optimization vector from an object of either 
        ResultDymolaTextual or ResultDymolaBinary.

        Parameters::
        
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
        """
        
        xmldoc = self.model.get_model_description()

        # Obtain the names and sort them in value reference order
        names = xmldoc.get_dx_variable_names(include_alias=False)
        dx_names=[]
        for name in sorted(names):
            dx_names.append(name[1])

        names = xmldoc.get_x_variable_names(include_alias=False)
        x_names=[]
        for name in sorted(names):
            x_names.append(name[1])

        names = xmldoc.get_u_variable_names(include_alias=False)
        u_names=[]
        for name in sorted(names):
            u_names.append(name[1])

        names = xmldoc.get_w_variable_names(include_alias=False)
        w_names=[]
        for name in sorted(names):
            w_names.append(name[1])

        names = xmldoc.get_p_opt_variable_names(include_alias=False)
        p_opt_names=[]
        for name in sorted(names):
            p_opt_names.append(name[1])
        
        # Obtain vector sizes
        n_points = 0
        num_name_hits = 0
        if len(dx_names) > 0:
            for name in dx_names:
                print name
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(x_names) > 0:
            for name in x_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(u_names) > 0:
            for name in u_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(w_names) > 0:
            for name in w_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass
        else:
            raise Exception(
                "None of the model variables not found in result file.")

        if num_name_hits==0:
            raise Exception(
                "None of the model variables not found in result file.")
        
        #print(traj.t)
        
        n_points = N.size(traj.t,0)
        n_cols = 1+len(dx_names)+len(x_names)+len(u_names)+len(w_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = res.get_variable_data('time').t

#         p_opt_data = N.zeros(len(p_opt_names))

#         sc = self._model.jmimodel.get_variable_scaling_factors()

#         # Get the parameters
#         n_p_opt = self._model.jmimodel.opt_get_n_p_opt()
#         if n_p_opt > 0:
#             p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
#             self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
#             p_opt_indices = p_opt_indices.tolist()

#             for name in p_opt_names:
#                 try:
#                     ref = self._model.get_value_reference(name)
#                     (z_i, ptype) = jmi._translate_value_ref(ref)
#                     i_pi = z_i - self._model._offs_real_pi.value
#                     i_pi_opt = p_opt_indices.index(i_pi)
#                     traj = res.get_variable_data(name)
#                     if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
#                         p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
#                     else:
#                         p_opt_data[i_pi_opt] = traj.x[0]
#                 except VariableNotFoundError:
#                     print "Warning: Could not find value for parameter " + name
                    
#         #print(N.size(var_data))

#         # Initialize variable names
#         # Loop over all the names

#         sc_dx = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_dx.value:self._model._offs_real_x.value]
#         sc_x = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_x.value:self._model._offs_real_u.value]
#         sc_u = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_u.value:self._model._offs_real_w.value]
#         sc_w = self._model.jmimodel.get_variable_scaling_factors()[
#             self._model._offs_real_w.value:self._model._offs_t.value]

        scaling = False

        col_index = 1;
        dx_index = 0;
        x_index = 0;
        u_index = 0;
        w_index = 0;
        for name in dx_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/self.model.get_dx_sf()[dx_index]
                dx_index = dx_index + 1
                col_index = col_index + 1
            except:
                dx_index = dx_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for derivative variable " + name
        for name in x_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/self.model.get_x_sf()[x_index]
                x_index = x_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                x_index = x_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for state variable " + name

        for name in u_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/self.model.get_u_sf()[u_index]
                else:
                    var_data[:,col_index] = traj.x/self.model.get_u_sf()[u_index]
                u_index = u_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                u_index = u_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for input variable " + name

        for name in w_names:
            try:
                #print(name)
                #print(col_index)
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/self.model.get_w_sf()[w_index]
                else:
                    var_data[:,col_index] = traj.x/self.model.get_w_sf()[w_index]
                w_index = w_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                w_index = w_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for algebraic variable " + name

        dx_init = N.zeros((len(self.get_time_points()),self.model.get_n_x()))
        x_init = N.zeros((len(self.get_time_points()),self.model.get_n_x()))
        w_init = N.zeros((len(self.get_time_points()),self.model.get_n_w()))
        u_init = N.zeros((len(self.get_time_points()),self.model.get_n_u()))
        
        t_points = N.zeros(len(self.get_time_points()))

        cnt = 0
        for t,i,j in self.get_time_points():
            t_points[cnt] = t
            cnt = cnt + 1

        # make sure abscissa is increasing
        d = var_data[0,0]
        for i in range(len(var_data[:,0])-1):
            if var_data[i+1,0]<=d:
                var_data[i+1,0] = d + 1e-5
            d = var_data[i+1,0]

        # interpolate
        for i in range(self.model.get_n_x()):
            dx_init[:,i] = N.interp(t_points,var_data[:,0],var_data[:,1+i]);

        for i in range(self.model.get_n_x()):
            x_init[:,i] = N.interp(t_points,var_data[:,0],var_data[:,1 + self.model.get_n_x() +i]);

        for i in range(self.model.get_n_u()):
            u_init[:,i] = N.interp(t_points,var_data[:,0],var_data[:,1 + 2*self.model.get_n_x() + i]);

        for i in range(self.model.get_n_w()):
            w_init[:,i] = N.interp(t_points,var_data[:,0],var_data[:,1 + 2*self.model.get_n_x() + self.model.get_n_u() + i]);

        cnt = 0
        for t,i,j in self.get_time_points():
            if (self.model.get_n_x()>0):
                self.get_xx_init()[self.var_indices[i][j]['dx']] = dx_init[cnt,:]
            if (self.model.get_n_x()>0):
                self.get_xx_init()[self.var_indices[i][j]['x']] = x_init[cnt,:]
                if i>1: # Initialize element junction states TODO: this is not quite correct, could be improved
                    try:
                        self.get_xx_init()[self.var_indices[i][0]['x']] = x_init[cnt,:]
                    except:
                        pass
            if (self.model.get_n_u()>0):
                self.get_xx_init()[self.var_indices[i][j]['u']] = u_init[cnt,:]
            if (self.model.get_n_w()>0):
                self.get_xx_init()[self.var_indices[i][j]['w']] = w_init[cnt,:]
            cnt = cnt + 1

        
class PseudoSpectral(CasadiCollocator):
    """
    This class discretize and solves optimization problem of the general kind,
    
    .. math::
    
        min J = \Phi (x(t_0),t_0, x(t_f),t_f;q) + \int_{t_0}^{t_f} \Theta (x(t),u(t),t;q)dt
        
    subject to the dynamics,
    
    .. math::
    
        \dot{x} = f(x,u,t;q)
        
    and the constraints,
    
    .. math::
    
        \phi_{min} \leq \phi (x(t_0),t_0,x(t_f),t_f;q) \leq \phi_{max}
    
        C_{min} \leq C(x(t),u(t),t;q) \leq C_{max}.
    
    This class gives the option to discretize the optimization problem and 
    perform the collocation at three different set of points, Legendre-Gauss 
    (LG), Legendre-Gauss-Radau (LGR) and Legendre-Gauss-Lobatto (LGL). The 
    points are calculated from the roots of different variations and/or 
    combinations of Legendre polynomials. For LG, the collocation points are 
    calculated as the roots of :math:`P_N(x)`. For LGR, roots of 
    :math:`P_N(x)-P_{N-1}(x)`. For LGL, roots of 
    :math:`(1-x^2) \cdot P_{N-1}'(x)`. Here, :math:`P_N(x)` is a Legendre 
    polynomial of degree :math:`N`.
    
    The points all lie in/on the interval :math:`(-1,1)`. A
    transformation of the optimization interval to the interval :math:`(-1,1)`
    is performed as (still allowing free start and/or final time),
    
    .. math::
    
        t = \\frac{t_f-t_0}{2} \\tau + \\frac{t_f-t_0}{2}.
        
    The state(s) and control(s) are approximated with Lagrange polynomials. For 
    LG and LGR points the state(s) are approximated with :math:`N+1` polynomials
    and for LGL points, :math:`N` polynomials. In all cases the control(s) is 
    approximated using :math:`N` Lagrange polynomials. Example (LG), 
    
    .. math::
    
        x(\\tau) \\approx X(\\tau) = \sum_{i=0}^N X(\\tau _i) L_i(\\tau) ,\quad
        u(\\tau) \\approx U(\\tau) = \sum_{i=1}^N U(\\tau _i) L_i(\\tau). 
    
    Differentiation of the state(s) approximation gives the approximation for
    the state(s) derivatives,
    
    .. math::
    
        \dot{x}(\\tau) \\approx \\frac{dX(\\tau)}{d\\tau} =  
        \sum_{i=0}^N X(\\tau _i) \\frac{dL_i(\\tau)}{d\\tau}, \quad D=\dot{L}.
    
    This implementation gives the options to use either discretization as a
    global collocation method, i.e. the number of phases (elements) are set to
    one or to use it as a local method, number of phases are greater than one. 
    If the number of phases are greater than one, the phases needs to be linked
    together as,
    
    .. math::
    
        x_N^p = x_0^{p+1} + dx^{p+1}
        
    where :math:`x_N^p` is the end point in the :math:`p` phase, 
    :math:`x_0^{p+1}` is the start point in the :math:`p+1` phase and 
    :math:`dx^{p+1}` can be specified to allow discontinuous changes in the 
    state(s). :math:`dx^{p+1}` defaults to zero.
    
    Using the above described method leads to, for each phase (LG),
    
    .. math::
        
        \sum_{i=0}^N D_{ki}X_i - \\frac{t_f-t_0}{2}f(X_k,U_k,\\tau_k;q) = 0, 
        \quad k=1,...,N \quad \\text{(Eq. 1)}
        
        X_{N+1} - X_0 - \sum_{i=0}^N \sum_{k=1}^N \omega_k D_{ki}X_i = 0 \quad 
        \\text{(Eq. 2)}
        
        \phi_{min} \leq \phi (X_0,t_0,X_{N+1},t_f;q) \leq \phi_{max} \quad 
        \\text{(Eq. 3)}
    
        C_{min} \leq C(X_k,U_k,\\tau_k;q) \leq C_{max}, \quad k=1,...,N \quad 
        \\text{(Eq. 4)}
    
    together with,
    
    .. math::
    
        x_{N+1}^p = x_0^{p+1} + dx^{p+1}, \quad p=1,...,P-1
    
        J = \Phi (X_0^1,t_0^1, X_{N+1}^P,t_f^P;q) + \sum_{p=1}^P 
        \\frac{t_f^p-t_0^p}{2} \sum_{k=1}^N \omega_k \Theta (X_k^p,U_k^p,
        \\tau_k^p;q)
    
    gives our NLP which is solved using IPOPT. The changes needed when using 
    LGR points is that the final point is instead :math:`X_N`, because the final
    point is included in the collocation. This removes the need for Equation 2. 
    For LGL points, both the start and final time is included in the collocation 
    so that the start point is :math:`X_1` and the final point :math:`X_N`. This 
    also removes the need for Equation 2.
    
    .. warning::
    
        Path constraints are currently not supported, as is not optimization 
        problems with free start or final time. However, variable bounds are 
        supported.
    
    .. note::
    
        In the result file, the control(s) at the end points for the LG points
        have been extrapolated from the approximated Lagrange polynomials. For
        the LGR points, the start points for the controls have been extrapolated
        in the same way.
        
        The same procedure have been performed for the state derivative(s) in the
        case for LG and LGR points.
    
    .. note::
        
        A reference of an implementation of Gauss-Pseudospectral method can be
        found in, `Algorithm 902: GPOPS, A MATLAB software for solving 
        multiple-phase optimal control problems using the gauss pseudospectral 
        method <http://portal.acm.org/citation.cfm?doid=1731022.1731032>`_. 
        
        Other references include,
        
            - `A unified framework for the numerical solution of optimal control
              problems using pseudospectral methods. 
              <http://portal.acm.org/citation.cfm?id=1872787>`_
        
            - `A Gauss pseudospectral transcription for optimal control. 
              <http://dspace.mit.edu/handle/1721.1/28919>`_
            
            - `Advancement and analysis of Gauss pseudospectral transcription 
              for optimal control problems. 
              <http://dspace.mit.edu/handle/1721.1/42180>`_
    """
    def __init__(self, model, options):
        #Make problem explicit
        model._convert_to_ode()
        
        self.model = model
        self.options = options
        self.md  = model.get_model_description()
        self.ocp = model.get_casadi_ocp()
        self.var = model.get_casadi_variables()
        
        #Create the necessary vectors for a corresponding set of points
        if options['discr'] == "LG":
            self._Collocation    = range(1,options['n_cp']+1)
            self._Discretization = range(0,options['n_cp']+2)
            self._Approximation  = range(0,options['n_cp']+1)
            self._Weights    = gauss_quadrature_weights("LG", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Gauss", options['n_cp'])
            self._Roots      = legendre_Pn_roots(options['n_cp'])
            self._ApproximationRoots = N.append(-1.0, self._Roots)
            self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix[0] = N.array(0.0)#Using analytical results for W*D
        elif options['discr'] == "LGR":
            self._Collocation    = range(1,options['n_cp']+1)
            self._Discretization = range(0,options['n_cp']+1)
            self._Approximation  = range(0,options['n_cp']+1)
            self._Weights    = gauss_quadrature_weights("LGR", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Radau", options['n_cp'])
            self._Roots      = N.append(jacobi_a1_b0_roots(options['n_cp']-1), 1.0)
            self._ApproximationRoots = N.append(-1.0, self._Roots)
            #self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix     = N.zeros(options['n_cp']+1)#Using analytical results for W*D
            self._WeightsTDiffMatrix[0]  = N.array(-1.0)
            self._WeightsTDiffMatrix[-1] = N.array(1.0)
        elif options['discr'] == "LGL":
            self._Collocation    = range(0,options['n_cp'])
            self._Discretization = range(0,options['n_cp'])
            self._Approximation  = range(0,options['n_cp'])
            self._Weights    = gauss_quadrature_weights("LGL", options['n_cp'])
            self._DiffMatrix = differentiation_matrix("Legendre", options['n_cp'])
            self._Roots      = N.append(N.append(-1.0, legendre_dPn_roots(options['n_cp']-1)), 1.0)
            self._ApproximationRoots = self._Roots
            #self._WeightsTDiffMatrix = N.dot(self._Weights, self._DiffMatrix).flatten()
            self._WeightsTDiffMatrix     = N.zeros(options['n_cp']) #Using analytical results for W*D
            self._WeightsTDiffMatrix[0]  = N.array(-1.0)
            self._WeightsTDiffMatrix[-1] = N.array(1.0)
        else:
            raise Exception("Unknown discretization option. Valid options: LG,LGL,LGR")
            
        self._Phases   = range(1,options['n_e']+1)
        
        self._create_nlp_variables()
        self._create_collocation_constraints()
        self._create_bolza_functional()
        
        # Necessary!
        super(PseudoSpectral,self).__init__(model)
        
        self._modify_init()
    
    def _modify_init(self):
        PHASE = self._Phases
        DISCR = self._Discretization
        
        xx_init = self.get_xx_init()
        xx_lb = self.get_xx_lb()
        xx_ub = self.get_xx_ub()
        
        #Handle free final time
        if self.md.get_opt_finaltime_free():
            val_ref = self.md.get_value_reference("finalTime")
            init = self.md.get_p_opt_initial_guess()
            lb   = self.md.get_p_opt_min()
            ub   = self.md.get_p_opt_max()
            for i,p in enumerate(init):
                if p[0] == val_ref:
                    xx_init[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = init[i][1] if init[i][1] != None else N.array(0.0)
                    xx_lb[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = lb[i][1] if lb[i][1] != None else N.array(-1e20)
                    xx_ub[self.get_var_indices()[PHASE[-1]][DISCR[-1]]['t']] = ub[i][1] if ub[i][1] != None else N.array(1e20)
        
        #Handle free start time
        if self.md.get_opt_starttime_free():
            val_ref = self.md.get_value_reference("startTime")
            init = self.md.get_p_opt_initial_guess()
            lb   = self.md.get_p_opt_min()
            ub   = self.md.get_p_opt_max()
            for i,p in enumerate(init):
                if p[0] == val_ref:
                    xx_init[self.get_var_indices()[0][DISCR[0]]['t']] = init[i][1] if init[i][1] != None else N.array(0.0)
                    xx_lb[self.get_var_indices()[0][DISCR[0]]['t']] = lb[i][1] if lb[i][1] != None else N.array(-1e20)
                    xx_ub[self.get_var_indices()[0][DISCR[0]]['t']] = ub[i][1] if ub[i][1] != None else N.array(1e20)
        
        #Handle free phases
        if self.options['free_phases'] and len(PHASE) > 1 and not self.options['phase_options']:
            #if self.options['phase_bounds'] != None:
            #    for i,x in enumerate(self.options['phase_bounds']):
            #        xx_init[self.get_var_indices()[i+1][DISCR[-1]]['t']]=x[0]
            #        xx_lb[self.get_var_indices()[i+1][DISCR[-1]]['t']] = x[1]
            #        xx_ub[self.get_var_indices()[i+1][DISCR[-1]]['t']] = x[2]
            #else:
            for i in PHASE[:-1]:
                xx_init[self.get_var_indices()[i][DISCR[-1]]['t']] = i*(self.ocp.tf-self.ocp.t0)/len(PHASE)
                xx_lb[self.get_var_indices()[i][DISCR[-1]]['t']] = N.array(-1e20)
                xx_ub[self.get_var_indices()[i][DISCR[-1]]['t']] = N.array(1e20)
        
        #Handle links
        """
        if self.options['link_options'] != []:
            for j,x in enumerate(self.options['link_bounds']):
                for i in PHASE[:-1]:
                    xx_init[self.get_var_indices()[i][0]['link_x'][j]]=x[0]
                    xx_lb[self.get_var_indices()[i][0]['link_x'][j]] = x[1]
                    xx_ub[self.get_var_indices()[i][0]['link_x'][j]] = x[2]
        """
        
    def _create_collocation_constraints(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        WTD   = self._WeightsTDiffMatrix
        
        self.h = [] #Equality constraints
        self.g = [] #Inequality constraints
        self.time_points = []
        
        #Create initial constraints
        t = self.vars[0]['t']
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += [t]
        init_constr = list(self.model.get_ode_F0().eval([z])[0])
        self.h += init_constr
        
        #Create collocation constraints
        for i in PHASE:
            if DISCR[0] != COLLO[0]:
                self.time_points += [(self.vars[i-1]['t'],i,DISCR[0])]
            for ind,j in enumerate(COLLO):
                dx = []
                for k in range(self.model.get_n_x()):
                    dx += [sum([DIFFM[ind,l]*self.vars[i][l]['x'][k] for l in APPRO])]
                    
                t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                z = []
                z += self.vars[0]['p']
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += [t]
                dynamic_constr = list((self.vars[i]['t']-self.vars[i-1]['t'])*0.5*self.model.get_ode_F().eval([z])[0])
                for k in range(self.model.get_n_x()):
                    self.h += [dx[k] - dynamic_constr[k]]

                self.time_points += [(t,i,j)]
            if DISCR[-1] != COLLO[-1]:
                self.time_points += [(self.vars[i]['t'],i,DISCR[-1])]
        """
        #Create linking constraints
        for i in PHASE[:-1]:
            z = []
            #u = []
            for x in range(self.model.get_n_x()):
                z += [self.vars[i][DISCR[-1]]['x'][x] - self.vars[i+1][DISCR[0]]['x'][x] + self.vars[i]['link_x'][x]]
            #for x in range(self.model.get_n_u()):
            #    u += [sum([lagrange_eval(ROOTS,ind,1.0)*self.vars[i][l]['u'][x] for ind,l in enumerate(COLLO)])-sum([lagrange_eval(ROOTS,ind,-1.0)*self.vars[i+1][l]['u'][x] for ind,l in enumerate(COLLO)])]
            #self.h += u    
            self.h += z
        """
        self.linkning_constraints = []
        #Create linkning constraints
        for i in PHASE[:-1]:
            z = []
            for x in range(self.model.get_n_x()):
                z += [self.vars[i][DISCR[-1]]['x'][x] - self.vars[i+1][DISCR[0]]['x'][x]]
            self.linkning_constraints += z
            
        for opt in self.link:
            i = opt[0] #Phase
            x_ind = opt[1] #Variable
            p_ind = opt[2] #Parameter
            z = self.vars[i][DISCR[-1]]['x'][x_ind] - self.vars[i+1][DISCR[0]]['x'][x_ind] + self.vars[0]['p'][p_ind]
            self.linkning_constraints[(i-1)*self.model.get_n_x()+x_ind] = z
        self.h += self.linkning_constraints
        
        #Create constraints on the final x (Linear Equation)
        if self.options["discr"]=="LG":
            final_constr = []
            for j in PHASE:
                for x in range(self.model.get_n_x()):
                    temp = []
                    for i in APPRO:
                        #for ind,k in enumerate(COLLO):
                        #    temp += [WEIGH[ind]*DIFFM[ind,i]*self.vars[j][i]['x'][x]]
                        temp += [WTD[i]*self.vars[j][i]['x'][x]]
                    final_constr += [self.vars[j][DISCR[-1]]['x'][x] - self.vars[j][DISCR[0]]['x'][x] - sum(temp)]
            self.h += final_constr
        #Create constraints on the final x (NonLinear Equation)
        
        """
        final_constr = []
        for i in PHASE:
            dynamic_constr = []
            for ind,j in enumerate(COLLO):
                t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                z = []
                z += self.vars[0]['p']
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += [t]
                dynamic_constr += list((self.vars[i]['t']-self.vars[i-1]['t'])*0.5*float(WEIGH[ind])*self.model.get_ode_F().eval([z])[0])
            sums = []
            for j in range(self.model.get_n_x()):
                sums += [-1.0*sum(dynamic_constr[j::self.model.get_n_x()])]
            for j in range(self.model.get_n_x()):
                final_constr += [self.vars[i][DISCR[-1]]['x'][j] - self.vars[i][DISCR[0]]['x'][j] + sums[j]]
        self.h += final_constr
        """

        #Create boundary constraints (equality)
        boundary_constr = []
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += [self.vars[0]['t']]
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        z += [self.vars[PHASE[-1]]['t']]
        boundary_constr = list(self.model.opt_ode_C.eval([z])[0])
        self.h += boundary_constr
        
        #Create boundary constraints (inequality)
        boundary_constr_ineq = []
        z = []
        z += self.vars[0]['p']
        z += self.vars[PHASE[0]][DISCR[0]]['x']
        z += [self.vars[0]['t']]
        z += self.vars[PHASE[-1]][DISCR[-1]]['x']
        z += [self.vars[PHASE[-1]]['t']]
        boundary_constr_ineq = list(self.model.opt_ode_Cineq.eval([z])[0])
        self.g += boundary_constr_ineq
        
        #Create inequality constraint
        if self.options['free_phases']:
            for i in PHASE:
                self.g += [self.vars[i-1]['t']-self.vars[i]['t']]
    
    def _create_bolza_functional(self):
        
        PHASE = self._Phases
        APPRO = self._Approximation
        COLLO = self._Collocation
        DISCR = self._Discretization
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        # Generate cost function
        self.cost_mayer = 0
        self.cost_lagrange = 0
    
        if self.model.get_opt_J() != None:
            # Assume Mayer cost
            z = []
            t = self.vars[PHASE[-1]]['t']
            z += self.vars[0]['p']
            z += self.vars[PHASE[-1]][DISCR[-1]]['x']
            z += [t]
            self.cost_mayer = list(self.model.get_opt_ode_J().eval([z])[0])[0]
        #NOTE TEMPORARY!!!!
        #self.cost_mayer=self.vars[PHASE[-1]]['t']
        # Take care of Lagrange cost
        if self.model.get_opt_L() != None:
            for i in PHASE:
                for ind,j in enumerate(COLLO):
                    t = (self.vars[i]['t']-self.vars[i-1]['t'])*0.5*(ROOTS[ind]+(self.vars[i]['t']+self.vars[i-1]['t'])/(self.vars[i]['t']-self.vars[i-1]['t']))
                    z = []
                    z += self.vars[0]['p']
                    z += self.vars[i][j]['x']
                    z += self.vars[i][j]['u']
                    z += [t]
                    self.cost_lagrange += (self.vars[i]['t']-self.vars[i-1]['t'])/2.0*self.model.get_opt_ode_L().eval([z])[0][0]*WEIGH[ind]
          
        self.cost = self.cost_mayer + self.cost_lagrange

        # Objective function
        self.cost_fcn = casadi.SXFunction([self.xx], [[self.cost]])  
        
        # Hessian
        self.sigma = casadi.SX('sigma')
        
        self.lam = []
        self.Lag = self.sigma*self.cost
        for i in range(len(self.h)):
            self.lam.append(casadi.SX('lambda_' + str(i)))
            self.Lag = self.Lag + self.h[i]*self.lam[i]
        for i in range(len(self.g)):
            self.lam.append(casadi.SX('lambda_' + str(i+len(self.h))))
            self.Lag = self.Lag + self.g[i]*self.lam[i+len(self.h)]
            
        self.Lag_fcn = casadi.SXFunction([self.xx, self.lam, [self.sigma]],[[self.Lag]])
        
        #self.H_fcn = None
        self.H_fcn = self.Lag_fcn.hessian(0,0)
    
    def _create_nlp_variables(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        
        # Group variables into elements
        self.vars = {}
        # Extended vars
        self.ext_vars = {}
        
        t0 = self.ocp.t0
        tf = self.ocp.tf
        
        if self.md.get_opt_finaltime_free():
            tf = casadi.SX("tf")
        if self.md.get_opt_starttime_free():
            t0 = casadi.SX("t0")
        
        self.vars[0] = {}
        for i in PHASE: #Phases
            for j in DISCR: #Discretization
                xi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_x()]
                if j==0:
                    self.vars[i] = {}
                self.vars[i][j] = {}
                self.vars[i][j]['x'] = xi
                    
            for j in COLLO: #Collocation
                ui = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_u()]
                self.vars[i][j]['u'] = ui
        
        
        pi = [casadi.SX(str(x)) for x in self.model.get_p()]
        self.vars[0]['p'] = pi
        
        
        for i in PHASE[:-1]:
            if self.options['free_phases']:
                if self.options['phase_options']:
                    for ind, p in enumerate(self.model.get_p()):
                        if self.options['phase_options'][i-1] == str(p):    
                            self.vars[i]['t'] = self.vars[0]['p'][ind]
                            break
                    else:
                        raise CasadiCollocatorException("Could not find the parameter for the phase bound.")
                else:
                    self.vars[i]['t'] = casadi.SX("t"+str(i))
            else:
                self.vars[i]['t'] = i*(tf-t0)/len(PHASE)

        self.vars[PHASE[-1]]['t'] = tf
        self.vars[0]['t']         = t0
        
        # Group variables indices in the global
        # variable vector
        self.var_indices = {0:{0:{}}}
        self.xx = []
        
        for i in PHASE: #Phases
            self.var_indices[i] = {}
            
            for j in DISCR: #Discretization
                self.var_indices[i][j] = {}
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['x']
                self.var_indices[i][j]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
                
            for j in COLLO: #Collocation
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['u']
                self.var_indices[i][j]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        pre_len = len(self.xx)
        self.xx += self.vars[0]['p']
        self.var_indices[0][0]['p'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        if self.md.get_opt_finaltime_free(): #Handle free finaltime
            pre_len = len(self.xx)
            self.xx += [self.vars[PHASE[-1]]['t']]
            self.var_indices[PHASE[-1]][DISCR[-1]]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        if self.md.get_opt_starttime_free(): #Handle free starttime
            pre_len = len(self.xx)
            self.xx += [self.vars[0]['t']]
            self.var_indices[0][0]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        if self.options['free_phases'] and len(PHASE) > 1: #Handle free phases
            for i in PHASE[:-1]:
                if self.options['phase_options']:
                    for ind, p in enumerate(self.model.get_p()):
                        if self.options['phase_options'][i-1] == str(p):
                            self.var_indices[i][DISCR[-1]]['t'] = self.var_indices[0][0]['p'][ind]
                            break
                else:
                    pre_len = len(self.xx)
                    self.xx += [self.vars[i]['t']]
                    self.var_indices[i][DISCR[-1]]['t'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        
        self.link = [] 
        for all in self.options['link_options']:
            xlink = -1
            plink = -1
            for ind, x in enumerate(self.model.get_x()):
                if all[1] == str(x):
                    xlink = ind
                    break
            for ind, p in enumerate(self.model.get_p()):
                if all[2] == str(p):
                    plink = ind
                    break
            
            if xlink == -1:
                raise CasadiCollocatorException("Could not find the linking variable, ",all[1], ".")
            if plink == -1:
                raise CasadiCollocatorException("Could not find the linking parameter, ",all[2], ".")
            self.link += [(all[0],xlink,plink)]
        
        """
        #Create vector allowing or disallowing discontinuous state
        for i in PHASE[:-1]: #Phases
            self.vars[i]['link_x'] = [casadi.SX(0.0) for x in self.model.get_x()]
            links = []
            for j in self.options['link_options']:
                for l,k in enumerate(self.model.get_x()):
                    if j[0] == str(k):
                        self.vars[i]['link_x'][l] = casadi.SX('link_'+str(k)+'_'+str(i))
                        links += [self.vars[i]['link_x'][l]]
            pre_len = len(self.xx)
            #self.xx += [self.vars[i]['link_x'][l]]
            self.xx += links
            self.var_indices[i][0]['link_x'] = N.arange(pre_len,len(self.xx),dtype=int)
        """
    
    def get_equality_constraint(self):
        return self.h
    
    def get_inequality_constraint(self):
        return self.g

    def get_cost(self):
        return self.cost_fcn

    def get_hessian(self):
        return self.H_fcn
    
    def _compute_bounds_and_init(self):
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        # Create lower and upper bounds
        nlp_lb = self.LOWER*N.ones(len(self.get_xx()))
        nlp_ub = self.UPPER*N.ones(len(self.get_xx()))
        nlp_init = N.zeros(len(self.get_xx()))
        
        md = self.get_model_description()
        var = self.var
        
        _x_max = md.get_x_max(include_alias = False)
        _u_max = md.get_u_max(include_alias = False)
        _p_max = [(p.getValueReference(), p.getMax()) for p in var.p]
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _p_min = [(p.getValueReference(), p.getMin()) for p in var.p]
        _x_start = md.get_x_start(include_alias = False)
        #_u_start = md.get_u_start(include_alias = False)
        _u_start = md.get_u_initial_guess(include_alias = False)
        _p_start = []
        for p in var.p: #NOTE SHOULD BE CHANGED
            for p_ori in md.get_p_opt_initial_guess():
                if p.getValueReference() == p_ori[0]:
                    _p_start += [p_ori] 
        #_p_start = [(p.getValueReference(), p.getStart()) for p in var.p]
        
        x_max = self.UPPER*N.ones(len(_x_max))
        u_max = self.UPPER*N.ones(len(_u_max))
        p_max = self.UPPER*N.ones(len(_p_max))
        x_min = self.LOWER*N.ones(len(_x_min))
        u_min = self.LOWER*N.ones(len(_u_min))
        p_min = self.LOWER*N.ones(len(_p_min))
        x_start = self.LOWER*N.ones(len(_x_start))
        u_start = self.LOWER*N.ones(len(_u_start))
        p_start = self.LOWER*N.ones(len(_p_start))
        
        for vr, val in _x_min:
            if val != None:
                x_min[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_max:
            if val != None:
                x_max[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]
        for vr, val in _x_start:
            if val != None:
                x_start[self.model.get_x_vr_map()[vr]] = val/self.model.get_x_sf()[self.model.get_x_vr_map()[vr]]

        for vr, val in _u_min:
            if val != None:
                u_min[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_max:
            if val != None:
                u_max[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        for vr, val in _u_start:
            if val != None:
                u_start[self.model.get_u_vr_map()[vr]] = val/self.model.get_u_sf()[self.model.get_u_vr_map()[vr]]
        
        for vr, val in _p_min:
            if val != None:
                p_min[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_max:
            if val != None:
                p_max[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        for vr, val in _p_start:
            if val != None:
                p_start[self.model.get_p_vr_map()[vr]] = val/self.model.get_p_sf()[self.model.get_p_vr_map()[vr]]
        
        for t,i,j in self.get_time_points():
            nlp_lb[self.get_var_indices()[i][j]['x']] = x_min
            nlp_ub[self.get_var_indices()[i][j]['x']] = x_max
            nlp_init[self.get_var_indices()[i][j]['x']] = x_start
            if j==0 and DISCR[0] != COLLO[0]:
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                continue
            nlp_lb[self.get_var_indices()[i][j]['u']] = u_min
            nlp_ub[self.get_var_indices()[i][j]['u']] = u_max
            nlp_init[self.get_var_indices()[i][j]['u']] = u_start
        
        #Add the parameters options
        nlp_lb[self.get_var_indices()[0][0]['p']] = p_min
        nlp_ub[self.get_var_indices()[0][0]['p']] = p_max
        nlp_init[self.get_var_indices()[0][0]['p']] = p_start

        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb,nlp_ub,nlp_init)
    
    def get_result(self):
        
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        APPRO = self._Approximation
        AROOT = self._ApproximationRoots
        
        dx_opt = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_x()))
        x_opt  = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_x()))
        u_opt  = N.zeros((len(PHASE)*len(DISCR), self.model.get_n_u()))
        w_opt  = N.zeros((len(PHASE)*len(DISCR), 0))
        t_opt  = N.zeros(len(self.get_time_points()))
        p_opt  = N.zeros(self.model.get_n_p())
        
        ts = [i[0] for i in self.get_time_points()]

        if (self.options['free_phases'] and len(PHASE) > 1) and self.md.get_opt_finaltime_free():
            input_t = [self.vars[i]['t'] for i in PHASE]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.nlp_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE]
            tfcn.setInput(N.array(input_res).flatten())
        elif (self.options['free_phases'] and len(PHASE) > 1):
            input_t = [self.vars[i]['t'] for i in PHASE[:-1]]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.nlp_opt[self.var_indices[i][DISCR[-1]]['t']][0] for i in PHASE[:-1]]
            tfcn.setInput(N.array(input_res).flatten())
        elif self.md.get_opt_finaltime_free():
            input_t = self.vars[PHASE[-1]]['t']
            tfcn = casadi.SXFunction([[input_t]],[ts])
            tfcn.init()
            tfcn.setInput(self.nlp_opt[self.var_indices[PHASE[-1]][DISCR[-1]]['t']])
        else:
            tfcn = casadi.SXFunction([[]],[ts])
            tfcn.init()
            
        tfcn.evaluate()
        t = N.transpose(N.array([tfcn.output()]))
        t_opt = t.flatten()
        
        cnt = 0
        for time,i,j in self.get_time_points():
            #t_opt[cnt] = t
            x_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['x']][:,0]
            
            if j==0 and DISCR[0] != COLLO[0]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,-1.0)*self.nlp_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,-1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,-1.0)*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                u_opt[cnt,:] = [sum([lagrange_eval(ROOTS,ind,1.0)*self.nlp_opt[self.get_var_indices()[i][l]['u']][k,0] for ind,l in enumerate(COLLO)]) for k in range(self.model.get_n_u())]
                dx_coeff = [lagrange_derivative_eval(AROOT,ind,1.0) for ind in range(len(APPRO))]
                dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([dx_coeff[ind]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                #dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([lagrange_derivative_eval(AROOT,ind,1.0)*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for ind,l in enumerate(APPRO)]) for k in range(self.model.get_n_x())]
                cnt = cnt + 1
                continue
            
            u_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['u']][:,0]
            dx_opt[cnt,:] = [N.array(2.0)/(t_opt[(i)*len(DISCR)-1]-t_opt[(i-1)*len(DISCR)])*sum([DIFFM[j-COLLO[0],l]*self.nlp_opt[self.get_var_indices()[i][l]['x']][k,0] for l in APPRO]) for k in range(self.model.get_n_x())]
            cnt = cnt + 1
            
        p_opt[:] = self.nlp_opt[self.get_var_indices()[0][0]['p']][:,0]

        return (t,dx_opt,x_opt,u_opt,w_opt,p_opt)
        
    def set_initial_from_file(self,res):
        """ 
        Initialize the optimization vector from an object of either 
        ResultDymolaTextual or ResultDymolaBinary.

        Parameters::
        
            res --
                A reference to an object of type ResultDymolaTextual or
                ResultDymolaBinary.
        """
        names = self.md.get_x_variable_names(include_alias=False)
        x_names=[]
        for name in sorted(names):
            x_names.append(name[1])

        names = self.md.get_u_variable_names(include_alias=False)
        u_names=[]
        for name in sorted(names):
            u_names.append(name[1])
            
        names = self.md.get_p_opt_variable_names(include_alias=False)
        p_opt_names=[]
        for name in sorted(names):
            if name == "finalTime" or name == "startTime":
                continue
            p_opt_names.append(name[1])
        
        # Obtain vector sizes
        n_points = 0
        num_name_hits = 0
        if len(x_names) > 0:
            for name in x_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass

        elif len(u_names) > 0:
            for name in u_names:
                try:
                    traj = res.get_variable_data(name)
                    num_name_hits = num_name_hits + 1
                    if N.size(traj.x)>2:
                        break
                except:
                    pass
        else:
            raise Exception(
                "None of the model variables not found in result file.")

        if num_name_hits==0:
            raise Exception(
                "None of the model variables not found in result file.")

        n_points = N.size(traj.t,0)
        n_cols = 1+len(x_names)+len(u_names)

        var_data = N.zeros((n_points,n_cols))
        # Initialize time vector
        var_data[:,0] = res.get_variable_data('time').t

        # If a normalized minimum time problem has been solved,
        # then, the time vector should be rescaled
        #n=[names[1] for names in self.md.get_p_opt_variable_names()]
        #non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        #dx_factor = 1.0
        """
        if non_fixed_interval:
            # A minimum time problem has been solved,
            # interval is normalized to [-1,1]
            t0 = self.ocp.t0
            tf = self.ocp.tf
            dx_factor = tf-t0
            for i in range(N.size(var_data,0)):
                var_data[i,0] = 2.0*var_data[i,0]/(tf-t0)-(tf+t0)/(tf-t0)
                #var_data[i,0] = -t0/(tf-t0) + var_data[i,0]/(tf-t0)
        """
        
        p_opt_data = N.zeros(len(p_opt_names))
        # Get the parameters
        n_p_opt = len(p_opt_names)
        if n_p_opt > 0:
            for i,name in enumerate(p_opt_names):
                try:
                    #ref = self.md.get_value_reference(name)
                    #(z_i, ptype) = jmi._translate_value_ref(ref)
                    #i_pi = z_i - self._model._offs_real_pi.value
                    #i_pi_opt = p_opt_indices.index(i_pi)
                    traj = res.get_variable_data(name)
                    #if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                    #    p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
                    #else:
                    p_opt_data[i] = traj.x[0]
                except VariableNotFoundError:
                    print "Warning: Could not find value for parameter " + name
        
        # Initialize variable names
        # Loop over all the names

        sc_x = self.model.get_x_sf()
        sc_u = self.model.get_u_sf()

        col_index = 1;
        x_index = 0;
        u_index = 0;
        for name in x_names:
            try:
                traj = res.get_variable_data(name)
                var_data[:,col_index] = traj.x/sc_x[x_index]
                x_index = x_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                x_index = x_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for state variable " + name
        for name in u_names:
            try:
                traj = res.get_variable_data(name)
                if not res.is_variable(name):
                    var_data[:,col_index] = N.ones(n_points)*traj.x[0]/sc_u[u_index]
                else:
                    var_data[:,col_index] = traj.x/sc_u[u_index]
                u_index = u_index + 1
                col_index = col_index + 1
            except VariableNotFoundError:
                u_index = u_index + 1
                col_index = col_index + 1
                print "Warning: Could not find trajectory for input variable " + name
                
        self.var_data = var_data
        self.par_data = p_opt_data 
        
        self._set_initial_from_file(var_data,p_opt_data)
        
    def _set_initial_from_file(self, var_data, par_data):
        PHASE = self._Phases
        COLLO = self._Collocation
        DISCR = self._Discretization
        APPRO = self._Approximation
        WEIGH = self._Weights
        DIFFM = self._DiffMatrix
        ROOTS = self._Roots
        
        ts = [i[0] for i in self.get_time_points()]

        if (self.options['free_phases'] and len(PHASE) > 1) and self.md.get_opt_finaltime_free():
            input_t = [self.vars[i]['t'] for i in PHASE]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.xx_init[self.var_indices[i][DISCR[-1]]['t']] for i in PHASE]
            tfcn.setInput(N.array(input_res).flatten())
        elif (self.options['free_phases'] and len(PHASE) > 1):
            input_t = [self.vars[i]['t'] for i in PHASE[:-1]]
            tfcn = casadi.SXFunction([input_t],[ts])
            tfcn.init()
            input_res = [self.xx_init[self.var_indices[i][DISCR[-1]]['t']] for i in PHASE[:-1]]
            tfcn.setInput(N.array(input_res).flatten())
        elif self.md.get_opt_finaltime_free():
            input_t = self.vars[PHASE[-1]]['t']
            tfcn = casadi.SXFunction([[input_t]],[ts])
            tfcn.init()
            tfcn.setInput(self.xx_init[self.var_indices[PHASE[-1]][DISCR[-1]]['t']])
        else:
            tfcn = casadi.SXFunction([[]],[ts])
            tfcn.init()
            
        tfcn.evaluate()
        t = N.transpose(N.array([tfcn.output()]))
        t_opt = t.flatten()
        
        xx_init = self.get_xx_init()

        x_init = N.zeros((len(t), self.model.get_n_x()))
        u_init = N.zeros((len(t)-len(DISCR)+len(COLLO), self.model.get_n_u()))
        
        for i in range(self.model.get_n_x()):
            x_init[:,i] = N.interp(t_opt, var_data[:,0], var_data[:,i+1]).transpose()
        for i in range(self.model.get_n_u()):
            if DISCR[0] != COLLO[0]:
                start = 1
            else:
                start = 0
            if DISCR[-1] != COLLO[-1]:
                end = -1
            else:
                end = len(t_opt)
            u_init[:,i] = N.interp(t_opt[start:end], var_data[:,0], var_data[:,1+self.model.get_n_x()+i]).transpose()
        
        cnt_x = 0
        cnt_u = 0
        
        #Add the initials of the states and controls
        for time,i,j in self.get_time_points():
            xx_init[self.get_var_indices()[i][j]['x']] = x_init[cnt_x,:]
            cnt_x += 1
            if j==0 and DISCR[0] != COLLO[0]:
                continue
            if j==DISCR[-1] and DISCR[-1] != COLLO[-1]:
                continue
            xx_init[self.get_var_indices()[i][j]['u']] = u_init[cnt_u,:]
            cnt_u += 1
        
        #Add the initial of the parameters
        if len(par_data) > 0:
            xx_init[self.get_var_indices()[0][0]['p']] = par_data

        self.xx_init = xx_init
