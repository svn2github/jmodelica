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
Module for testing external function support.
"""
import os, subprocess, shutil
from os.path import join as path

import nose

from pymodelica import compile_fmu
from pymodelica.common.core import get_platform_dir, create_temp_dir
from pyfmi import load_fmu
from pyfmi.fmi import FMUException
from tests_jmodelica import testattr, get_files_path
from tests_jmodelica.general.base_simul import *
from assimulo.solvers.sundials import CVodeError

path_to_mofiles = os.path.join(get_files_path(), 'Modelica')

class TestExternalStatic:

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def test_ExtFuncStatic(self):
        """ 
        Test compiling a model with external functions in a static library.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest1"
        fmu_name = compile_fmu(cpath, TestExternalStatic.fpath)
        model = load_fmu(fmu_name)
    
    @testattr(stddist = True)
    def test_IntegerArrays(self):
        """
        Test a model with external functions containing integer array and literal inputs.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest4"
        fmu_name = compile_fmu(cpath, TestExternalStatic.fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(fmu_name)
        res = model.simulate()
        
        nose.tools.assert_equals(res.final('myResult[1]'), 2) 
        nose.tools.assert_equals(res.final('myResult[2]'), 4)
        nose.tools.assert_equals(res.final('myResult[3]'), 6)
        
class TestUtilities:
    
    @testattr(stddist = True)
    def test_ModelicaUtilities(self):
        """ 
        Test compiling a model with external functions using the functions in ModelicaUtilities.
        """
        fpath = path(get_files_path(), 'Modelica', "ExtFunctionTests.mo")
        cpath = "ExtFunctionTests.ExtFunctionTest3"
        jmu_name = compile_fmu(cpath, fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(jmu_name)
        #model.simulate()

class TestExternalShared:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtFuncShared(self):
        """ 
        Test compiling a model with external functions in a shared library. Simple.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest1"
        fmu_name = compile_fmu(cpath, TestExternalShared.fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('c'), 3) 
        
    @testattr(stddist = True)
    def test_ExtFuncSharedCeval(self):
        """ 
        Test compiling a model with external functions in a shared library. Constant evaluation during compilation.
        """
        cpath = "ExtFunctionTests.ExtFunctionTest1"
        fmu_name = compile_fmu(cpath, TestExternalShared.fpath, compiler_options={'variability_propagation':True})
        model = load_fmu(fmu_name)
        nose.tools.assert_equals(model.get('c'), 3)

