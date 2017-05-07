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
from pyfmi import load_fmu
from tests_jmodelica import testattr, get_files_path
from pyfmi.common.core import get_platform_dir
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')


class Test_FMI_Jacobians_base:

    def jac_analytic(self, model, A=True, B=True, C=True, D=True):
        """
        The jacobian function calculated analytically with directional derivatives.
        """

        # Evaluating the jacobian
        orig_finite_diffs = model.force_finite_differences
        model.force_finite_differences = False
        A, B, C, D = model.get_state_space_representation(A=A, B=B, C=C, D=D)
        model.force_finite_differences = orig_finite_diffs
        return A, B, C, D
        
    def jac_fin_diff(self, model, A=True, B=True, C=True, D=True):
        """
        The jacobian function calculated as an finite approximation.
        """

        # Evaluating the jacobian
        # Evaluating the jacobian
        
        orig_finite_diffs = model.force_finite_differences
        model.force_finite_differences = True
        A, B, C, D = model.get_state_space_representation(A=A, B=B, C=C, D=D)
        model.force_finite_differences = orig_finite_diffs
        return A, B, C, D

    def check_jacobian(self, model, tol_check=1e-3, A=True, B=True, C=True, D=True):
        """
        Checks the jacobians by comparing a finite difference and an analytical
        jacobian with each other.
        """
        
        a_jacA, a_jacB, a_jacC, a_jacD = self.jac_analytic(model, A=A, B=B, C=C, D=D)
        f_jacA, f_jacB, f_jacC, f_jacD = self.jac_fin_diff(model, A=A, B=B, C=C, D=D)
        if A:
            a_jac=a_jacA
            f_jac=f_jacA
            assert self.comp_jac_matrix(a_jac, f_jac, comp_matrix='A', tol_check=tol_check)
        if B:
            a_jac=a_jacB
            f_jac=f_jacB
            assert self.comp_jac_matrix(a_jac, f_jac, comp_matrix='B', tol_check=tol_check)
        if C:
            a_jac=a_jacC
            f_jac=f_jacC
            assert self.comp_jac_matrix(a_jac, f_jac, comp_matrix='C', tol_check=tol_check)
        if D:
            a_jac=a_jacD
            f_jac=f_jacD
            assert self.comp_jac_matrix(a_jac, f_jac, comp_matrix='D', tol_check=tol_check)
            
    def comp_jac_matrix(self, a_jac, f_jac, comp_matrix, tol_check=1e-3):
        a_jacPrint = a_jac
        f_jacPrint = f_jac        
        a_jac = a_jac.data
        f_jac = f_jac.data
        errors = N.absolute(a_jac - f_jac)
        errors = N.divide(errors, N.maximum(N.maximum(abs(a_jac), abs(f_jac)),1))
        
        if len(errors) > 0:
            data_max = errors.max()
        else:
            data_max = 0
        
        if data_max < tol_check:
            return True
        else:
            print 'Check of Jacobian' , comp_matrix ,' failed, max error: ', data_max
            print '==== Analytical matrix ===='
            print a_jacPrint
            print '=== Finitie diff matrix ==='
            print f_jacPrint
            return False
            
    def basic_initialize_test(self, cname, fname, compiler_options={'generate_ode_jacobian':True}, tol_check=1e-3, A=True, B=True, C=True, D=True):
        fn = compile_fmu(cname, fname, compiler_options=compiler_options, version="2.0")
        m = load_fmu(fn)
        m.set_debug_logging(True)
        m.setup_experiment()
        m.initialize()
        self.check_jacobian(m, tol_check=tol_check,  A=A, B=B, C=C, D=D)

class Test_FMI_Jacobians_operators(Test_FMI_Jacobians_base):
    
    """
    Test for arithmetic operators, as listed in section 3.4 of the Modelica specification 3.2. 3.2
    """

    def setUp(self):    
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
        

    @testattr(stddist = True)
    def test_addition(self):
        cname = "JacGenTests.JacTestAdd"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    
    @testattr(stddist = True)
    def test_substraction(self):
        cname = "JacGenTests.JacTestSub"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 

    
    @testattr(stddist = True)
    def test_multiplication(self):
        cname = "JacGenTests.JacTestMult"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 

    @testattr(stddist = True)
    def test_division(self):
        cname = "JacGenTests.JacTestDiv"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
    
    
    @testattr(stddist = True)
    def test_exponentiation(self):
        cname = "JacGenTests.JacTestPow"
        try:
            compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
            self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)
        except:
            raise Exception

    
