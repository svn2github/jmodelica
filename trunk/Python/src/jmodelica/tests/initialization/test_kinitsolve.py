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

""" Tests the jmi wrappers for the KinitSolve solver module. """

import os.path

import numpy as N
import nose.tools

import scipy.sparse as ss

from jmodelica.jmi import compile_jmu
from jmodelica.jmi import JMUModel
from jmodelica.jmi import JMIException

from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from assimulo.kinsol import KINSOL, KINSOL_Exception
from jmodelica.initialization.assimulo_interface import JMUAlgebraic, JMUAlgebraic_Exception

int = N.int32
N.int = N.int32

class TestKInitSolve:
    """ Test evaluation of function in NLPInitialization and solution
    of initialization problems.
    
    """
    @classmethod
    def setUpClass(cls):
        """Sets up the test class."""
        # Compile the stationary initialization model into a JMU
        fpath = os.path.join(get_files_path(), 'Modelica', 'CSTRLib.mo')
        compile_jmu("CSTRLib.Components.Two_CSTRs_stat_init", fpath)
        
    
    def setUp(self):
        """Test setUp. Load the test model."""
        # Load model
        self.model = JMUModel("CSTRLib_Components_Two_CSTRs_stat_init.jmu")
        self.problem = JMUAlgebraic(self.model)
        self.solver = KINSOL(self.problem)
        
        # Set inputs for Stationary point A
        u1_0_A = 1
        u2_0_A = 1
        self.model.set('u1',u1_0_A)
        self.model.set('u2',u2_0_A)
        
        self.dx0 = N.zeros(6)
        self.x0 = N.array([200., 3.57359316e-02, 446.471014, 100., 1.79867213e-03,453.258466])
        self.w0 = N.array([100., 100., -48.1909])
    
    @testattr(assimulo = True)
    def test_inits(self):
        """
        test if solver is correctly initialized
        """
        nose.tools.assert_true(self.solver._use_jac)
        nose.tools.assert_equals(self.problem._neqF0,15)
        nose.tools.assert_equals(self.problem._dx_size,6)
        nose.tools.assert_equals(self.problem._x_size,6)
        nose.tools.assert_equals(self.problem._w_size,3)
        nose.tools.assert_equals(self.problem._mark,12)
    
    @testattr(assimulo = True)  
    def test_jac_settings(self):
        """
        test if user can set usage of jacobian
        """
        self.solver.set_jac_usage(True)
        nose.tools.assert_true(self.solver._use_jac)
        self.solver.set_jac_usage(False)
        nose.tools.assert_false(self.solver._use_jac)
        self.solver.set_jac_usage(True)
        
        # test bad cases
        nose.tools.assert_raises(KINSOL_Exception,self.solver.set_jac_usage,2)
        nose.tools.assert_raises(KINSOL_Exception,self.solver.set_jac_usage,'a')
        nose.tools.assert_raises(KINSOL_Exception,self.solver.set_jac_usage,None)
        nose.tools.assert_raises(KINSOL_Exception,self.solver.set_jac_usage,[True,False])
        nose.tools.assert_raises(KINSOL_Exception,self.solver.set_jac_usage,N.array([True,False]))
        
        
    @testattr(assimulo = True)   
    def test_constraint_settings(self):
        """
        test if user can set usage of constraints
        """
        const = N.ones(self.problem._neqF0)
        # test boolean settings
        self.problem.set_constraints_usage(True)
        nose.tools.assert_true(self.problem.use_constraints)
        self.problem.set_constraints_usage(False)
        nose.tools.assert_false(self.problem.use_constraints)
 
        
        # test if constraints can be set properly
        self.problem.set_constraints_usage(True,const)
        nose.tools.assert_true(self.problem.use_constraints)

        res1 = const == self.problem.constraints

        for r1 in res1:
            nose.tools.assert_true(r1)

        self.problem.set_constraints_usage(False,const)
        nose.tools.assert_false(self.problem.use_constraints)
        res1 = const == self.problem.constraints
        for r1 in res1:
            nose.tools.assert_true(r1)

        # test if constraints resets
        self.problem.set_constraints_usage(False)
        nose.tools.assert_true(self.problem.constraints == None)
        
        self.problem.set_constraints_usage(True,const)
        self.problem.set_constraints_usage(True)
        nose.tools.assert_true(self.problem.constraints == None)
        
        #test bad input
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,2)
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,'a')
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,None)
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,[True,False])
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,N.array([True,False]))
        
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,False,2)
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,False,'a')
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,False,True)
        nose.tools.assert_raises(JMUAlgebraic_Exception, self.problem.set_constraints_usage,False,[5.,6.])
        
    @testattr(assimulo = True)
    def test_initialize(self):
        """
        test if the initialize function works
        """
        
        self.solver.set_jac_usage(True)
        self.solver.solve()
        
        dx = self.model.real_dx
        x = self.model.real_x
        w = self.model.real_w
        
        # Test equalities
        for pre,calced in zip(self.dx0,dx):
            nose.tools.assert_almost_equal(pre,calced,6)
            
        for pre,calced in zip(self.x0,x):
            nose.tools.assert_almost_equal(pre,calced,6)
            
        for pre,calced in zip(self.w0,w):
            nose.tools.assert_almost_equal(pre,calced,6)
            
    @testattr(assimulo = True)
    def test_sparse_jac(self):
        """
        Test if the sparse jacobian works
        """
        
        # calculate jacobians at given 'point' input
        input = N.zeros(15)
        input[0:6]   = self.dx0
        input[6:12]  = self.x0
        input[12:15] = self.w0
        
        jac_dense = self.problem.jac(input)
        jac_sparse = self.problem.sparse_jac(input)
        
        # check the format of the sparse jacoban
        type_name = type(jac_sparse).__name__
        nose.tools.assert_equals(type_name,'coo_matrix')
        
        jac_sparse = N.array(jac_sparse.todense())
        """
        print "dense: \n",jac_dense
        print "sparse: \n", jac_sparse.todense()
        """
        # check if it is the same result as the dense jacobian 
        i = 0
        j = 0
        for d_col, sp_col in zip(jac_dense,jac_sparse):
            
            for dense,sparse in zip(d_col,sp_col):
                nose.tools.assert_almost_equal(dense,sparse,6)
                
                j += 1
                
            j = 0
            i += 1
