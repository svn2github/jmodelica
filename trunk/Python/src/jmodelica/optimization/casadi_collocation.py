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
""" 
Collocation algorithms based on CasADi. 
"""

try:
    import casadi
except:
    pass

import numpy as N
from jmodelica.xmlparser import ModelDescription

import codecs
from operator import itemgetter
import jmodelica.jmi

# This function is needed since CasADi creates derivative names
# differently than those present in the FMI XML files:
# FMI: x.der(y)
# CasADI: der(x.y)
def convert_der_name(dx_name):
    name = dx_name.split('(')
    name = name[1].split(')')
    name = name[0]
    name_parts = name.split('.')
    i = 0
    final_name = ''
    for n in name_parts:
        if i==len(name_parts)-1:
            final_name = final_name + 'der(' + n + ')'
        else:
            final_name = final_name + n + '.'
            i = i+1
    return final_name

class XMLOCP:

    def __init__(self,fname):

        # Load model description
        self.xmldoc = ModelDescription(fname)
        
        # Allocate a parser and load the xml
        self.parser = casadi.FMIParser(fname)

        # Obtain the symbolic representation of the OCP
        self.ocp = self.parser.parse()

        # Sort the variables according to type
        self.ocp.sortVariables()

        # Make sure the variables appear in value reference order

        var_dict = dict((convert_der_name(str(v)),v) for v in self.ocp.xdot)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_dx_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.ocp.xdot[i] = var_dict[name_dict[vr]]
            i = i + 1

        var_dict = dict((str(v),v) for v in self.ocp.x)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_x_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.ocp.x[i] = var_dict[name_dict[vr]]
            i = i + 1

        var_dict = dict((str(v),v) for v in self.ocp.u)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_u_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.ocp.u[i] = var_dict[name_dict[vr]]
            i = i + 1

        var_dict = dict((str(v),v) for v in self.ocp.xa)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_w_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.ocp.xa[i] = var_dict[name_dict[vr]]
            i = i + 1

        self.ocp_inputs = []
        self.ocp_inputs += self.ocp.xdot
        self.ocp_inputs += self.ocp.x
        self.ocp_inputs += self.ocp.u
        self.ocp_inputs += self.ocp.xa
        self.ocp_inputs += self.ocp.t
        
        # The DAE function
        self.dae_F = casadi.SXFunction([self.ocp_inputs],[self.ocp.dyneq])

        self.dae_F.init()
        
        # The initial equations
        self.init_F0 = casadi.SXFunction([self.ocp_inputs],[self.ocp.initeq])

        # The Mayer cost function
        self.opt_J = casadi.SXFunction([self.ocp_inputs],[[self.ocp.mterm[0]]])

        self.n_x = len(self.ocp.x)
        self.n_u = len(self.ocp.u)
        self.n_w = len(self.ocp.xa)

    def dae_F(self): 
        return self.F

    def init_F0(self):
        return self._initF0

    def get_name(self):
        return self.xmldoc.get_model_name()

class PolyomialUtils:

    def __init__():
        pass
    
