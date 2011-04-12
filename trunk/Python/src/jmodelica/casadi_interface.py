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
import os.path
import numpy as N

try:
    import casadi
except:
    pass

from jmodelica.jmi import compile_jmu
from jmodelica.core import unzip_unit, get_unit_name, get_temp_location
from jmodelica import xmlparser

def compile_casadi(class_name, file_name=[], compiler='auto', target='ipopt', 
    compiler_options={}, compile_to='.', compiler_log_level='warning'):
    """
    Helper function for creating a CasADi compliant model. Extends the compiler
    options with 'generate_xml_equations':True which is an requirement for
    CasADi.
    """
    compiler_options['generate_xml_equations']=True
    compiler_options['normalize_minimum_time_problems']=False
    
    return compile_jmu(class_name, file_name, compiler, target, compiler_options,
                       compile_to, compiler_log_level)

class CasadiModel(object):
    def __init__(self, name, path='.'):
        
        #Create temp binary
        self._tempnames = unzip_unit(archive=name, path=".")
        self._tempdll = self._tempnames[0]
        self._tempxml = self._tempnames[1]
        self._modelname = self._tempnames[2]
        self._tempdir = get_temp_location()
        
        #Load model description
        self.xmldoc = xmlparser.ModelDescription(os.path.join(self._tempdir,self._tempxml))
        
        #Load CasADi interface
        self._load_xml_to_casadi(os.path.join(self._tempdir,self._tempxml))
    
    def get_model_description(self):
        return self.xmldoc
    
    def get_name(self):
        """
        Returns the model name.
        """
        return self._modelname
    
    def _default_options(self, algorithm):
        """ 
        Help method. Gets the options class for the algorithm specified in 
        'algorithm'.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        algorithm = getattr(algdrive, algorithm)
        return algorithm.get_default_options()
    
    def optimize_options(self, algorithm='CasadiRadau'):
        """
        Returns an instance of the optimize options class containing options 
        default values. If called without argument then the options class for 
        the default optimization algorithm will be returned.
        
        Parameters::
        
            algorithm --
                The algorithm for which the options class should be returned. 
                Possible values are: 'CasadiRadau', 'CasadiLPM'
                Default: 'CasadiRadau'
                
        Returns::
        
            Options class for the algorithm specified with default values.
        """
        return self._default_options(algorithm)    
    
    def optimize(self, 
                 algorithm='CasadiRadau', 
                 options={}):
        """
        Solve an optimization problem.
            
        Parameters::
            
            algorithm --
                The algorithm which will be used for the optimization is 
                specified by passing the algorithm class name as string or class 
                object in this argument. 'algorithm' can be any class which 
                implements the abstract class AlgorithmBase (found in 
                algorithm_drivers.py). In this way it is possible to write 
                custom algorithms and to use them with this function.

                The following algorithms are available:
                - 'CasadiRadau'. This algorithm is based 
                  on direct collocation on finite elements and the algorithm 
                  IPOPT is used to obtain a numerical solution to the problem.
                - 'CasadiLPM'
                Default: 'CasadiRadau'
                
            options -- 
                The options that should be used in the algorithm. The options
                documentation can be retrieved from an options object:
                
                    >>> myModel = JMUModel(...)
                    >>> opts = myModel.optimize_options()
                    >>> opts?

                Valid values are: 
                - A dict that overrides some or all of the default values
                  provided by CasadiRadauOptions. An empty
                  dict will thus give all options with default values.
                - A CasadiRadauOptions object.
                Default: Empty dict
            
        Returns::
            
            A result object, subclass of algorithm_drivers.ResultBase.
        """
        return self._exec_algorithm(algorithm,
                                    options)
                                    
    def _exec_algorithm(self, algorithm, options):
        """ 
        Helper function which performs all steps of an algorithm run which are 
        common to all initialize and optimize algortihms.
        
        Raises:: 
        
            Exception if algorithm is not a subclass of 
            jmodelica.algorithm_drivers.AlgorithmBase.
        """
        base_path = 'jmodelica.algorithm_drivers'
        algdrive = __import__(base_path)
        algdrive = getattr(algdrive, 'algorithm_drivers')
        AlgorithmBase = getattr(algdrive, 'AlgorithmBase')
        
        if isinstance(algorithm, basestring):
            algorithm = getattr(algdrive, algorithm)
        
        if not issubclass(algorithm, AlgorithmBase):
            raise Exception(str(algorithm)+
            " must be a subclass of jmodelica.algorithm_drivers.AlgorithmBase")

        # initialize algorithm
        alg = algorithm(self, options)
        # solve optimization problem/initialize
        alg.solve()
        # get and return result
        return alg.get_result()
    
    def get_casadi_ocp(self):
        return self.ocp
        
    def get_casadi_variables(self):
        return self.var

    def get_n_x(self):
        return self.n_x
    
    def get_n_p(self):
        return self.n_p

    def get_n_u(self):
        return self.n_u

    def get_n_w(self):
        return self.n_w
        
    def get_dx_sf(self):
        return self.dx_sf
        
    def get_dx(self):
        return self.dx
    
    def get_x(self):
        return self.x
        
    def get_u(self):
        return self.u
    
    def get_p(self):
        return self.p
    
    def get_variability(self, variablename):
        """ 
        Get variability of variable. 
            
        Parameters::
            
            variablename --
                The name of the variable.
                    
        Returns::
        
            The variability of the variable, CONTINUOUS(0), CONSTANT(1), 
            PARAMETER(2) or DISCRETE(3).

        Raises::
        
            XMLException if variable was not found.
        """
        return self.xmldoc.get_variability(variablename)
    
    def get_pd_val(self):
        pd = []
        for p in self.var.d:
            pFunc = casadi.SXFunction([[]],[[p.getBindingEquation()]])
            pFunc.init()
            pFunc.evaluate()
            
            pd += [(p.getName(),p.getValueReference(),N.array([pFunc.output()]).flatten())]
        return pd
    
    def get_w(self):
        return self.w
    
    def get_t(self):
        return self.t
    
    def get_x_sf(self):
        return self.x_sf

    def get_u_sf(self):
        return self.u_sf
        
    def get_p_sf(self):
        return self.p_sf

    def get_w_sf(self):
        return self.w_sf

    def get_dx_vr_map(self):
        return self.dx_vr_map

    def get_x_vr_map(self):
        return self.x_vr_map
        
    def get_p_vr_map(self):
        return self.p_vr_map

    def get_u_vr_map(self):
        return self.u_vr_map

    def get_w_vr_map(self):
        return self.w_vr_map
        
    def get_dae_F(self):
        return self.dae_F
        
    def get_init_F0(self):
        return self.init_F0
        
    def get_opt_J(self):
        """
        Get the Mayer cost functional.
        """
        return self.opt_J
        
    def get_opt_L(self):
        """
        Get the Lagrange cost functional.
        """
        return self.opt_L
        
    def _convert_to_ode(self, enable_scaling=False):

        self.ocp.makeExplicit()
        
        self.ocp_ode_inputs = []
        self.ocp_ode_inputs += list(self.p)
        self.ocp_ode_inputs += list(self.x)
        self.ocp_ode_inputs += list(self.u)
        self.ocp_ode_inputs += [self.t]
        
        self.ocp_ode_init_inputs = []
        self.ocp_ode_init_inputs += list(self.p)
        self.ocp_ode_init_inputs += list(self.x)
        self.ocp_ode_init_inputs += [self.t]
        
        self.F = casadi.der(self.var.x)
        
        self.ode_F = casadi.SXFunction([self.ocp_ode_inputs], [self.F])
        
        # The initial equations
        self.ode_F0 = casadi.SXFunction([self.ocp_ode_init_inputs],[self.ocp.initeq])
        
        # The Lagrange cost function
        if len(self.ocp.lterm)>0:
            self.opt_ode_L = casadi.SXFunction([self.ocp_ode_inputs],[[self.ocp.lterm[0]]])
        else:
            self.opt_ode_L = None
        
        # The Mayer cost function
        if len(self.ocp.mterm)>0:
            self.ocp_ode_mterm_inputs = []
            self.ocp_ode_mterm_inputs += list(self.p)
            self.ocp_ode_mterm_inputs += [x.atTime(self.ocp.tf,True) for x in self.var.x]
            self.ocp_ode_mterm_inputs += [self.t]
            self.opt_ode_J = casadi.SXFunction([self.ocp_ode_mterm_inputs],[[self.ocp.mterm[0]]])
        else:
            self.opt_ode_J = None
        
        # Boundary Constraints
        self.opt_ode_Cineq = [] #Inequality
        self.opt_ode_C = [] #Equality
        # Modify equality constraints to be on type g(x)=0 (instead of g(x)=a)
        lb = N.array(self.ocp.cfcn_lb, dtype=N.float)
        ub = N.array(self.ocp.cfcn_ub, dtype=N.float)
        for i in range(len(ub)):
            if lb[i] == ub[i]: #The constraint is an equality
                self.opt_ode_C += [self.ocp.cfcn[i]-self.ocp.cfcn_ub[i]]
                #self.ocp.cfcn_ub[i] = casadi.SX(0.0)
                #self.ocp.cfcn_lb[i] = casadi.SX(0.0)
            else: #The constraint is an inequality
                if   lb[i] == -N.inf:
                    self.opt_ode_Cineq += [(1.0)*self.ocp.cfcn[i]-self.ocp.cfcn_ub[i]]
                elif ub[i] == N.inf:
                    self.opt_ode_Cineq += [(-1.0)*self.ocp.cfcn[i]+self.ocp.cfcn_lb[i]]
                else:
                    self.opt_ode_Cineq += [(1.0)*self.ocp.cfcn[i]-self.ocp.cfcn_ub[i]]
                    self.opt_ode_Cineq += [(-1.0)*self.ocp.cfcn[i]+self.ocp.cfcn_lb[i]]
        
        self.ocp_ode_boundary_inputs = []
        self.ocp_ode_boundary_inputs += list(self.p)
        self.ocp_ode_boundary_inputs += [x.atTime(self.ocp.t0,True) for x in self.var.x]
        self.ocp_ode_boundary_inputs += [self.t]
        self.ocp_ode_boundary_inputs += [x.atTime(self.ocp.tf,True) for x in self.var.x]
        self.ocp_ode_boundary_inputs += [self.t]
        self.opt_ode_C     = casadi.SXFunction([self.ocp_ode_boundary_inputs],[self.opt_ode_C])
        self.opt_ode_Cineq = casadi.SXFunction([self.ocp_ode_boundary_inputs],[self.opt_ode_Cineq])
    
        if enable_scaling:
            # Scale model
            # Get nominal values for scaling
            x_nominal = self.xmldoc.get_x_nominal(include_alias = False)
            u_nominal = self.xmldoc.get_u_nominal(include_alias = False)
            
            for vr, val in x_nominal:
                if val != None:
                    self.x_sf[self.x_vr_map[vr]] = N.abs(val)

            for vr, val in u_nominal:
                if val != None:
                    self.u_sf[self.u_vr_map[vr]] = N.abs(val)

            # Create new, scaled variables
            self.x_scaled = self.x_sf*self.x
            self.u_scaled = self.u_sf*self.u
            
            self.ocp_ode_inputs_scaled = []
            self.ocp_ode_inputs_scaled += list(self.p)
            self.ocp_ode_inputs_scaled += list(self.x_scaled)
            self.ocp_ode_inputs_scaled += list(self.u_scaled)
            self.ocp_ode_inputs_scaled += [self.t]
            
            self.ocp_ode_init_inputs_scaled = []
            self.ocp_ode_init_inputs_scaled += list(self.p)
            self.ocp_ode_init_inputs_scaled += list(self.x_scaled)
            self.ocp_ode_init_inputs_scaled += [self.t]
            
            self.ocp_ode_mterm_inputs_scaled = []
            self.ocp_ode_mterm_inputs_scaled += list(self.p)
            self.ocp_ode_mterm_inputs_scaled += [self.x_sf[ind]*x.atTime(self.ocp.tf,True) for ind,x in enumerate(self.var.x)]
            self.ocp_ode_mterm_inputs_scaled += [self.t]

            # Substitute scaled variables
            self.ode_F = list(self.ode_F.eval([self.ocp_ode_inputs_scaled])[0])
            self.ode_F0 = list(self.ode_F0.eval([self.ocp_ode_init_inputs_scaled])[0])
            if self.opt_ode_J != None:
                self.opt_ode_J = list(self.opt_ode_J.eval([self.ocp_ode_mterm_inputs_scaled])[0])
            if self.opt_L!=None:
                self.opt_ode_L = list(self.opt_ode_L.eval([self.ocp_ode_inputs_scaled])[0])

            self.ode_F = casadi.SXFunction([self.ocp_ode_inputs], [self.ode_F])
            self.ode_F0 = casadi.SXFunction([self.ocp_ode_init_inputs],[self.ode_F0])
        
            if self.opt_ode_J != None:
                self.opt_ode_J = casadi.SXFunction([self.ocp_ode_mterm_inputs],[[self.opt_ode_J]])
            if self.opt_ode_J != None:
                self.opt_ode_L = casadi.SXFunction([self.ocp_ode_inputs],[[self.opt_ode_L]])
    
    def get_opt_ode_L(self):
        return self.opt_ode_L

    def get_opt_ode_J(self):
        return self.opt_ode_J    
    
    def get_ode_F(self):
        return self.ode_F
        
    def get_ode_F0(self):
        return self.ode_F0
        
    def _load_xml_to_casadi(self, xml, enable_scaling=False):
        # Store scaling option
        self.enable_scaling = enable_scaling
        
        # Allocate a parser and load the xml
        self.parser = casadi.FMIParser(xml)

        # Obtain the symbolic representation of the OCP
        self.ocp = self.parser.parse()

        # Sort the variables according to type
        self.var = casadi.OCPVariables(self.ocp.variables)
        
        # Make sure the variables appear in value reference order
        var_dict = dict((repr(v),v) for v in self.var.x)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_x_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.var.x[i] = var_dict[name_dict[vr]]
            i = i + 1

        var_dict = dict((repr(v),v) for v in self.var.u)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_u_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.var.u[i] = var_dict[name_dict[vr]]
            i = i + 1

        var_dict = dict((repr(v),v) for v in self.var.z)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_w_variable_names(include_alias = False))        
        i = 0;
        for vr in sorted(name_dict.keys()):
            self.var.z[i] = var_dict[name_dict[vr]]
            i = i + 1
        
        var_dict = dict((repr(v),v) for v in self.var.p)            
        name_dict = dict((x[0],x[1]) for x in self.xmldoc.get_p_opt_variable_names(include_alias = False))        
        i = 0;

        for vr in sorted(name_dict.keys()):
            if name_dict[vr] == "finalTime":
                continue
            self.var.p[i] = var_dict[name_dict[vr]]
            i = i + 1
        
        # Get the variables
        self.dx = casadi.der(self.var.x)
        self.x = casadi.sx(self.var.x)
        self.u = casadi.sx(self.var.u)
        self.w = casadi.sx(self.var.z)
        self.t = self.var.t.sx()
        self.p = casadi.sx(self.var.p)

        # Build maps mapping value references to indices in the
        # variable vectors of casadi
        self.dx_vr_map = {}
        self.x_vr_map = {}
        self.u_vr_map = {}
        self.w_vr_map = {}
        self.p_vr_map = {}

        i = 0;
        for v in self.dx:
            self.dx_vr_map[self.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        i = 0;
        for v in self.x:
            self.x_vr_map[self.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        i = 0;
        for v in self.u:
            self.u_vr_map[self.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        i = 0;
        for v in self.w:
            self.w_vr_map[self.xmldoc.get_value_reference(str(v))] = i
            i = i + 1
            
        i = 0;
        for v in self.p:
            self.p_vr_map[self.xmldoc.get_value_reference(str(v))] = i
            i = i + 1

        self.ocp_inputs = []
        self.ocp_inputs += list(self.dx)
        self.ocp_inputs += list(self.x)
        self.ocp_inputs += list(self.u)
        self.ocp_inputs += list(self.w)
        self.ocp_inputs += [self.t]
        
        # The DAE function
        self.dae_F = casadi.SXFunction([self.ocp_inputs],[self.ocp.dae])

        self.dae_F.init()
        
        # The initial equations
        self.init_F0 = casadi.SXFunction([self.ocp_inputs],[self.ocp.initeq])
        
        # The Mayer cost function
        if len(self.ocp.mterm)>0:
            self.opt_J = casadi.SXFunction([self.ocp_inputs],[[self.ocp.mterm[0]]])
        else:
            self.opt_J = None

        # The Lagrange cost function
        if len(self.ocp.lterm)>0:
            self.opt_L = casadi.SXFunction([self.ocp_inputs],[[self.ocp.lterm[0]]])
        else:
            self.opt_L = None

        self.n_x = len(self.x)
        self.n_u = len(self.u)
        self.n_w = len(self.w)
        self.n_p = len(self.p)

        self.dx_sf = N.ones(self.n_x)
        self.x_sf = N.ones(self.n_x)
        self.u_sf = N.ones(self.n_u)
        self.w_sf = N.ones(self.n_w)
        self.p_sf = N.ones(self.n_p)
        
        if enable_scaling:
            # Scale model
            # Get nominal values for scaling
            dx_nominal = self.xmldoc.get_x_nominal(include_alias = False)
            x_nominal = self.xmldoc.get_x_nominal(include_alias = False)
            u_nominal = self.xmldoc.get_u_nominal(include_alias = False)
            w_nominal = self.xmldoc.get_w_nominal(include_alias = False)

            for vr, val in x_nominal:
                if val != None:
                    self.dx_sf[self.x_vr_map[vr]] = N.abs(val)
                    self.x_sf[self.x_vr_map[vr]] = N.abs(val)

            for vr, val in u_nominal:
                if val != None:
                    self.u_sf[self.u_vr_map[vr]] = N.abs(val)

            for vr, val in w_nominal:
                if val != None:
                    self.w_sf[self.w_vr_map[vr]] = N.abs(val)

            # Create new, scaled variables
            self.dx_scaled = self.x_sf*self.dx
            self.x_scaled = self.x_sf*self.x
            self.u_scaled = self.u_sf*self.u
            self.w_scaled = self.w_sf*self.w

            z_scaled = []
            z_scaled += list(self.dx_scaled)
            z_scaled += list(self.x_scaled)
            z_scaled += list(self.u_scaled)
            z_scaled += list(self.w_scaled)
            z_scaled += [self.var.t.sx()]

            # Substitue scaled variables
            self.dae_F = list(self.dae_F.eval([z_scaled])[0])
            self.init_F0 = list(self.init_F0.eval([z_scaled])[0])
            if self.opt_J!=None:
                self.opt_J = list(self.opt_J.eval([z_scaled])[0])
            if self.opt_L!=None:
                self.opt_L = list(self.opt_L.eval([z_scaled])[0])

            self.dae_F = casadi.SXFunction([self.ocp_inputs],[self.dae_F])
            self.init_F0 = casadi.SXFunction([self.ocp_inputs],[self.init_F0])
            if self.opt_J!=None:
                self.opt_J = casadi.SXFunction([self.ocp_inputs],[self.opt_J])
            if self.opt_L!=None:
                self.opt_L = casadi.SXFunction([self.ocp_inputs],[self.opt_L])
