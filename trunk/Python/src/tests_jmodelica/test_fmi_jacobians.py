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
from pyfmi.fmi import FMUModel2
from tests_jmodelica import testattr, get_files_path
from pyfmi.common.core import get_platform_dir
path_to_mofiles = os.path.join(get_files_path(), 'Modelica')



class Test_FMI_Jaobians_Elementary_operators:
	
	"""
	Test for arithmetic operators, as listed in section 3.4 of the Modelica specification 3.2. 3.2
	"""

	def setUp(self):	
		self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
		

	@testattr(stddist = True)
	def test_elementary_addition(self):
		cname = "JacGenTests.JacTestAdd"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
		
	
	@testattr(stddist = True)
	def test_elementary_substraction(self):
		cname = "JacGenTests.JacTestSub"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	
	@testattr(stddist = True)
	def test_elementary_multiplication(self):
		cname = "JacGenTests.JacTestMult"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	@testattr(stddist = True)
	def test_elementary_division(self):
		cname = "JacGenTests.JacTestDiv"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	
	@testattr(stddist = True)
	def test_elementary_exponentiation(self):
		cname = "JacGenTests.JacTestPow"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	
class Test_FMI_Jaobians_Elementary_functions:
	"""
	This class tests the elemenary functions that Jmodelica.org has implemented according to
	Petter Lindhomlms thesis "Efficient implementation of Jacobians using automatic differentiation", p. 35
	"""


	def setUp(self):	
		self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")

	"""
	Fails in the check_jacobians test. This is not surprising however, since the abs function has en undefined derivative in the origin. 
	The choice has been made to treat the derivative of abs as:
	der(abs(x)) = -1 if x < 0 else 1, thus the finite difference will say that derivative is
	zero at the origin and the AD-code that it's 1. 
	@testattr(stddist = True)
	def test_elementary_abs1(self):
		cname = "JacGenTests.JacTestAbs1"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""
	@testattr(stddist = True)
	def test_elementary_abs2(self):
		cname = "JacGenTests.JacTestAbs2"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	@testattr(stddist = True)
	def test_elementary_sqrt(self):
		cname = "JacGenTests.JacTestSqrt"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 	
		
	@testattr(stddist = True)
	def test_elementary_sin(self):
		cname = "JacGenTests.JacTestSin"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	@testattr(stddist = True)
	def test_elementary_cos(self):
		cname = "JacGenTests.JacTestCos"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	@testattr(stddist = True)
	def test_elementary_tan(self):	
		cname = "JacGenTests.JacTestTan"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	@testattr(stddist = True)
	def test_elementary_Cotan(self):	
		cname = "JacGenTests.JacTestCoTan"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 	

	@testattr(stddist = True)
	def test_elementary_asin(self):	
		cname = "JacGenTests.JacTestAsin"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	@testattr(stddist = True)
	def test_elementary_acos(self):	
		cname = "JacGenTests.JacTestAcos"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	@testattr(stddist = True)
	def test_elementary_atan(self):	
		cname = "JacGenTests.JacTestAtan"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
		
		
	@testattr(stddist = True)
	def test_elementary_atan2(self):		
		cname = "JacGenTests.JacTestAtan2"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
		
	@testattr(stddist = True)
	def test_elementary_sinh(self):	
		cname = "JacGenTests.JacTestSinh"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
		
	@testattr(stddist = True)
	def test_elementary_cosh(self):	
		cname = "JacGenTests.JacTestCosh"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

		
	@testattr(stddist = True)
	def test_elementary_tanh(self):	
		cname = "JacGenTests.JacTestTanh"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	
	@testattr(stddist = True)
	def test_elementary_exp(self):	
		cname = "JacGenTests.JacTestExp"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	
	@testattr(stddist = True)
	def test_elementary_log(self):
		cname = "JacGenTests.JacTestLog"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	
	@testattr(stddist = True)
	def test_elementary_log10(self):
		cname = "JacGenTests.JacTestLog10"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	
class Test_FMI_Jaobians_Whencases:
	
	def setUp(self):
		self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")
	
	"""
	#Raises compliance error: "Else clauses in when equations are currently not supported". 
	#Even if generate_ode_jacobian is set to false. 
	@testattr(stddist = True)
	def test_elementary_whenElse(self):
		cname = "JacGenTests.JacTestWhenElse"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':False,'eliminate_alias_variables':False,'fmi_version':2.0})
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
	def test_elementary_whenSimple(self):
		cname = "JacGenTests.JacTestWhenSimple"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	"""
	Raises: CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	@testattr(stddist = True)
	def test_elementary_whenPre(self):
		cname = "JacGenTests.JacTestWhenPre"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	"""
	Raises: CcodeCompilationError: 
	Message: Compilation of generated C code failed.	
	@testattr(stddist = True)
	def test_elementary_whenFunction(self):
		cname = "JacGenTests.JacTestWhenFunction"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	"""
	Raises: CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	@testattr(stddist = True)
	def test_elementary_whenSample(self):
		cname = "JacGenTests.JacTestWhenSample"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	
	
class Test_FMI_Jaobians_Ifcases:
	
	def setUp(self):
		self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


	@testattr(stddist = True)
	def test_elementary_IfExpression1(self):
		cname = "JacGenTests.JacTestIfExpression1"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
		
	"""
	This on raises a compiler error even though I think it's legal
	@testattr(stddist = True)
	def test_elementary_IfExpression2(self):
		cname = "JacGenTests.JacTestIfExpression2"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	
	#This one doesn't really test anything, the ODE jacobians are empty. I don't know how to
	#rewrite it in such a way that it performs a sensible test, my attempts have resulted in
	#a singular system (more free variables than variables). At least it compiles. 
	@testattr(stddist = True)
	def test_elementary_IfExpression3(self):
		cname = "JacGenTests.JacTestIfExpression3"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		m.simulate(final_time=10);
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	
	
	@testattr(stddist = True)
	def test_elementary_IfEquation1(self):
		cname = "JacGenTests.JacTestIfEquation1"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	@testattr(stddist = True)
	def test_elementary_IfEquation2(self):
		cname = "JacGenTests.JacTestIfEquation2"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 

	@testattr(stddist = True)
	def test_elementary_IfFunctionRecord(self):
		cname = "JacGenTests.JacTestIfFunctionRecord"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 		

class Test_FMI_Jaobians_Functions:

	def setUp(self):
		self.fname = os.path.join(path_to_mofiles,"JacGenTests.mo")


	"""
	Raises: CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	@testattr(stddist = True)
	def test_elementary_Function1(self):
		cname = "JacGenTests.JacTestFunction1"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 
	"""

	"""
	Raises: CcodeCompilationError: 
	Message: Compilation of generated C code failed.
	@testattr(stddist = True)
	def test_elementary_Function2(self):
		cname = "JacGenTests.JacTestFunction2"
		fn = compile_fmu(cname,self.fname,compiler_options={'generate_ode_jacobian':True,'eliminate_alias_variables':False,'fmi_version':2.0})
		m = FMUModel2(fn)
		m.set_debug_logging(True)
		Afd,Bfd,Cfd,Dfd,n_errs= m.check_jacobians(delta_rel=1e-6,delta_abs=1e-3,tol=1e-5)
		assert n_errs ==0 	
	"""



