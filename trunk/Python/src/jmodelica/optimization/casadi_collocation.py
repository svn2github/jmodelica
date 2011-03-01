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

from jmodelica.optimization.casadi_polynomial import *
from jmodelica import xmlparser
from jmodelica.io import VariableNotFoundError

class CasadiCollocator(object):
    
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

        (t,dx_opt,x_opt,u_opt,w_opt) = self.get_result() 
        #print (t,dx_opt,x_opt,u_opt,w_opt)
        data = N.hstack((N.transpose(N.array([t])),dx_opt,x_opt,u_opt,w_opt))
        
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
            f.write("%12.12f" % data[0,0])
            str_text = ''
            for i in params:
                if rescale:
                    #str_text += " %12.12f" % (z[ref]*sc[ref])
                    raise NotImplementedError
                else:
                    str_text += " %12.12f" % (start_values[i[0]])#(0.0)#(z[ref])
                    
            f.write(str_text)
            f.write('\n')
            f.write("%12.12f" % data[-1,0])
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
                        str = str + (" %12.12f" % data[i,ref])
                    else:
                        if rescale:
                            str = str + (" %12.12f" % (data[i,ref]*sc[ref]))
                        else:
                            str = str + (" %12.12f" % data[i,ref])
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
        
        t_opt = N.zeros(len(self.get_time_points()))

        cnt = 0
        for t,i,j in self.get_time_points():
            t_opt[cnt] = t
            dx_opt[cnt,:] = self.nlp_opt[self.get_var_indices()[i][j]['dx']][:,0]
            x_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['x']][:,0]
            u_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['u']][:,0]
            w_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['w']][:,0]
            cnt = cnt + 1
        return (t_opt,dx_opt,x_opt,u_opt,w_opt)
    
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
        glb = len(g)*[-1e20]
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
        nlp_lb = -1e20*N.ones(len(self.get_xx()))
        nlp_ub = 1e20*N.ones(len(self.get_xx()))
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
        _dx_start = md.get_dx_start(include_alias = False)
        _x_start = md.get_x_start(include_alias = False)
        _u_start = md.get_u_start(include_alias = False)
        _w_start = md.get_w_start(include_alias = False)

        dx_max = 1e20*N.ones(len(_dx_max))
        x_max = 1e20*N.ones(len(_x_max))
        u_max = 1e20*N.ones(len(_u_max))
        w_max = 1e20*N.ones(len(_w_max))
        dx_min = -1e20*N.ones(len(_dx_min))
        x_min = -1e20*N.ones(len(_x_min))
        u_min = -1e20*N.ones(len(_u_min))
        w_min = -1e20*N.ones(len(_w_min))
        dx_start = -1e20*N.ones(len(_dx_start))
        x_start = -1e20*N.ones(len(_x_start))
        u_start = -1e20*N.ones(len(_u_start))
        w_start = -1e20*N.ones(len(_w_start))

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

        self.initial_dae_constraints = []
        self.dae_constraints = {}
        self.collocation_constraints = {}
        self.continuity_constraints = {}

        z = []
        t = self.ocp.t0
        z += self.vars[1][0]['dx']
        z += self.vars[1][0]['x']
        z += self.vars[1][0]['u']
        z += self.vars[1][0]['w']
        #z += [xmlocp.var.t.sx()]
        z += [casadi.SX(t)]
        self.g += list(self.model.get_init_F0().eval([z])[0])
        self.g += list(self.model.get_dae_F().eval([z])[0])

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
                dae_constr = list(self.model.get_dae_F().eval([z])[0])
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
        