class TestExternalBool:
    
    @classmethod
    def setUpClass(self):
        """
        Sets up the test class.
        """
        self.cpath = "ExtFunctionTests.ExtFunctionBool"
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtFuncBool(self):
        """ 
        Test compiling a model with external functions in a shared library. Boolean arrays.
        """
        fmu_name = compile_fmu(self.cpath, self.fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(fmu_name)
        model.simulate()
        trueInd  = {1,2,3,5,8}
        falseInd = {4,6,7}
        for i in trueInd:
            assert(model.get('res[' + str(i) + ']'))
        for i in falseInd:
            assert(not model.get('res[' + str(i) + ']'))

class TestExternalShared2:
    
    @classmethod
    def setUpClass(self):
        """
        Sets up the test class.
        """
        self.cpath = "ExtFunctionTests.ExtFunctionTest2"
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtFuncShared(self):
        """ 
        Test compiling a model with external functions in a shared library. Real, Integer, and Boolean arrays.
        Compare results between constant evaluation and simulation.
        """
        fmu_name = compile_fmu(self.cpath, self.fpath, compiler_options={'variability_propagation':True})
        model = load_fmu(fmu_name)
        s_ceval = model.get('s')
        res = model.simulate()
        s_sim1 = res.final('s')
        
        fmu_name = compile_fmu(self.cpath, self.fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(fmu_name)
        res = model.simulate()
        s_sim2 = res.final('s')
        nose.tools.assert_equals(s_sim1, s_sim2)
        
class TestExternalInf:
    
    @classmethod
    def setUpClass(self):
        """
        Sets up the test class. Check timeout of infinite loop during constant evaluation.
        """
        self.cpath = "ExtFunctionTests.ExternalInfinityTest"
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtFuncShared(self):
        """ 
        Test compiling a model with external functions in a shared library. Infinite loop.
        """
        fmu_name = compile_fmu(self.cpath, self.fpath)
        
        
class TestExternalObject:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtObjectDestructor(self):
        """ 
        Test compiling a model with external object functions in a static library.
        """
        cpath = 'ExtFunctionTests.ExternalObjectTests1'
        fmu_name = compile_fmu(cpath, TestExternalObject.fpath)
        model = load_fmu(fmu_name)
        model.simulate()
        model.terminate()
        if (os.path.exists('test_ext_object.marker')):
             os.remove('test_ext_object.marker')
        else:
            assert False, 'External object destructor not called.'
            
class TestExternalObject2:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
        
    @testattr(stddist = True)
    def test_ExtObjectDestructor(self):
        """ 
        Test compiling a model with external object functions in a static library.
        """
        cpath = 'ExtFunctionTests.ExternalObjectTests2'
        fmu_name = compile_fmu(cpath, TestExternalObject2.fpath)
        model = load_fmu(fmu_name)
        model.simulate()
        model.terminate()
        if (os.path.exists('test_ext_object_array1.marker') and os.path.exists('test_ext_object_array2.marker')):
             os.remove('test_ext_object_array1.marker')
             os.remove('test_ext_object_array2.marker')
        else:
            assert False, 'External object destructor not called.'
            
class TestAssertEqu1(SimulationTest):
    '''Test assert in equation without event'''
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertEqu1')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist = True)
    def test_simulate(self):
        try:
            self.run(cvode_options={"minh":1e-15})
            assert False, 'Simulation not stopped by failed assertions'
        except CVodeError, e:
            self.assert_equals('Simulation stopped at wrong time', e.t, 2.0)
    
class TestAssertEqu2(SimulationTest):
    '''Test assert in equation with event'''
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertEqu2')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist = True)
    def test_simulate(self):
        try:
            self.run()
            assert False, 'Simulation not stopped by failed assertions'
        except FMUException, e:
            self.assert_equals('Simulation stopped at wrong time', self.model.time, 2.0)
    
     
class TestAssertFunc(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertFunc')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist = True)
    def test_simulate(self):
        try:
            self.run(cvode_options={"minh":1e-15})
            assert False, 'Simulation not stopped by failed assertions'
        except CVodeError, e:
            self.assert_equals('Simulation stopped at wrong time', e.t, 2.0)

     
class TestTerminateWhen(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.TerminateWhen')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(final_time=3)
        self.run()

    @testattr(stddist = True)
    def test_end_values(self):
        self.assert_end_value('time', 2.0)
        self.assert_end_value('x', 2.0)

     
class TestModelicaError:
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath = path(path_to_mofiles, 'Asserts.mo')
        
    @testattr(stddist = True)
    def test_simulate(self):
        cpath = 'Asserts.ModelicaError'
        fmu_name = compile_fmu(cpath, TestModelicaError.fpath)
        model = load_fmu(fmu_name)
        try:
            model.simulate(final_time = 3, options={"CVode_options":{"minh":1e-15}})
            assert False, 'Simulation not stopped by calls to ModelicaError()'
        except CVodeError, e:
            assert abs(e.t - 2.0) < 0.01, 'Simulation stopped at wrong time'
        
        
class TestCBasic:
    '''
    Test basic external C functions.
    '''
    @classmethod
    def setUpClass(self):
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def testCEvalReal(self):
        '''
        Constant evaluation of basic external C function with Reals.
        '''
        cpath = "ExtFunctionTests.CEval.C.RealTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), 3*3.14)
        nose.tools.assert_equals(res.final('xArray[2]'), 4)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), 6)
        
    @testattr(stddist = True)
    def testCEvalInteger(self):
        '''
        Constant evaluation of basic external C function with Integers.
        '''
        cpath = "ExtFunctionTests.CEval.C.IntegerTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), 9)
        nose.tools.assert_equals(res.final('xArray[2]'), 4)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), 6)
    
    @testattr(stddist = True)
    def testCEvalBoolean(self):
        '''
        Constant evaluation of basic external C function with Booleans.
        '''
        cpath = "ExtFunctionTests.CEval.C.BooleanTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), False)
        nose.tools.assert_equals(res.final('xArray[2]'), True)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), False)
    
    @testattr(stddist = True)
    def test_ExtFuncString(self):
        cpath = "ExtFunctionTests.CEval.C.StringTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        #TODO: enable when model.get_string implemented
        #nose.tools.assert_equals(model.get('xScalar'), 'dcb')
        #nose.tools.assert_equals(model.get('xArray[2]'), 'dbf')
        #nose.tools.assert_equals(model.get('xArrayUnknown[2]'), 'dbf')
    
    @testattr(stddist = True)
    def testCEvalEnum(self):
        '''
        Constant evaluation of basic external C function with Enums.
        '''
        cpath = "ExtFunctionTests.CEval.C.EnumTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(model.get('xScalar'), 2)
        nose.tools.assert_equals(model.get('xArray[2]'), 2)
        nose.tools.assert_equals(model.get('xArrayUnknown[2]'), 1)
        
    @testattr(stddist = True)
    def testCEvalShortClass(self):
        '''
        Constant evaluation of function modified by short class decl
        '''
        cpath = "ExtFunctionTests.CEval.C.ShortClass"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        resConst = model.simulate()
        nose.tools.assert_almost_equal(resConst.final('a1'), 10*3.14)
        