class Collocator:

    def __init__(xmlocp):
        pass

    def get_xmlocp(self):
        pass

    def get_n_x(self):
        pass

    def get_n_u(self):
        pass

    def get_n_w(self):
        pass

    def get_dx_vr_map(self):
        pass

    def get_x_vr_map(self):
        pass

    def get_u_vr_map(self):
        pass

    def get_w_vr_map(self):
        pass

    def get_time_points(self):
        pass

    def get_xx(self):
        pass

    def get_var_indices(self):
        pass

    def get_xx_lb(self):
        pass

    def get_xx_ub(self):
        pass

    def get_xx_init(self):
        pass

    def get_g(self):
        pass

    def get_cost(self):
        pass

    def get_hess_lag(self):
        pass

    def _compute_bounds_and_init(self):
        # Create lower and upper bounds
        xx_lb = N.zeros(len(self.get_xx()))
        xx_ub = N.zeros(len(self.get_xx()))
        xx_init = N.zeros(len(self.get_xx()))
        _dx_max = self.get_xmlocp().xmldoc.get_dx_max(include_alias = False)
        _x_max = self.get_xmlocp().xmldoc.get_x_max(include_alias = False)
        _u_max = self.get_xmlocp().xmldoc.get_u_max(include_alias = False)
        _w_max = self.get_xmlocp().xmldoc.get_w_max(include_alias = False)
        _dx_min = self.get_xmlocp().xmldoc.get_dx_min(include_alias = False)
        _x_min = self.get_xmlocp().xmldoc.get_x_min(include_alias = False)
        _u_min = self.get_xmlocp().xmldoc.get_u_min(include_alias = False)
        _w_min = self.get_xmlocp().xmldoc.get_w_min(include_alias = False)
        _dx_start = self.get_xmlocp().xmldoc.get_dx_start(include_alias = False)
        _x_start = self.get_xmlocp().xmldoc.get_x_start(include_alias = False)
        _u_start = self.get_xmlocp().xmldoc.get_u_start(include_alias = False)
        _w_start = self.get_xmlocp().xmldoc.get_w_start(include_alias = False)

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
                dx_min[self.get_dx_vr_map()[vr]] = val
        for vr, val in _dx_max:
            if val != None:
                dx_max[self.get_dx_vr_map()[vr]] = val
        for vr, val in _dx_start:
            if val != None:
                dx_start[self.get_dx_vr_map()[vr]] = val

        for vr, val in _x_min:
            if val != None:
                x_min[self.get_x_vr_map()[vr]] = val
        for vr, val in _x_max:
            if val != None:
                x_max[self.get_x_vr_map()[vr]] = val
        for vr, val in _x_start:
            if val != None:
                x_start[self.get_x_vr_map()[vr]] = val

        for vr, val in _u_min:
            if val != None:
                u_min[self.get_u_vr_map()[vr]] = val
        for vr, val in _u_max:
            if val != None:
                u_max[self.get_u_vr_map()[vr]] = val
        for vr, val in _u_start:
            if val != None:
                u_start[self.get_u_vr_map()[vr]] = val

        for vr, val in _w_min:
            if val != None:
                w_min[self.get_w_vr_map()[vr]] = val
        for vr, val in _w_max:
            if val != None:
                w_max[self.get_w_vr_map()[vr]] = val
        for vr, val in _w_start:
            if val != None:
                w_start[self.get_w_vr_map()[vr]] = val

        for t,i,j in self.time_points:
            xx_lb[self.get_var_indices()[i][j]['dx']] = dx_min
            xx_ub[self.get_var_indices()[i][j]['dx']] = dx_max
            xx_init[self.get_var_indices()[i][j]['dx']] = dx_start
            xx_lb[self.get_var_indices()[i][j]['x']] = x_min
            xx_ub[self.get_var_indices()[i][j]['x']] = x_max
            xx_init[self.get_var_indices()[i][j]['x']] = x_start
            xx_lb[self.get_var_indices()[i][j]['u']] = u_min
            xx_ub[self.get_var_indices()[i][j]['u']] = u_max
            xx_init[self.get_var_indices()[i][j]['u']] = u_start
            xx_lb[self.get_var_indices()[i][j]['w']] = w_min
            xx_ub[self.get_var_indices()[i][j]['w']] = w_max
            xx_init[self.get_var_indices()[i][j]['w']] = w_start

        return (xx_lb,xx_ub,xx_init)
        
    def solve(self):

        # Create Solver
        self.solver = casadi.IpoptSolver(self.get_cost(),self.get_g(),self.get_hess_lag())

        # Set options
        # solver.setOption("tol",1e-10)
        #solver.setOption("derivative_test",'second-order')
        self.solver.setOption("max_iter",300)

        # Initialize
        self.solver.init();

        # Initial condition
#        self.x_initial_guess = len(self.xx) * [0]
        self.solver.setInput(self.get_xx_init(),casadi.NLP_X_INIT)
        
        # Bounds on x