class Test_FMI_Jacobians_functions(Test_FMI_Jacobians_base):
    """
    This class tests the elemenary functions that Jmodelica.org has implemented according to
    Petter Lindhomlms thesis "Efficient implementation of Jacobians using automatic differentiation", p. 35
    """


    def setUp(self):    
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_abs1(self):
        cname = "JacGenTests.JacTestAbs1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 

    @testattr(stddist = True)
    def test_min(self):
        cname = "JacGenTests.JacTestMin"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)    

    @testattr(stddist = True)
    def test_max(self):
        cname = "JacGenTests.JacTestMax"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
        
    @testattr(stddist = True)
    def test_sqrt(self):
        cname = "JacGenTests.JacTestSqrt"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)    
        
    @testattr(stddist = True)
    def test_sin(self):
        cname = "JacGenTests.JacTestSin"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    
    @testattr(stddist = True)
    def test_cos(self):
        cname = "JacGenTests.JacTestCos"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
    
    @testattr(stddist = True)
    def test_tan(self): 
        cname = "JacGenTests.JacTestTan"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
    
    @testattr(stddist = True)
    def test_Cotan(self):   
        cname = "JacGenTests.JacTestCoTan"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)   

    @testattr(stddist = True)
    def test_asin(self):    
        cname = "JacGenTests.JacTestAsin"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    
    @testattr(stddist = True)
    def test_acos(self):    
        cname = "JacGenTests.JacTestAcos"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
    
    @testattr(stddist = True)
    def test_atan(self):    
        cname = "JacGenTests.JacTestAtan"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
        
        
    @testattr(stddist = True)
    def test_atan2(self):       
        cname = "JacGenTests.JacTestAtan2"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
        
    @testattr(stddist = True)
    def test_sinh(self):    
        cname = "JacGenTests.JacTestSinh"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
        
    @testattr(stddist = True)
    def test_cosh(self):    
        cname = "JacGenTests.JacTestCosh"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  

        
    @testattr(stddist = True)
    def test_tanh(self):    
        cname = "JacGenTests.JacTestTanh"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  

    
    @testattr(stddist = True)
    def test_exp(self): 
        cname = "JacGenTests.JacTestExp"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  

    
    @testattr(stddist = True)
    def test_log(self):
        cname = "JacGenTests.JacTestLog"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, tol_check=1e-2)  

    
    @testattr(stddist = True)
    def test_log10(self):
        cname = "JacGenTests.JacTestLog10"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, tol_check=1e-2) 

    
    @testattr(stddist = True)
    def test_smooth(self):
        cname = "JacGenTests.SmoothTest1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        #No derivatives in model
        self.basic_initialize_test(cname, self.fname, compiler_options, A=False, B=False, C=False, D=False) 

    
    @testattr(stddist = True)
    def test_not(self):
        cname = "JacGenTests.NotTest1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        #No derivatives in model
        self.basic_initialize_test(cname, self.fname, compiler_options, A=False, B=False, C=False, D=False)  
    
    