class GaussPseudoSpectralMethod(CasadiCollocator):
    """
    This class implementes the Gauss PseudoSpectral method described in:
    
        * A Gauss pseudospectral transcription for optimal control.
            -> http://dspace.mit.edu/handle/1721.1/28919
        * Advancement and analysis of Gauss pseudospectral transcription for optimal control problems.
            -> http://dspace.mit.edu/handle/1721.1/42180
        * Algorithm 902: GPOPS, A MATLAB software for solving multiple-phase optimal control problems using the gauss pseudospectral method.
            -> http://portal.acm.org/citation.cfm?doid=1731022.1731032
    """
    def __init__(self, model, options):
        #Make problem explicit
        model._convert_to_ode()
        
        self.model = model
        self.options = options
        self.md  = model.get_model_description()
        self.ocp = model.get_casadi_ocp()
        
        self.P = options['n_e']
        self.K = options['n_cp']
        
        self.LG = LegendreGauss(self.K)
        self.LGr = self.LG.get_roots()
        self.LGm = self.LG.get_matrix()
        self.LGw = self.LG.get_weights()
        self.LGd = self.LG.get_discretization_points()
        self.LGl = self.LG.get_lagrange_pol().get_lagrange_polynomials()
        
        self._create_nlp_variables()
        self._create_collocation_constraints()
        self._create_bolza_functional()
        
        # Necessary!
        super(GaussPseudoSpectralMethod,self).__init__(model)
        
        self._modify_init()
        
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
        n=[names[1] for names in self.md.get_p_opt_variable_names()]
        non_fixed_interval = ('finalTime' in n) or ('startTime' in n)            

        dx_factor = 1.0
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
        """
        p_opt_data = N.zeros(len(p_opt_names))
        # Get the parameters
        n_p_opt = len(self.md.get_p_opt_variable_names())
        if n_p_opt > 0:
            p_opt_indices = N.zeros(n_p_opt, dtype=int)
        
            self._model.jmimodel.opt_get_p_opt_indices(p_opt_indices)
            p_opt_indices = p_opt_indices.tolist()

            for name in p_opt_names:
                try:
                    ref = self.md.get_value_reference(name)
                    (z_i, ptype) = jmi._translate_value_ref(ref)
                    i_pi = z_i - self._model._offs_real_pi.value
                    i_pi_opt = p_opt_indices.index(i_pi)
                    traj = res.get_variable_data(name)
                    if self._model.get_scaling_method() & jmi.JMI_SCALING_VARIABLES > 0:
                        p_opt_data[i_pi_opt] = traj.x[0]/sc[z_i]
                    else:
                        p_opt_data[i_pi_opt] = traj.x[0]
                except VariableNotFoundError:
                    print "Warning: Could not find value for parameter " + name
        """
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
        
        self._set_initial_from_file(var_data)
    
    def _set_initial_from_file(self, var_data):
        xx_init = self.get_xx_init()
        t_points = self.get_time_points()
        ts = [i[0] for i in t_points]

        tfcn_in = []
        for i in range(1,self.P):
            tfcn_in += [self.ext_vars[i]['t']]
        if self.md.get_opt_finaltime_free():
            tfcn_in += [self.ext_vars[self.P]['t']]
        
        tfcn = casadi.SXFunction([tfcn_in],[ts])
        tfcn.init()
        input = []
        if (self.options['free_phases'] or self.md.get_opt_finaltime_free()) and self.P > 1:
            for i in range(1,self.P):
                input += [xx_init[self.ext_var_indices['t'+str(i)]]]
            input += [xx_init[self.ext_var_indices['tf']]]
            tfcn.setInput(input)
        tfcn.evaluate()
        t = tfcn.output()

        x_init = N.zeros((len(t), self.model.get_n_x()))
        u_init = N.zeros((len(t)-2, self.model.get_n_u()))
        
        for i in range(self.model.get_n_x()):
            x_init[:,i] = N.interp(t, var_data[:,0], var_data[:,i+1]).transpose()
        for i in range(self.model.get_n_u()):
            u_init[:,i] = N.interp(t[1:-1], var_data[:,0], var_data[:,1+self.model.get_n_x()+i]).transpose()
        
        cnt_x = 0
        cnt_u = 0
        for t_false,i,j in self.get_time_points():
            xx_init[self.get_var_indices()[i][j]['x']] = x_init[cnt_x,:]
            cnt_x += 1
            if j!= 0 and j!=self.K+1:
                xx_init[self.get_var_indices()[i][j]['u']] = u_init[cnt_u,:]
                cnt_u += 1
    
    def _modify_init(self):
        xx_init = self.get_xx_init()
        xx_lb = self.get_xx_lb()
        xx_ub = self.get_xx_ub()
        if (self.options['free_phases'] or self.md.get_opt_finaltime_free()) and self.P > 1:
            if self.options['free_phases_bounds'] != None:
                for i,x in enumerate(self.options['free_phases_bounds']):
                    xx_init[self.ext_var_indices['t'+str(i+1)]]=x[0]
                    xx_lb[self.ext_var_indices['t'+str(i+1)]] = x[1]
                    xx_ub[self.ext_var_indices['t'+str(i+1)]] = x[2]
            else:
                for i in range(1,self.P):
                    xx_init[self.ext_var_indices['t'+str(i)]] = i*(self.ocp.tf-self.ocp.t0)/self.P
                    xx_lb[self.ext_var_indices['t'+str(i)]] = self.ocp.t0
                    xx_ub[self.ext_var_indices['t'+str(i)]] = self.ocp.tf

        if self.md.get_opt_finaltime_free():#self.ocp.tf_free:
            val_ref = self.md.get_value_reference("finalTime")
            init = self.md.get_p_opt_initial_guess()
            lb   = self.md.get_p_opt_min()
            ub   = self.md.get_p_opt_max()
            for i,x in enumerate(init):
                if x[0] == val_ref:
                    if init[i][1] != None:
                        xx_init[self.ext_var_indices['tf']] = init[i][1]
                    if lb[i][1] != None:
                        xx_lb[self.ext_var_indices['tf']] = lb[i][1]
                    if ub[i][1] != None:
                        xx_ub[self.ext_var_indices['tf']] = ub[i][1]
                    
    def _compute_bounds_and_init(self):
        # Create lower and upper bounds
        nlp_lb = -1e20*N.ones(len(self.get_xx()))
        nlp_ub = 1e20*N.ones(len(self.get_xx()))
        nlp_init = N.zeros(len(self.get_xx()))
        
        md = self.get_model_description()
        
        _x_max = md.get_x_max(include_alias = False)
        _u_max = md.get_u_max(include_alias = False)
        _x_min = md.get_x_min(include_alias = False)
        _u_min = md.get_u_min(include_alias = False)
        _x_start = md.get_x_start(include_alias = False)
        _u_start = md.get_u_start(include_alias = False)
        
        x_max = 1e20*N.ones(len(_x_max))
        u_max = 1e20*N.ones(len(_u_max))
        x_min = -1e20*N.ones(len(_x_min))
        u_min = -1e20*N.ones(len(_u_min))
        x_start = -1e20*N.ones(len(_x_start))
        u_start = -1e20*N.ones(len(_u_start))

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

        for t,i,j in self.get_time_points():
            nlp_lb[self.get_var_indices()[i][j]['x']] = x_min
            nlp_ub[self.get_var_indices()[i][j]['x']] = x_max
            nlp_init[self.get_var_indices()[i][j]['x']] = x_start
            if j!= 0 and j!=self.K+1:
                nlp_lb[self.get_var_indices()[i][j]['u']] = u_min
                nlp_ub[self.get_var_indices()[i][j]['u']] = u_max
                nlp_init[self.get_var_indices()[i][j]['u']] = u_start

        self.xx_lb = nlp_lb
        self.xx_ub = nlp_ub
        self.xx_init = nlp_init

        return (nlp_lb,nlp_ub,nlp_init)
    
    def _create_nlp_variables(self):
        # Group variables into elements
        self.vars = {}
        # Extended vars
        self.ext_vars = {}
        
        for i in range(self.P): #Phases
            for j in range(self.K+2): #Points
                xi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_x()]
                ui = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_u()]
                
                if j==0:
                    self.vars[i] = {}
                self.vars[i][j] = {}
                self.vars[i][j]['x'] = xi
                if j!=0 and j!=self.K+1:
                    self.vars[i][j]['u'] = ui
        
        # Group variables indices in the global
        # variable vector
        self.var_indices = {}
        self.xx = []
        
        for i in range(self.P):
            self.var_indices[i] = {}
            for j in range(self.K+2):
                self.var_indices[i][j] = {}
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['x']
                self.var_indices[i][j]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
                if j!=0 and j!=self.K+1:
                    pre_len = len(self.xx)
                    self.xx += self.vars[i][j]['u']
                    self.var_indices[i][j]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
        
        #Create vector allowing or disallowing discontinuous state
        xvars = self.model.get_x()
        for i in range(self.P):
            self.ext_vars[i] = {}
            self.ext_vars[i]['link_x'] = [casadi.SX(0.0) for x in self.model.get_x()]
            for j in self.options['link_options']:
                for l,k in enumerate(self.model.get_x()):
                    if j[0] == str(k):
                        self.ext_vars[i]['link_x'][l] = casadi.SX('link_'+str(k)+'_'+str(i))
                        self.xx += [self.ext_vars[i]['link_x'][l]]
        
        self.ext_var_indices = {}
        #Create vector of time points
        for i in range(self.P+1):
            try:
                self.ext_vars[i]
            except KeyError:
                self.ext_vars[i] = {}
            if i == 0:
                self.ext_vars[i]['t'] = casadi.SX(self.ocp.t0)
            elif i==self.P:
                if self.md.get_opt_finaltime_free():#self.ocp.tf_free:
                    self.ext_vars[i]['t'] = casadi.SX('tf')
                    self.xx += [self.ext_vars[i]['t']]
                    self.ext_var_indices['tf'] = len(self.xx)-1
                else:
                    self.ext_vars[i]['t'] = casadi.SX(self.ocp.tf)
            else:
                if self.options['free_phases'] or self.md.get_opt_finaltime_free():
                    self.ext_vars[i]['t'] = casadi.SX('t_'+str(i))
                    self.xx += [self.ext_vars[i]['t']]
                    self.ext_var_indices['t'+str(i)] = len(self.xx)-1
                else:
                    self.ext_vars[i]['t'] = casadi.SX(i*(self.ocp.tf-self.ocp.t0)/self.P)
                    
    def get_result(self):
        dx_opt = N.zeros((self.P*(self.K+2), self.model.get_n_x()))
        x_opt = N.zeros((self.P*(self.K+2), self.model.get_n_x()))
        u_opt = N.zeros((self.P*(self.K+2), self.model.get_n_u()))
        w_opt = N.zeros((self.P*(self.K+2), 0))
        t_opt = N.zeros(len(self.get_time_points()))

        cnt = 0
        for t,i,j in self.get_time_points():
            t_opt[cnt] = t
            x_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['x']][:,0]
            
            if j!=0 and j!=self.K+1:
                u_opt[cnt,:]  = self.nlp_opt[self.get_var_indices()[i][j]['u']][:,0]
            elif j==0:
                for k in range(self.model.get_n_u()):
                    u_opt[cnt,k] = sum([self.LGl[l](-1.0)*self.nlp_opt[self.get_var_indices()[i][l+1]['u']][k,0] for l in range(self.K)])
            else:
                for k in range(self.model.get_n_u()):
                    u_opt[cnt,k] = sum([self.LGl[l](1.0)*self.nlp_opt[self.get_var_indices()[i][l+1]['u']][k,0] for l in range(self.K)])
            cnt = cnt + 1

        t_points = self.get_time_points()
        
        if self.options['free_phases'] and self.P > 1:
            ts = [i[0] for i in t_points]
            input_t = []
            for i in range(1,self.P):
                input_t += [self.ext_vars[i]['t']]

            self._tfcn = casadi.SXFunction([input_t],[ts])
            self._tfcn.init()
            self._tfcn.setInput(self.nlp_opt[-self.P+1:].flatten())
            self._tfcn.evaluate()
            
            self._t = self._tfcn.output()
        else:
            ts = [i[0] for i in t_points]
            self._tfcn = casadi.SXFunction([[]],[ts])
            self._tfcn.init()
            self._tfcn.evaluate()
            
            self._t = self._tfcn.output()
        """
        ts = [i[0] for i in t_points]
        self._tfcn = casadi.SXFunction([[]],[ts])
        self._tfcn.init()
        self._tfcn.evaluate()
            
        self._t = self._tfcn.output()
        """
        self._result = (self._t,dx_opt,x_opt,u_opt,w_opt)

        return (self._t,dx_opt,x_opt,u_opt,w_opt)
        
    def _create_collocation_constraints(self):
        
        self.h = [] #Equality constraints
        self.g = [] #Inequality constraints
        self.time_points = []
        
        #print "Creating collocation constraints"
        
        #Create initial constraints
        t = self.ext_vars[0]['t']
        z = []
        z += self.vars[0][0]['x']
        z += [t]
        init_constr = list(self.model.get_ode_F0().eval([z])[0])
        self.h += init_constr
        
        #print "Initial Constraints ", init_constr
        
        #Create collocation constraints
        for i in range(self.P):
            self.time_points += [(self.ext_vars[i]['t'],i,0)]
            for j in range(1,self.K+1):
                dx = []
                for k in range(self.model.get_n_x()):
                    dx += [sum([self.LGm[j-1,l]*self.vars[i][l]['x'][k] for l in range(self.K+1)])]
                    
                t = (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])*0.5*(self.LGd[j]+(self.ext_vars[i+1]['t']+self.ext_vars[i]['t'])/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']))
                z = []
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += [t]
                dynamic_constr = list((self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])*0.5*self.model.get_ode_F().eval([z])[0])
                for k in range(self.model.get_n_x()):
                    self.h += [dx[k] - dynamic_constr[k]]

                self.time_points += [(t,i,j)]
            self.time_points += [(self.ext_vars[i+1]['t'],i,self.K+1)]
        
        #Create linking constraints
        for i in range(self.P-1):
            z = []
            for x in range(self.model.get_n_x()):
                z += [self.vars[i][self.K+1]['x'][x] - self.vars[i+1][0]['x'][x] + self.ext_vars[i]['link_x'][x]]
            self.h += z
        
        #print self.h
        
        #Create constraints on the final x
        final_constr = []
        for j in range(self.P):
            for x in range(self.model.get_n_x()):
                temp = []
                for i in range(self.K+1):
                    for k in range(self.K):
                        temp += [self.LGw[k]*self.LGm[k,i]*self.vars[j][i]['x'][x]]
                    
                final_constr += [self.vars[j][self.K+1]['x'][x] - self.vars[j][0]['x'][x] - sum(temp)]
            
        self.h += final_constr
        
        #print "Final constraints ", final_constr
        
        #Create inequality constraint
        if self.options['free_phases'] or self.md.get_opt_finaltime_free():
            for i in range(1,self.P+1):
                self.g += [self.ext_vars[i-1]['t']-self.ext_vars[i]['t']]
        #print self.g
    
    def _create_bolza_functional(self):
         # Generate cost function
        self.cost_mayer = 0
        self.cost_lagrange = 0
    
        if self.model.get_opt_J() != None:
            # Assume Mayer cost
            z = []
            t = self.ext_vars[self.P]['t']
            z += self.vars[self.P-1][self.K+1]['x']
            #z += self.vars[P-1][N+1]['u']
            z += [t]
            self.cost_mayer = list(self.model.get_opt_ode_J().eval([z])[0])[0]
        
        #Add linking options to the Mayer functional
        for i in range(self.P-1):
            for j in self.options['link_options']:
                for l,k in enumerate(self.model.get_x()):
                    if j[0] == str(k) and j[1]==True:
                        self.cost_mayer += self.ext_vars[i]['link_x'][l]*self.ext_vars[i]['link_x'][l]
        

        # Take care of Lagrange cost
        if self.model.get_opt_L() != None:
            for i in range(self.P):
                for j in range(1,self.K+1):
                    t = (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])*0.5*(self.LGr[j-1]+(self.ext_vars[i+1]['t']+self.ext_vars[i]['t'])/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']))
                    z = []
                    z += self.vars[i][j]['x']
                    z += self.vars[i][j]['u']
                    z += [t]
                    self.cost_lagrange += (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])/2.0*self.model.get_opt_ode_L().eval([z])[0][0]*self.LGw[j-1]
          
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

        self.H_fcn = self.Lag_fcn.hessian(0,0)
        
    def get_equality_constraint(self):
        return self.h
    
    def get_inequality_constraint(self):
        return self.g

    def get_cost(self):
        return self.cost_fcn

    def get_hessian(self):
        return self.H_fcn
        