#        self.xx_lb = len(self.xx)*[-100]
#        self.xx_ub = len(self.xx)*[100]
        self.solver.setInput(self.get_xx_lb(),casadi.NLP_LBX)
        self.solver.setInput(self.get_xx_ub(),casadi.NLP_UBX)
        
        # Bounds on the constraints
        self.glub = len(self.g)*[0]
        self.solver.setInput(self.glub,casadi.NLP_LBG)
        self.solver.setInput(self.glub,casadi.NLP_UBG)
        
        # Solve the problem
        self.solver.solve()
        
        self.xx_opt = N.array(self.solver.getOutput(casadi.NLP_X_OPT))

    def get_result(self):
        dx_opt = N.zeros((len(self.get_time_points()),self.get_n_x()))
        x_opt = N.zeros((len(self.get_time_points()),self.get_n_x()))
        w_opt = N.zeros((len(self.get_time_points()),self.get_n_w()))
        u_opt = N.zeros((len(self.get_time_points()),self.get_n_u()))
        
        t_opt = N.zeros(len(self.get_time_points()))

        cnt = 0
        for t,i,j in self.get_time_points():
            t_opt[cnt] = t
            dx_opt[cnt,:] = self.xx_opt[self.var_indices[i][j]['dx']]
            x_opt[cnt,:] = self.xx_opt[self.var_indices[i][j]['x']]
            u_opt[cnt,:] = self.xx_opt[self.var_indices[i][j]['u']]
            w_opt[cnt,:] = self.xx_opt[self.var_indices[i][j]['w']]
            cnt = cnt + 1
        return (t_opt,dx_opt,x_opt,u_opt,w_opt)


    def write_result(self,file_name='', format='txt', scaled=False):
        """
        Export an optimization or simulation result to file in Dymolas result file 
        format. The parameter values are read from the z vector of the model object 
        and the time series are read from the data argument.

        Parameters::
    
            model --
                A Model object.
            
            data --
                A two dimensional array of variable trajectory data. The first 
                column represents the time vector. The following colums contain, in 
                order, the derivatives, the states, the inputs and the algebraic 
                variables. The ordering is according to increasing value references.
            
            file_name --
                If no file name is given, the name of the model (as defined by 
                JMIModel.get_name()) concatenated with the string '_result' is used. 
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

        data = N.hstack((N.transpose(N.array([t])),dx_opt,x_opt,u_opt,w_opt))

        if (format=='txt'):

            if file_name=='':
                file_name = self.get_xmlocp().get_name() + '_result.txt'

            # Open file
            f = codecs.open(file_name,'w','utf-8')

            # Write header
            f.write('#1\n')
            f.write('char Aclass(3,11)\n')
            f.write('Atrajectory\n')
            f.write('1.1\n')
            f.write('\n')
                
            #xmlfile = model.get_name()+'.xml'
            #md = xmlparser.ModelDescription(xmlfile)
            md = self.get_xmlocp().xmldoc
        
            # sort in value reference order (must match order in data)
            names = sorted(md.get_variable_names(), key=itemgetter(0))
            aliases = sorted(md.get_variable_aliases(), key=itemgetter(0))
            descriptions = sorted(md.get_variable_descriptions(), key=itemgetter(0))
            variabilities = sorted(md.get_variable_variabilities(), key=itemgetter(0))
        
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
            # This is really shaky and relies on how JModelica assigns 
            # value references. Need to be changed.
            name_dict = dict((x[0],x[1]) for x in self.get_xmlocp().xmldoc.get_dx_variable_names(include_alias = False))        
            n_parameters = sorted(name_dict.keys())[0]
            f.write('int dataInfo(%d,%d)\n' % (num_vars + 1, 4))
            f.write('0 1 0 -1 # time\n')
            
            cnt_1 = 1
            cnt_2 = 1
        
            for i, name in enumerate(names):
                (ref, type) = jmodelica.jmi._translate_value_ref(name[0])
            
                if int(ref) < n_parameters: # Put parameters in data set
                    if aliases[i][1] == 0: # no alias
                        cnt_1 = cnt_1 + 1
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

#            sc = self.get_variable_scaling_factors()
#            z = model.z
            
#            rescale = (model.get_scaling_method() == 
#                       jmodelica.jmi.JMI_SCALING_VARIABLES) and (not scaled)

            rescale = False

            # Write data
            # Write data set 1
            f.write('float data_1(%d,%d)\n' % (2, n_parameters + 1))
            f.write("%12.12f" % data[0,0])
            str_text = ''
            for ref in range(n_parameters):
                #print ref
                if rescale:
                    #print z[ref]*sc[ref]
                    #print "hej"
                    str_text += " %12.12f" % (z[ref]*sc[ref])
                else:
                    #print z[ref]
                    #print "hopp"
                    str_text += " %12.12f" % (0)
                
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
                            str = str + (" %12.12f" % (data[i,ref]*sc[ref-1+n_parameters]))
                        else:
                            str = str + (" %12.12f" % data[i,ref])
                f.write(str+'\n')

            f.write('\n')

            f.close()

        else:
            raise Error('Export on binary Dymola result files not yet supported.')


class BackwardEulerCollocator(Collocator):

    def __init__(self,xmlocp, n_e):
        self.xmlocp = xmlocp
        self.n_e = n_e

        # Build maps mapping value references to indices in the
        # variable vectors of casadi
        self.dx_vr_map = {}
        self.x_vr_map = {}
        self.u_vr_map = {}
        self.w_vr_map = {}

        i = 0;
        for v in xmlocp.ocp.xdot:
            self.dx_vr_map[xmlocp.xmldoc.get_value_reference(convert_der_name(str(v)))] = i
            i = i + 1

        i = 0;
        for v in xmlocp.ocp.x:
            self.x_vr_map[xmlocp.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        i = 0;
        for v in xmlocp.ocp.u:
            self.u_vr_map[xmlocp.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        i = 0;
        for v in xmlocp.ocp.xa:
            self.w_vr_map[xmlocp.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        # Group variables into elements
        self.vars = {}

        # Create variables for the collocation points
        for i in range(self.n_e+1):
            dxi = []
            xi = []
            ui = []
            wi = []
            for j in range(xmlocp.n_x):
                dxi.append(casadi.SX(str(self.xmlocp.ocp.xdot[j])+'_'+str(i)))
            for j in range(xmlocp.n_x):
                xi.append(casadi.SX(str(self.xmlocp.ocp.x[j])+'_'+str(i)))
            for j in range(xmlocp.n_u):
                ui.append(casadi.SX(str(self.xmlocp.ocp.u[j])+'_'+str(i)))
            for j in range(xmlocp.n_w):
                wi.append(casadi.SX(str(self.xmlocp.ocp.xa[j])+'_'+str(i)))
            if i==0:
                self.vars[1] = {}
                self.vars[1][0] = {}
                self.vars[1][0]['x'] = xi
                self.vars[1][0]['dx'] = dxi
                self.vars[1][0]['u'] = ui
                self.vars[1][0]['w'] = wi
            elif i==1:
                self.vars[1][1] = {}
                self.vars[1][1]['x'] = xi
                self.vars[1][1]['dx'] = dxi
                self.vars[1][1]['u'] = ui
                self.vars[1][1]['w'] = wi
            else:
                self.vars[i] = {}
                self.vars[i][1] = {}
                self.vars[i][1]['x'] = xi
                self.vars[i][1]['dx'] = dxi
                self.vars[i][1]['u'] = ui
                self.vars[i][1]['w'] = wi


        # Group variables indices in the global
        # variable vector
        self.var_indices = {}
        self.var_indices[1] = {}
        self.var_indices[1][0] = {}
        self.xx = []
        pre_len = len(self.xx)
        self.xx += self.vars[1][0]['dx']
        self.var_indices[1][0]['dx'] = N.arange(pre_len,len(self.xx),dtype=int)
        pre_len = len(self.xx)
        self.xx += self.vars[1][0]['x']
        self.var_indices[1][0]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
        pre_len = len(self.xx)
        self.xx += self.vars[1][0]['u']
        self.var_indices[1][0]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
        pre_len = len(self.xx)
        self.xx += self.vars[1][0]['w']
        self.var_indices[1][0]['w'] = N.arange(pre_len,len(self.xx),dtype=int)
        pre_len = len(self.xx)

        for i in range(self.n_e):
            if i>0:
                self.var_indices[i+1] = {}
            self.var_indices[i+1][1] = {}
            self.xx += self.vars[i+1][1]['dx']
            self.var_indices[i+1][1]['dx'] = N.arange(pre_len,len(self.xx),dtype=int)
            pre_len = len(self.xx)
            self.xx += self.vars[i+1][1]['x']
            self.var_indices[i+1][1]['x'] = N.arange(pre_len,len(self.xx),dtype=int)
            pre_len = len(self.xx)
            self.xx += self.vars[i+1][1]['u']
            self.var_indices[i+1][1]['u'] = N.arange(pre_len,len(self.xx),dtype=int)
            pre_len = len(self.xx)
            self.xx += self.vars[i+1][1]['w']
            self.var_indices[i+1][1]['w'] = N.arange(pre_len,len(self.xx),dtype=int)
            pre_len = len(self.xx)

        # Create vector of time points in the collocation problem, and associated
        # variables
        self.time_points = []

        # Equality constraints
        self.g = []

        z = []
        z += self.vars[1][0]['dx']
        z += self.vars[1][0]['x']
        z += self.vars[1][0]['u']
        z += self.vars[1][0]['w']
        z += [xmlocp.ocp.t0]
        self.g += list(xmlocp.init_F0.eval([z])[0])
        self.g += list(xmlocp.dae_F.eval([z])[0])
        self.g += [self.vars[1][0]['u'][0]-self.vars[1][1]['u'][0]]
        
        self.time_points.append((xmlocp.ocp.t0,1,0))
        
        # DAE residual and collocation equations
        for i in range(n_e):
            t = (xmlocp.ocp.tf-xmlocp.ocp.t0)/n_e*(i+1)
            self.time_points.append((t,i+1,1))
            z = []
            z += self.vars[i+1][1]['dx']
            z += self.vars[i+1][1]['x']
            z += self.vars[i+1][1]['u']
            z += self.vars[i+1][1]['w']
            z += [t]
            self.g += list(xmlocp.dae_F.eval([z])[0])
            if i==0:
                for j in range(xmlocp.n_x):
                    self.g.append(self.vars[i+1][1]['dx'][j] -
                                  (self.vars[i+1][1]['x'][j] -
                                   self.vars[i+1][0]['x'][j])/((xmlocp.ocp.tf-xmlocp.ocp.t0)/n_e))
            else:
                for j in range(xmlocp.n_x):
                    self.g.append(self.vars[i+1][1]['dx'][j] -
                                  (self.vars[i+1][1]['x'][j] -
                                   self.vars[i][1]['x'][j])/((xmlocp.ocp.tf-xmlocp.ocp.t0)/n_e))

        self.n_g_colloc = len(self.g)

        # Add path constraints
        for t,i,j in self.time_points:
            pass
            
        # Equality constraint residual
        self.g_fcn = casadi.SXFunction([self.xx],[self.g])

        # Assume Mayer cost
        z = []
        z += self.vars[n_e][1]['dx']
        z += self.vars[n_e][1]['x']
        z += self.vars[n_e][1]['u']
        z += self.vars[n_e][1]['w']
        z += [xmlocp.ocp.tf]
        self.cost = list(xmlocp.opt_J.eval([z])[0])[0]

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

        (self.xx_lb,self.xx_ub,self.xx_init) = self._compute_bounds_and_init()

    def get_xmlocp(self):
        return self.xmlocp

    def get_n_x(self):
        return self.get_xmlocp().n_x

    def get_n_u(self):
        return self.get_xmlocp().n_u

    def get_n_w(self):
        return self.get_xmlocp().n_w

    def get_dx_vr_map(self):
        return self.dx_vr_map

    def get_x_vr_map(self):
        return self.x_vr_map

    def get_u_vr_map(self):
        return self.u_vr_map

    def get_w_vr_map(self):
        return self.w_vr_map

    def get_time_points(self):
        return self.time_points

    def get_xx(self):
        return self.xx

    def get_var_indices(self):
        return self.var_indices

    def get_xx_lb(self):
        return self.xx_lb

    def get_xx_ub(self):
        return self.xx_ub

    def get_xx_init(self):
        return self.xx_init

    def get_g(self):
        return self.g_fcn

    def get_cost(self):
        return self.cost_fcn

    def get_hess_lag(self):
        return self.H_fcn