class Test_FMI_Jacobians_Whencases(Test_FMI_Jacobians_base):
    
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
    
    """
    #Raises compliance error: "Else clauses in when equations are currently not supported". 
    #Even if generate_ode_jacobian is set to false. 
    @testattr(stddist = True)
    def test_whenElse(self):
        cname = "JacGenTests.JacTestWhenElse"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    """
    
    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
     Raises compliance error: "Else clauses in when equations are currently not supported". 
    Even if generate_ode_jacobian is set to false. 
    @testattr(stddist = True)
    def test_whenSimple(self):
        cname = "JacGenTests.JacTestWhenSimple"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
    @testattr(stddist = True)
    def test_whenPre(self):
        cname = "JacGenTests.JacTestWhenPre"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.    
    @testattr(stddist = True)
    def test_whenFunction(self):
        cname = "JacGenTests.JacTestWhenFunction"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    """

    """
    Raises: CcodeCompilationError: 
    Message: Compilation of generated C code failed.
    @testattr(stddist = True)
    def test_whenSample(self):
        cname = "JacGenTests.JacTestWhenSample"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options) 
    """
    
class Test_FMI_Jacobians_Ifcases(Test_FMI_Jacobians_base):
    
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_IfExpression1(self):
        cname = "JacGenTests.JacTestIfExpression1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, A=True, B=False, C=False, D=False)  
        
    @testattr(stddist = True)
    def test_IfExpression2(self):
        cname = "JacGenTests.JacTestIfExpression2"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, A=True, B=False, C=False, D=False) 
    

    @testattr(stddist = True)
    def test_IfExpression3(self):
        cname = "JacGenTests.JacTestIfExpression3"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, A=True, B=False, C=False, D=False) 

    @testattr(stddist = True)
    def test_IfExpressionSim1(self):
        cname = "JacGenTests.JacTestIfExpression3"
        fn = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.set_debug_logging(True)
        m.setup_experiment()
        m.initialize()
        self.check_jacobian(m, A=True, B=False, C=False, D=False)
        m.event_update()
        m.enter_continuous_time_mode()
        m.simulate(final_time=2, options={'initialize':False})
        self.check_jacobian(m, A=True, B=False, C=False, D=False)
        m.simulate(final_time=4, options={'initialize':False})
        self.check_jacobian(m, A=True, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_IfEquation1(self):
        pass
        """
        #Disabled the test temporary, see https://trac.jmodelica.org/ticket/4612  
        
        cname = "JacGenTests.JacTestIfEquation1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  
        """

    @testattr(stddist = True)
    def test_IfEquation2(self):
        cname = "JacGenTests.JacTestIfEquation2"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options)  

    @testattr(stddist = True)
    def test_IfEquationSimNested(self):
        cname = "JacGenTests.JacTestIfEquation3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.set_debug_logging(True)
        m.setup_experiment()
        m.initialize()
        self.check_jacobian(m, A=True, B=True, C=True, D=False)
        m.event_update()
        m.enter_continuous_time_mode()
        m.simulate(final_time=2, options={'initialize':False})
        self.check_jacobian(m, A=True, B=True, C=True, D=False)
        
    @testattr(stddist = True)
    def test_IfEquation4(self):
        cname = "JacGenTests.JacTestIfEquation4"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, A=True, B=False, C=False, D=False)   

##
##Raised the following error
##CcodeCompilationError: 
##Message: Compilation of generated C code failed.
##  @testattr(stddist = True)
##  def test_IfFunctionRecord(self):
##      cname = "JacGenTests.JacTestIfFunctionRecord"
##      fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
##      'eliminate_alias_variables':False}, version="2.0")
##      m = load_fmu(fn)
##      m.set_debug_logging(True)
##      m.setup_experiment(m)
##      self.check_jacobian(m)      

class Test_FMI_Jacobians_Functions(Test_FMI_Jacobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_Function1(self):
        cname = "JacGenTests.JacTestFunction1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options,  B=False, C=False, D=False)  


    @testattr(stddist = True)
    def test_Function2(self):
        cname = "JacGenTests.JacTestFunction2"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)  


    @testattr(stddist = True)
    def test_Function3(self):
        cname = "JacGenTests.JacTestFunction3"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options,  B=False, C=False, D=False)  

    @testattr(stddist = True)
    def test_Function4(self):
        cname = "JacGenTests.JacTestFunction4"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)            
    
    @testattr(stddist = True)
    def test_Function5(self):
        cname = "JacGenTests.JacTestFunction5"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)  


    @testattr(stddist = True)
    def test_Function6(self):
        cname = "JacGenTests.JacTestFunction6"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options,  B=False, C=False, D=False)  

    @testattr(stddist = True)
    def test_Function7(self):
        cname = "JacGenTests.JacTestFunction7"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        #No derivatives in model, does not work with get state space
        self.basic_initialize_test(cname, self.fname, compiler_options, A=False, B=False, C=False, D=False)  
        
    @testattr(stddist = True)
    def test_JacTestExpInFuncArg1(self):
        cname = "JacGenTests.JacTestExpInFuncArg1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_DiscreteFunction1(self):
        cname = "JacGenTests.JacTestDiscreteFunction1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, B=False, C=False, D=False)  

class Test_FMI_Jacobians_Simulation(Test_FMI_Jacobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_FunctionSim1(self):
        cname = "JacGenTests.JacTestFunction1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment()
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m, B=False, C=False, D=False)
        m.simulate(final_time=5, options={'initialize':False})
        self.check_jacobian(m, B=False, C=False, D=False)


    @testattr(stddist = True)
    def test_FunctionSim2(self):
        cname = "JacGenTests.JacTestFunction3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment()
        m.set_debug_logging(True)
        m.initialize()
        m.event_update()
        m.enter_continuous_time_mode()
        m.simulate(final_time=5, options={'initialize':False})
        self.check_jacobian(m, B=False, C=False, D=False)           


class Test_FMI_Jacobians_Unsolved_blocks(Test_FMI_Jacobians_base):
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

    @testattr(stddist = True)
    def test_Unsolved_blocks1(self):
        cname = "JacGenTests.Unsolved_blocks1"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_Unsolved_blocks2(self):
        cname = "JacGenTests.Unsolved_blocks2"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m)

    @testattr(stddist = True)
    def test_Unsolved_blocks3(self):
        cname = "JacGenTests.Unsolved_blocks3"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_Unsolved_blocks4(self):
        cname = "JacGenTests.Unsolved_blocks4"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_Unsolved_blocks5(self):
        cname = "JacGenTests.Unsolved_blocks5"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m, B=False, C=False, D=False)

    @testattr(stddist = True)
    def test_Unsolved_blocks6(self):
        cname = "JacGenTests.Unsolved_blocks6"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,\
          'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment()
        m.initialize()
        self.check_jacobian(m, tol_check=1e-5, B=False, C=False, D=False)  

    @testattr(stddist = True)
    def test_Unsolved_blocks_torn_1(self):
        cname = "JacGenTests.Unsolved_blocks_torn_1"
        fn = compile_fmu(cname,self.fname,compiler_options={'automatic_tearing':True,
            'equation_sorting':True,'eliminate_alias_variables':False,
            'generate_ode_jacobian':True}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        self.check_jacobian(m)

    @testattr(stddist = True)
    def test_Unsolved_blocks_torn_2(self):
        cname = "JacGenTests.Unsolved_blocks_torn_2"
        fn = compile_fmu(cname,self.fname,compiler_options={'automatic_tearing':True,
            'equation_sorting':True,'eliminate_alias_variables':False,
            'generate_ode_jacobian':True}, version="2.0")
        m = load_fmu(fn)
        m.setup_experiment(tolerance=1e-11)
        m.set_debug_logging(True)
        m.initialize()
        # Test not working, nan are returned from directional derivatives
        #self.check_jacobian(m)      
        
    # Test not working when run in test suite. Works when run seperately. Commented out for now.
    #@testattr(stddist = True)
    #def test_local_loop_1(self):
        #cname = "TearingTests.TearingTest1"
        #fn = compile_fmu(cname,os.path.join(path_to_mofiles,'TearingTests.mo'),compiler_options={'automatic_tearing':True,
            #'equation_sorting':True,'eliminate_alias_variables':False,
            #'generate_ode_jacobian':True, "local_iteration_in_tearing":"all"},version="2.0")
        #m = FMUModel2(fn)
        #m.set_debug_logging(True)
        #m.initialize(relativeTolerance=1e-11)
        #m.setup_experiment()
        #self.check_jacobian(m)       
        
class Test_FMI_Jacobians_Miscellaneous(Test_FMI_Jacobians_base):

    def setUp(self):
        self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


    @testattr(stddist = True)
    def test_Input(self):
        cname = "JacGenTests.JacTestInput"
        fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True, \
        'eliminate_alias_variables':False}, version="2.0")
        m = load_fmu(fn)
        m.set_debug_logging(True)
        m.setup_experiment()
        m.initialize()
        self.check_jacobian(m, A=True, B=True, C=False, D=False)
        t = N.linspace(0.,5.0,100) 
        u_traj = N.transpose(N.vstack((t,t)))
        input_object = ('u', u_traj)
        m.event_update()
        m.enter_continuous_time_mode()
        m.simulate(final_time = 10, options={'initialize':False}, input = input_object)
        self.check_jacobian(m, A=True, B=True, C=False, D=False)
    
    #Fails in Linux, needs to be investigated
    #@testattr(stddist = True)
    #def test_Record1(self):
        #self.basic_initialize_test("JacGenTests.JacTestRecord1", self.fname)
        
    @testattr(stddist = True)
    def test_Array1(self):
        cname = "JacGenTests.JacTestArray1"
        compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False}
        self.basic_initialize_test(cname, self.fname, compiler_options, A=True, B=False, C=False, D=False)     
        
class Test_ODE_JACOBIANS1(Test_FMI_Jacobians_base):       
        
    def setUp(self):
        self.fname = os.path.join(path_to_mofiles, 'furuta.mo')

    @testattr(stddist = True)
    def test_ode_simulation_furuta(self): 
        cname='Furuta'
        _fn_furuta = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True}, version="2.0")
        m_furuta = load_fmu(_fn_furuta)
        
        print "Starting simulation"
        
        opts = m_furuta.simulate_options()
        opts['with_jacobian'] = True
        res = m_furuta.simulate(final_time=100, options=opts)
    
        self.check_jacobian(m_furuta)
        
        opts['with_jacobian'] = False
        opts['initialize'] = False
        res = m_furuta.simulate(final_time=100, options=opts)
        
        self.check_jacobian(m_furuta)

class Test_ODE_JACOBIANS2(Test_FMI_Jacobians_base):
     
        
    def setUp(self):
        self.fname = os.path.join(get_files_path(), 'Modelica', 'NonLinear.mo')

    @testattr(stddist = True)
    def test_ode_simulation_NonLinear(self):
        cname='NonLinear.MultiSystems'
        _fn_nonlin = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True,'automatic_tearing':False}, version="2.0")
        """
        #Disabled the test temporary, see https://trac.jmodelica.org/ticket/4612 
        m_nonlin = load_fmu(_fn_nonlin)
        
        m_nonlin.initialize()
        
        self.check_jacobian(m_nonlin)
        """
        
        
class Test_ODE_JACOBIANS3(Test_FMI_Jacobians_base):
            
    def setUp(self):
        self.fname = os.path.join(get_files_path(), 'Modelica', 'DISTLib.mo')
    
    @testattr(stddist = True)
    def test_ode_simulation_distlib(self): 
        cname='DISTLib.Examples.Simulation'
        _fn_distlib = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True}, version="2.0")
        m_distlib1 = load_fmu(_fn_distlib)
        m_distlib2 = load_fmu(_fn_distlib)
        
        opts = m_distlib1.simulate_options()
        opts['with_jacobian'] = True
        
        res = m_distlib1.simulate(final_time=70, options=opts)
        res = m_distlib2.simulate(final_time=70)
        
        self.check_jacobian(m_distlib1, A=True, B=False, C=False, D=False)

        self.check_jacobian(m_distlib2, A=True, B=False, C=False, D=False)
        
 
class Test_ODE_JACOBIANS4(Test_FMI_Jacobians_base):
        
    def setUp(self):
        self.fname = os.path.join(get_files_path(), 'Modelica', 'NonLinearIO.mo')       
        
    @testattr(stddist = True)
    def test_ode_simulation_NonLinearIO(self):
        cname='NonLinear.TwoSystems_wIO'
        fn_nonlinIO = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'automatic_tearing':False}, version="2.0")
        m_nonlinIO = load_fmu('NonLinear_TwoSystems_wIO.fmu')
        
        m_nonlinIO.set('u', 1)
        m_nonlinIO.set('u1', 10000)
        m_nonlinIO.set('u2', 1)
        m_nonlinIO.set('u3', 10000)
        m_nonlinIO.setup_experiment()
        m_nonlinIO.initialize()
        
        self.check_jacobian(m_nonlinIO)
        
        
class Test_ODE_JACOBIANS5(Test_FMI_Jacobians_base):
      
    def setUp(self):
        self.fname = os.path.join(get_files_path(), 'Modelica', 'BlockOdeJacTest.mo')
    
    @testattr(stddist = True)
    def test_ode_simulation_distlib(self):
        cname='BlockOdeJacTest'

        _fn_block = compile_fmu(cname, self.fname, compiler_options={'generate_ode_jacobian':True, 'automatic_tearing':False}, version="2.0")
        pass #THIS NEEDS TO BE FIXED SEE TICKET 3430
        """
        m_block = load_fmu('BlockOdeJacTest.fmu')
        m_block.initialize()
        
        self.check_jacobians(m_block)
        """