class TestFortranBasic:
    '''
    Test basic external fortran functions.
    '''
    @classmethod
    def setUpClass(self):
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def testCEvalReal(self):
        '''
        Constant evaluation of basic external fortran function with Reals.
        '''
        cpath = "ExtFunctionTests.CEval.Fortran.RealTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), 3*3.14)
        nose.tools.assert_equals(res.final('xArray[2]'), 4)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), 6)
        
    @testattr(stddist = True)
    def testCEvalInteger(self):
        '''
        Constant evaluation of basic external fortran function with Integers.
        '''
        cpath = "ExtFunctionTests.CEval.Fortran.IntegerTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), 9)
        nose.tools.assert_equals(res.final('xArray[2]'), 4)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), 6)
    
    @testattr(stddist = True)
    def testCEvalBoolean(self):
        '''
        Constant evaluation of basic external fortran function with Booleans.
        '''
        cpath = "ExtFunctionTests.CEval.Fortran.BooleanTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('xScalar'), False)
        nose.tools.assert_equals(res.final('xArray[2]'), True)
        nose.tools.assert_equals(res.final('xArrayUnknown[2]'), False)
    
    @testattr(stddist = True)
    def testCEvalEnum(self):
        '''
        Constant evaluation of basic external fortran function with Enums.
        '''
        cpath = "ExtFunctionTests.CEval.Fortran.EnumTest"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(model.get('xScalar'), 2)
        nose.tools.assert_equals(model.get('xArray[2]'), 2)
        nose.tools.assert_equals(model.get('xArrayUnknown[2]'), 1)
        
class TestAdvanced:
    '''
    Test advanced external fortran functions.
    '''
    @classmethod
    def setUpClass(self):
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def testDGELSX(self):
        '''
        A test using the external fortran function dgelsx from lapack.
        Compares simulation results with constant evaluation results.
        '''
        cpath = "ExtFunctionTests.CEval.Advanced.DgelsxTest"
        fmu_name = compile_fmu(cpath, self.fpath, compiler_options={'variability_propagation':False})
        model = load_fmu(fmu_name)
        resSim = model.simulate()
        fmu_name = compile_fmu(cpath, self.fpath, compiler_options={'variability_propagation':True})
        model = load_fmu(fmu_name)
        resConst = model.simulate()
        for i in range(1,4):
          for j in range(1,4):
            x = 'out[{0},{1}]'.format(i,j)
            nose.tools.assert_almost_equals(resSim.final(x), resConst.final(x), places=13)
        nose.tools.assert_equals(resSim.final('a'), resConst.final('a'))
        nose.tools.assert_equals(resSim.final('b'), resConst.final('b'))
        
    @testattr(stddist = True)
    def testExtObjScalar(self):
        '''
        Test constant evaluation of a simple external object.
        '''
        cpath = "ExtFunctionTests.CEval.Advanced.ExtObjTest1"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        resConst = model.simulate()
        nose.tools.assert_equals(resConst.final('x'), 6.13)
        
    @testattr(stddist = True)
    def testExtObjArrays(self):
        '''
        Test constant evaluation of arrays of external objects.
        '''
        cpath = "ExtFunctionTests.CEval.Advanced.ExtObjTest2"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        resConst = model.simulate()
        nose.tools.assert_equals(resConst.final('x'), 13.27)
        
    @testattr(stddist = True)
    def testExtObjRecursive(self):
        '''
        Test constant evaluation of external object encapsulating 
        external objects.
        '''
        cpath = "ExtFunctionTests.CEval.Advanced.ExtObjTest3"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        resConst = model.simulate()
        nose.tools.assert_equals(resConst.final('x'), 32.67)
    
    @testattr(stddist = True)
    def testExtObjRecursive(self):
        '''
        Test failing of partial constant evaluation on external function
        '''
        cpath = "ExtFunctionTests.CEval.Advanced.UnknownInput"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        assert model.get_variable_variability("y") == 3, 'y should be continuous'
        
        
    
