#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2012 Modelon AB
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
Module containing the tests for Jacobian generation. 
"""

import nose
import os
import numpy as N
import sys as S
import pyfmi as fmi
import pyfmi.fmi_algorithm_drivers as ad

from pymodelica import compile_fmu
from pyfmi.fmi_deprecated import FMUModel2
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path
from pyfmi.common.core import get_platform_dir
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')


class Test_FMI_Jaobians_base:

    def jac_analytic(self, model):
        """
        The jacobian function calculated analytically with directional derivatives.
        """

        # Evaluating the jacobian
        
        # If there are no states return a dummy jacobian.
        states = model.get_states_list()
        if len(states) == 0:
            return N.array([[0.0]])
        
        # Matrix that holds the information, first y elements is the first column of the Jac
        Jac = N.zeros(len(states)**2) 

        # Compute Jac
        derivatives = model.get_derivatives_list()
        states_ref  = [s.value_reference for s in states.values()]
        deriv_ref   = [s.value_reference for s in derivatives.values()]
        v           = [0]*len(states_ref)

        for i in range(len(v)):
            v[i-1]=0
            v[i]=1
            Jac[i*len(v):(i+1)*len(v)] = model.get_directional_derivative(var_ref=states_ref, func_ref=deriv_ref, v=v)

        # Vector manipulation
        Jac = Jac.reshape(len(states),len(states)).transpose() # Reshape to a matrix
        return Jac
        
    def jac_fin_diff(self, model, h=1e-6):
        """
        The jacobian function calculated as an finite approximation.
        """

        # Evaluating the jacobian
        
        # If there are no states return a dummy jacobian.
        state_orig = model.continuous_states
        if len(state_orig) == 0:
            return N.array([[0.0]])
        
        # Matrix that holds the information, first y elements is the first column of the Jac
        Jac = N.zeros(len(state_orig)**2) 

        # Compute Jacobian
        der_orig = model.get_derivatives()
        v        = [0]*len(state_orig)
        
        for i in range(len(state_orig)):
            v[i-1]=0
            v[i]=h
            model.continuous_states = model.continuous_states + v
            der_pert = model.get_derivatives()
            
            Jac[i*len(v):(i+1)*len(v)] = (der_pert - der_orig) / h
            model.continuous_states = state_orig # reset the states
            
        # Vector manipulation
        Jac = Jac.reshape(len(state_orig),len(state_orig)).transpose() # Reshape to a matrix
        return Jac

    def check_jacobian(self, model, tol_check=1e-4):
        """
        Checks the jacobians by comparing a finite difference and an analytical
        jacobian with each other.
        """
        
        errors = abs(self.jac_analytic(model) - self.jac_fin_diff(model))
        
        if errors.max() < tol_check:
            return True
        else:
            print 'Check of Jacobian failed, max error: ', errors.max()
            print '==== Analytical matrix ===='
            print self.jac_analytic(model)
            print '=== Finitie diff matrix ==='
            print self.jac_fin_diff(model)
            return False
            
    def basic_initialize_test(self, cname, fname):
        fn = compile_fmu(cname, fname, version="2.0", 
                         compiler_options={'generate_ode_jacobian':True})
        m = load_fmu(fn)
        m.set_debug_logging(True)
        m.setup_experiment()
        m.initialize()
        assert self.check_jacobian(m)

class Test_FMI_Jaobians_operators(Test_FMI_Jaobians_base):
    
    """
    Test for arithmetic operators, as listed in section 3.4 of the Modelica specification 3.2. 3.2
    """

    def setUp(self):    
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
        

    @testattr(stddist = True)
    def test_addition(self):
        cname = "JacGenTests.JacTestAdd"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
        
    
    @testattr(stddist = True)
    def test_substraction(self):
        cname = "JacGenTests.JacTestSub"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_multiplication(self):
        cname = "JacGenTests.JacTestMult"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    @testattr(stddist = True)
    def test_division(self):
        cname = "JacGenTests.JacTestDiv"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    
    @testattr(stddist = True)
    def test_exponentiation(self):
        cname = "JacGenTests.JacTestPow"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
class Test_FMI_Jaobians_functions(Test_FMI_Jaobians_base):
    """
    This class tests the elemenary functions that Jmodelica.org has implemented according to
    Petter Lindhomlms thesis "Efficient implementation of Jacobians using automatic differentiation", p. 35
    """


    def setUp(self):    
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_abs1(self):
        cname = "JacGenTests.JacTestAbs1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_min(self):
        cname = "JacGenTests.JacTestMin"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0   

    @testattr(stddist = True)
    def test_max(self):
        cname = "JacGenTests.JacTestMax"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        
    @testattr(stddist = True)
    def test_sqrt(self):
        cname = "JacGenTests.JacTestSqrt"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0   
        
    @testattr(stddist = True)
    def test_sin(self):
        cname = "JacGenTests.JacTestSin"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    @testattr(stddist = True)
    def test_cos(self):
        cname = "JacGenTests.JacTestCos"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    @testattr(stddist = True)
    def test_tan(self): 
        cname = "JacGenTests.JacTestTan"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    @testattr(stddist = True)
    def test_Cotan(self):   
        cname = "JacGenTests.JacTestCoTan"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0   

    @testattr(stddist = True)
    def test_asin(self):    
        cname = "JacGenTests.JacTestAsin"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    @testattr(stddist = True)
    def test_acos(self):    
        cname = "JacGenTests.JacTestAcos"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    @testattr(stddist = True)
    def test_atan(self):    
        cname = "JacGenTests.JacTestAtan"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
        
        
    @testattr(stddist = True)
    def test_atan2(self):       
        cname = "JacGenTests.JacTestAtan2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
        
    @testattr(stddist = True)
    def test_sinh(self):    
        cname = "JacGenTests.JacTestSinh"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
        
    @testattr(stddist = True)
    def test_cosh(self):    
        cname = "JacGenTests.JacTestCosh"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

        
    @testattr(stddist = True)
    def test_tanh(self):    
        cname = "JacGenTests.JacTestTanh"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_exp(self): 
        cname = "JacGenTests.JacTestExp"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_log(self):
        cname = "JacGenTests.JacTestLog"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_log10(self):
        cname = "JacGenTests.JacTestLog10"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_smooth(self):
        cname = "JacGenTests.SmoothTest1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    
    @testattr(stddist = True)
    def test_not(self):
        cname = "JacGenTests.NotTest1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    
    
class Test_FMI_Jaobians_Whencases(Test_FMI_Jaobians_base):
    
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
    
    """
    #Raises compliance error: "Else clauses in when equations are currently not supported". 
    #Even if generate_ode_jacobian is set to false. 
    @testattr(stddist = True)
    def test_whenElse(self):
        cname = "JacGenTests.JacTestWhenElse"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':False,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    """
    
    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
     Raises compliance error: "Else clauses in when equations are currently not supported". 
    Even if generate_ode_jacobian is set to false. 
    @testattr(stddist = True)
    def test_whenSimple(self):
        cname = "JacGenTests.JacTestWhenSimple"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
    @testattr(stddist = True)
    def test_whenPre(self):
        cname = "JacGenTests.JacTestWhenPre"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.    
    @testattr(stddist = True)
    def test_whenFunction(self):
        cname = "JacGenTests.JacTestWhenFunction"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
    @testattr(stddist = True)
    def test_whenSample(self):
        cname = "JacGenTests.JacTestWhenSample"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    """
    
class Test_FMI_Jaobians_Ifcases(Test_FMI_Jaobians_base):
    
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_IfExpression1(self):
        cname = "JacGenTests.JacTestIfExpression1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
        
    @testattr(stddist = True)
    def test_IfExpression2(self):
        cname = "JacGenTests.JacTestIfExpression2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 
    

    @testattr(stddist = True)
    def test_IfExpression3(self):
        cname = "JacGenTests.JacTestIfExpression3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_IfExpressionSim1(self):
        cname = "JacGenTests.JacTestIfExpression3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        m.simulate(final_time=2)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        m.simulate(final_time=4, options={'initialize':False})
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_IfEquation1(self):
        cname = "JacGenTests.JacTestIfEquation1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

    @testattr(stddist = True)
    def test_IfEquation2(self):
        cname = "JacGenTests.JacTestIfEquation2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_IfEquationSimNested(self):
        cname = "JacGenTests.JacTestIfEquation3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        m.simulate(final_time=2)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        
    @testattr(stddist = True)
    def test_IfEquation4(self):
        cname = "JacGenTests.JacTestIfEquation4"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0 

##
##Raised the following error
##CcodeCompilationError: 
##Message: Compilation of generated C code failed.
##  @testattr(stddist = True)
##  def test_IfFunctionRecord(self):
##      cname = "JacGenTests.JacTestIfFunctionRecord"
##      fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
##      'eliminate_alias_variables':False}, version="2.0alpha")
##      m = FMUModel2(fn)
##      m.set_debug_logging(True)
##      Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
##      assert n_errs ==0       

class Test_FMI_Jaobians_Functions(Test_FMI_Jaobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_Function1(self):
        cname = "JacGenTests.JacTestFunction1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0


    @testattr(stddist = True)
    def test_Function2(self):
        cname = "JacGenTests.JacTestFunction2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0


    @testattr(stddist = True)
    def test_Function3(self):
        cname = "JacGenTests.JacTestFunction3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Function4(self):
        cname = "JacGenTests.JacTestFunction4"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0           
    
    @testattr(stddist = True)
    def test_Function5(self):
        cname = "JacGenTests.JacTestFunction5"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0


    @testattr(stddist = True)
    def test_Function6(self):
        cname = "JacGenTests.JacTestFunction6"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Function7(self):
        cname = "JacGenTests.JacTestFunction7"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        
    @testattr(stddist = True)
    def test_JacTestExpInFuncArg1(self):
        cname = "JacGenTests.JacTestExpInFuncArg1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_DiscreteFunction1(self):
        cname = "JacGenTests.JacTestDiscreteFunction1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

class Test_FMI_Jacobians_Simulation(Test_FMI_Jaobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_FunctionSim1(self):
        cname = "JacGenTests.JacTestFunction1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        m.simulate(final_time=5)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0


    @testattr(stddist = True)
    def test_FunctionSim2(self):
        cname = "JacGenTests.JacTestFunction3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.simulate(final_time=5)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0           


class Test_FMI_Jaobians_Unsolved_blocks(Test_FMI_Jaobians_base):
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_Unsolved_blocks1(self):
        cname = "JacGenTests.Unsolved_blocks1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks2(self):
        cname = "JacGenTests.Unsolved_blocks2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks3(self):
        cname = "JacGenTests.Unsolved_blocks3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks4(self):
        cname = "JacGenTests.Unsolved_blocks4"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks5(self):
        cname = "JacGenTests.Unsolved_blocks5"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks6(self):
        cname = "JacGenTests.Unsolved_blocks6"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,\
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0       


    @testattr(stddist = True)
    def test_Unsolved_blocks_torn_1(self):
        cname = "JacGenTests.Unsolved_blocks_torn_1"
        fn = compile_fmu(cname,self.fname,compiler_options={'automatic_tearing':True,
            'equation_sorting':True,'eliminate_alias_variables':False,
            'generate_ode_jacobian':True}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Unsolved_blocks_torn_2(self):
        cname = "JacGenTests.Unsolved_blocks_torn_2"
        fn = compile_fmu(cname,self.fname,compiler_options={'automatic_tearing':True,
            'equation_sorting':True,'eliminate_alias_variables':False,
            'generate_ode_jacobian':True}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize(relativeTolerance=1e-11)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0       
        
    # Test not working when run in test suite. Works when run seperately. Commented out for now.
    #@testattr(stddist = True)
    #def test_local_loop_1(self):
        #cname = "TearingTests.TearingTest1"
        #fn = compile_fmu(cname,os.path.join(path_to_mofiles,'TearingTests.mo'),compiler_options={'automatic_tearing':True,
            #'equation_sorting':True,'eliminate_alias_variables':False,
            #'generate_ode_jacobian':True, "local_iteration_in_tearing":"all"},version="2.0alpha")
        #m = FMUModel2(fn)
        #m.set_debug_logging(True)
        #m.initialize(relativeTolerance=1e-11)
        #Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        #assert n_errs ==0       
        
class Test_FMI_Jaobians_Miscellaneous(Test_FMI_Jaobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_Input(self):
        cname = "JacGenTests.JacTestInput"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0
        t = N.linspace(0.,5.0,100) 
        u_traj = N.transpose(N.vstack((t,t)))
        input_object = ('u', u_traj)
        m.simulate(final_time = 10, input = input_object)
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0

    @testattr(stddist = True)
    def test_Record1(self):
        self.basic_initialize_test("JacGenTests.JacTestRecord1", self.fname)
        
    @testattr(stddist = True)
    def test_Array1(self):
        cname = "JacGenTests.JacTestArray1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0alpha")
        m = FMUModel2(fn)
        m.set_debug_logging(True)
        m.initialize()
        Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
        assert n_errs ==0    