class LegendrePseudoSpectralMethod(CasadiCollocator):
    def __init__(self, model, options):
        
        self.model = model
        self.options = options
        self.ocp = model.get_casadi_ocp()
        
        self._P = options['n_e']
        self._K = options['n_cp']
        self._disc_state = options['disc_state']
        
        
        self._LGL = LegendreGaussLobatto(self._K)
        self._LGLr = self._LGL.get_roots()
        self._LGLw = self._LGL.get_weights()
        self._LGLl = self._LGL.get_lagrange_pol().L
        self._LGLm = self._LGL.get_matrix()
        
        self._create_nlp_variables()
        self._create_collocation_constraints()
        self._create_bolza_functional()
        
        # Necessary!
        super(LegendrePseudoSpectralMethod,self).__init__(model)
        
        self._modify_init()
        
    def _modify_init(self):
        P = self.options['n_e']
        
        if self.options['n_e_free'] and P > 1:
            xx_init = self.get_xx_init()
            xx_lb = self.get_xx_lb()
            xx_ub = self.get_xx_ub()
            if self.options['n_e_bounds'] != None:
                for i,x in enumerate(self.options['n_e_bounds']):
                    xx_init[-P+1+i]=x[0]
                    xx_lb[-P+1+i] = x[1]
                    xx_ub[-P+1+i] = x[2]
            else:
                xx_init[-P+1:] = [x*(self.ocp.tf-self.ocp.t0)/P for x in range(1,P)]
                xx_lb[-P+1:] = [self.ocp.t0]*(P-1)
                xx_ub[-P+1:] = [self.ocp.tf]*(P-1)
        
    def _create_collocation_constraints(self):
        P = self._P
        K = self._K
 
        self.h = []
        
        # Create vector of time points in the collocation problem, and associated
        # variables
        self.time_points = []
        
        #Create initial constraints
        z = []
        #t = self.ocp.t0
        t = self.ext_vars[0]['t']
        #z += [x*2.0/(self.ocp.tf-self.ocp.t0) for x in self.vars[0][0]['dx']]
        #z += [x*2.0/(self.ts[1]-self.ocp.t0) for x in self.vars[0][0]['dx']]
        z += [x*2.0/(self.ext_vars[1]['t']-self.ext_vars[0]['t']) for x in self.vars[0][0]['dx']]
        z += self.vars[0][0]['x']
        z += self.vars[0][0]['u']
        z += self.vars[0][0]['w']
        #z += [casadi.SX(t)]
        z += [t]
        self.h += list(self.model.get_init_F0().eval([z])[0])
        self.h += list(self.model.get_dae_F().eval([z])[0])
        
        
        #Create collocation constraints
        for i in range(P):
            for j in range(K):
                z = []
                #t = (self.ocp.tf-self.ocp.t0)*0.5*(self._LGLr[j]+(self.ocp.tf+self.ocp.t0)/(self.ocp.tf-self.ocp.t0))
                #t = (self.ts[i+1]-self.ts[i])*0.5*(self._LGLr[j]+(self.ts[i+1]+self.ts[i])/(self.ts[i+1]-self.ts[i]))
                t = (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])*0.5*(self._LGLr[j]+(self.ext_vars[i+1]['t']+self.ext_vars[i]['t'])/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']))
                self.time_points.append((t,i,j))
                #z += [x*2.0/(self.ocp.tf-self.ocp.t0) for x in self.vars[i][j]['dx']]
                #z += [x*2.0/(self.ts[i+1]-self.ts[i]) for x in self.vars[i][j]['dx']]
                z += [x*2.0/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']) for x in self.vars[i][j]['dx']]
                z += self.vars[i][j]['x']
                z += self.vars[i][j]['u']
                z += self.vars[i][j]['w']
                #z += [casadi.SX(t)]
                #z += [t]
                z += [t]
                dae_constr = list(self.model.get_dae_F().eval([z])[0])
                self.h += dae_constr
        
        #Create constraints on x and dx
        for i in range(P):
            for j in range(K):
                for k in range(self.model.get_n_x()):
                    temp = [self._LGLm[j,l]*self.vars[i][l]['x'][k] for l in range(K)]
                    coll_constr = self.vars[i][j]['dx'][k] - sum(temp)
                    self.h += [coll_constr]
                    
        #Create phase constraints
        continuity_constr = []
        if P > 1:
            for i in range(P-1):
                for k in range(self.model.get_n_x()):
                    continuity_constr += [self.vars[i][K-1]['x'][k]-self.vars[i+1][0]['x'][k]+self.ext_vars[i]['delta_x'][k]]
                for k in range(self.model.get_n_u()):
                    continuity_constr += [self.vars[i][K-1]['u'][k]-self.vars[i+1][0]['u'][k]]
            self.h += continuity_constr
        self.continuity_constr = continuity_constr
        
        ## Equality constraint residual
        #self.g_fcn = casadi.SXFunction([self.nlp_x],[self.g])
        self.g = []
        #Create inequality constraint
        if self.options['n_e_free']:
            #for i in range(P-2):
            #    self.g += [self.vars[0][0]['t'][i+1]-self.vars[0][0]['t'][i]]
            for i in range(1,P):
                self.g += [self.ext_vars[i-1]['t']-self.ext_vars[i]['t']]
        #print self.g
        
    def _create_bolza_functional(self):
         # Generate cost function
        self.cost_mayer = 0
        self.cost_lagrange = 0
        
        P = self._P
        K = self._K
        
        if self.model.get_opt_J() != None:
            # Assume Mayer cost
            z = []
            #t = self.ocp.tf
            #z += [x*2.0/(self.ocp.tf-self.ocp.t0) for x in self.vars[P-1][K-1]['dx']]
            #z += [x*2.0/(self.ocp.tf-self.ts[-1]) for x in self.vars[P-1][K-1]['dx']]
            t = self.ext_vars[P]['t']
            z += [x*2.0/(self.ext_vars[P]['t']-self.ext_vars[P-1]['t']) for x in self.vars[P-1][K-1]['dx']]
            z += self.vars[P-1][K-1]['x']
            z += self.vars[P-1][K-1]['u']
            z += self.vars[P-1][K-1]['w']
            #z += [casadi.SX(t)]
            z += [t]
            self.cost_mayer = list(self.model.get_opt_J().eval([z])[0])[0]

        # Take care of Lagrange cost
        if self.model.get_opt_L() != None:
            for i in range(P):
                for j in range(K):
                    #t = (self.ocp.tf-self.ocp.t0)*0.5*(self._LGLr[j]+(self.ocp.tf+self.ocp.t0)/(self.ocp.tf-self.ocp.t0))
                    #t = (self.ts[i+1]-self.ts[i])*0.5*(self._LGLr[j]+(self.ts[i+1]+self.ts[i])/(self.ts[i+1]-self.ts[i]))
                    t = (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])*0.5*(self._LGLr[j]+(self.ext_vars[i+1]['t']+self.ext_vars[i]['t'])/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']))
                    z = []
                    #z += [x*2.0/(self.ocp.tf-self.ocp.t0) for x in self.vars[i][j]['dx']]
                    #z += [x*2.0/(self.ts[i+1]-self.ts[i]) for x in self.vars[i][j]['dx']]
                    z += [x*2.0/(self.ext_vars[i+1]['t']-self.ext_vars[i]['t']) for x in self.vars[i][j]['dx']]
                    z += self.vars[i][j]['x']
                    z += self.vars[i][j]['u']
                    z += self.vars[i][j]['w']
                    #z += [casadi.SX(t)]
                    z += [t]
                    #self.cost_lagrange += (self.ocp.tf-self.ocp.t0)/2.0*self.model.get_opt_L().eval([z])[0][0]*self._LGLw[j]
                    #self.cost_lagrange += (self.ts[i+1]-self.ts[i])/2.0*self.model.get_opt_L().eval([z])[0][0]*self._LGLw[j]
                    self.cost_lagrange += (self.ext_vars[i+1]['t']-self.ext_vars[i]['t'])/2.0*self.model.get_opt_L().eval([z])[0][0]*self._LGLw[j]
                    
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
            
        self.Lag_fcn = casadi.SXFunction([self.xx, self.lam, [self.sigma]],[[self.Lag]])

        self.H_fcn = self.Lag_fcn.hessian(0,0)
    
    def _create_nlp_variables(self):
        
        P = self._P
        K = self._K
        
        # Group variables into elements
        self.vars = {}
        # Extended vars
        self.ext_vars = {}
        
        for i in range(P): #Phases
            for j in range(K): #Points
                dxi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_dx()]
                xi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_x()]
                ui = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_u()]
                wi = [casadi.SX(str(x)+'_'+str(i)+','+str(j)) for x in self.model.get_w()]
                
                if j==0:
                    self.vars[i] = {}
                self.vars[i][j] = {}
                self.vars[i][j]['dx'] = dxi
                self.vars[i][j]['x'] = xi
                self.vars[i][j]['u'] = ui
                self.vars[i][j]['w'] = wi
        
        # Group variables indices in the global
        # variable vector
        self.var_indices = {}
        self.xx = []

        for i in range(P):
            self.var_indices[i] = {}
            for j in range(K):
                self.var_indices[i][j] = {}
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['dx']
                self.var_indices[i][j]['dx'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['x']
                self.var_indices[i][j]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['u']
                self.var_indices[i][j]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
                pre_len = len(self.xx)
                self.xx += self.vars[i][j]['w']
                self.var_indices[i][j]['w'] = N.arange(pre_len,len(self.xx),dtype=int)
    
        #Create vector allowing or disallowing discontinuous state
        for i in range(P-1):
            self.ext_vars[i] = {}
            if self.options['disc_state']:
                self.ext_vars[i]['delta_x'] = [casadi.SX('delta_'+str(x)+'_'+str(i)) for x in self.model.get_x()]
                self.xx += self.ext_vars[i]['delta_x']
            else:
                self.ext_vars[i]['delta_x'] = [casadi.SX(0.0) for x in self.model.get_x()]
                
        #Create vector of time points
        for i in range(self._P+1):
            try:
                self.ext_vars[i]
            except KeyError:
                self.ext_vars[i] = {}
            if i == 0:
                self.ext_vars[i]['t'] = casadi.SX(self.ocp.t0)
            elif i==P:
                self.ext_vars[i]['t'] = casadi.SX(self.ocp.tf)
            else:
                if self.options['n_e_free']:
                    self.ext_vars[i]['t'] = casadi.SX('t_'+str(i))
                    self.xx += [self.ext_vars[i]['t']]
                else:
                    self.ext_vars[i]['t'] = casadi.SX(i*(self.ocp.tf-self.ocp.t0)/self._P)
        #print self.xx
        #print self.ext_vars
        #if self._free_elements:
        #    if P > 1:
        #        ti = [casadi.SX('t_'+str(x)) for x in range(P-1)]
        #        self.vars[0][0]['t'] = ti
        #        self.xx += self.vars[0][0]['t']
        
        #self.ts = [(x)*(self.ocp.tf-self.ocp.t0)/self._P for x in range(self._P+1)]
        #for x in range(len(self.ts)):
        #    self.ts[x] = casadi.SX(self.ts[x])
        
        #if self._free_elements and self._P > 1:
        #    for i in range(self._P-1):
        #        self.ts[i+1] = self.vars[0][0]['t'][i]
        
    def get_result(self):
        (t_wrong,dx_opt,x_opt,u_opt,w_opt) = super(LegendrePseudoSpectralMethod,self).get_result()
        t_points = self.get_time_points()
        P = self.options['n_e']
        
        if self.options['n_e_free'] and P > 1:
            ts = [i[0] for i in t_points]
            input_t = []
            for i in range(1,P):
                input_t += [self.ext_vars[i]['t']]

            self._tfcn = casadi.SXFunction([input_t],[ts])
            self._tfcn.init()
            self._tfcn.setInput(self.nlp_opt[-P+1:].flatten())
            self._tfcn.evaluate()
            
            self._t = self._tfcn.output()
        else:
            ts = [i[0] for i in t_points]
            self._tfcn = casadi.SXFunction([[]],[ts])
            self._tfcn.init()
            self._tfcn.evaluate()
            
            self._t = self._tfcn.output()
        
        self._result = (self._t,dx_opt,x_opt,u_opt,w_opt)
        
        if self.options['n_interpolation_points'] == None:
            return (self._t,dx_opt,x_opt,u_opt,w_opt)
        else:
            raise NotImplementedError
    
    def get_equality_constraint(self):
        return self.h
    
    def get_inequality_constraint(self):
        return self.g

    def get_cost(self):
        return self.cost_fcn

    def get_hessian(self):
        return self.H_fcn