class TestUtilitiesCEval:
    '''
    Test utility functions in external C functions.
    '''
    @classmethod
    def setUpClass(self):
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def testCEvalLog(self):
        '''
        Constant evaluation of external C logging function.
        '''
        cpath = "ExtFunctionTests.CEval.Utility.LogTest"
        fmu_name = compile_fmu(cpath, self.fpath, compiler_log_level="w:tmp.log")
        logfile = open('tmp.log')
        count = 0
        for line in logfile:
            if line == "ModelicaMessage: <msg:X is a bit high: 1.100000.>\n" or line == "ModelicaError: <msg:X is too high: 2.100000.>\n":
                count = count + 1
        logfile.close()
        os.remove(logfile.name);
        assert(count >= 2)

class TestCevalCaching:
    '''
    Test caching of external objects during constant evaluation
    '''
    @classmethod
    def setUpClass(self):
        self.fpath = path(path_to_mofiles, "ExtFunctionTests.mo")
    
    @testattr(stddist = True)
    def testCaching1(self):
        '''
        Test caching of external objects during constant evaluation
        '''
        cpath = "ExtFunctionTests.CEval.Caching.CacheExtObj"
        fmu_name = compile_fmu(cpath, self.fpath)
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('n3'), 5)
        
    @testattr(stddist = True)
    def testCaching2(self):
        '''
        Test caching process limit of external objects during constant evaluation
        '''
        cpath = "ExtFunctionTests.CEval.Caching.CacheExtObjLimit"
        fmu_name = compile_fmu(cpath, self.fpath, compiler_options={'external_constant_evaluation_max_proc':2})
        model = load_fmu(fmu_name)
        res = model.simulate()
        nose.tools.assert_equals(res.final('n3'), 20)
        
    @testattr(stddist = True)
    def testConError(self):
        '''
        Test caching of external objects during constant evaluation, ModelicaError in constructor.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.ConError"
        fmu_name = compile_fmu(cpath, self.fpath)
        
    @testattr(stddist = True)
    def testDeconError(self):
        '''
        Test caching of external objects during constant evaluation, ModelicaError in deconstructor.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.DeconError"
        fmu_name = compile_fmu(cpath, self.fpath)
        
    @testattr(stddist = True)
    def testUseError(self):
        '''
        Test caching of external objects during constant evaluation, ModelicaError in use.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.UseError"
        fmu_name = compile_fmu(cpath, self.fpath)
        
        
    @testattr(stddist = True)
    def testConCrash(self):
        '''
        Test caching of external objects during constant evaluation, Crash in constructor.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.ConCrash"
        fmu_name = compile_fmu(cpath, self.fpath)
        
    @testattr(stddist = True)
    def testDeconCrash(self):
        '''
        Test caching of external objects during constant evaluation, Crash in deconstructor.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.DeconCrash"
        fmu_name = compile_fmu(cpath, self.fpath)
        
    @testattr(stddist = True)
    def testUseCrash(self):
        '''
        Test caching of external objects during constant evaluation, Crash in use.
        '''
        cpath = "ExtFunctionTests.CEval.Caching.UseCrash"
        fmu_name = compile_fmu(cpath, self.fpath)
        
