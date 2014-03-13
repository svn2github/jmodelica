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
from tests_jmodelica import testattr, get_files_path
from tests_jmodelica.general.base_simul import *
from assimulo.solvers.sundials import CVodeError

class TestExternalStatic:

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.dir = build_ext('add_static', 'ExtFunctionTests.mo')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalStatic.dir, True)
    
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
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        pass
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
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
        cls.dir = build_ext('add_shared', 'ExtFunctionTests.mo')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
        
    def setUp(self):
        """
        Sets up the test case.
        """
        pass
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalShared.dir, True)
        
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
        self.dir = build_ext('array_shared', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        """
        Cleans up after test class.
        """
        shutil.rmtree(self.dir, True)
        
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
        self.dir = build_ext('array_shared', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        """
        Cleans up after test class.
        """
        shutil.rmtree(self.dir, True)
        
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
        self.dir = build_ext('array_shared', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        """
        Cleans up after test class.
        """
        shutil.rmtree(self.dir, True)
        
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
        cls.dir = build_ext('ext_objects', 'ExtFunctionTests.mo')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalObject.dir, True)
        
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
        cls.dir = build_ext('ext_objects', 'ExtFunctionTests.mo')
        cls.fpath = path(cls.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestExternalObject2.dir, True)
        
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
            
class TestAssertEqu(SimulationTest):
    
    @classmethod
    def setUpClass(cls):
        SimulationTest.setup_class_base(
            'Asserts.mo',
            'Asserts.AssertEqu')

    @testattr(stddist = True)
    def setUp(self):
        self.setup_base(final_time=3)
        
    @testattr(stddist = True)
    def test_simulate(self):
        try:
            self.run()
            assert False, 'Simulation not stopped by failed assertions'
        except CVodeError, e:
            self.assert_equals('Simulation stopped at wrong time', e.t, 2.0)

     
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
            self.run()
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
        cls.dir = build_ext('use_modelica_error', 'Asserts.mo')
        cls.fpath = path(cls.dir, 'Asserts.mo')
    
    @classmethod
    def tearDownClass(cls):
        """
        Cleans up after test class.
        """
        shutil.rmtree(TestModelicaError.dir, True)
        
    @testattr(stddist = True)
    def test_simulate(self):
        cpath = 'Asserts.ModelicaError'
        fmu_name = compile_fmu(cpath, TestModelicaError.fpath)
        model = load_fmu(fmu_name)
        try:
            model.simulate(final_time = 3)
            assert False, 'Simulation not stopped by calls to ModelicaError()'
        except CVodeError, e:
            assert abs(e.t - 2.0) < 0.01, 'Simulation stopped at wrong time'
        
        
class TestCBasic:
    '''
    Test basic external C functions.
    '''
    @classmethod
    def setUpClass(self):
        self.dir = build_ext('basic_static_c', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        shutil.rmtree(self.dir, True)
    
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
        
class TestFortranBasic:
    '''
    Test basic external fortran functions.
    '''
    @classmethod
    def setUpClass(self):
        self.dir = build_ext('basic_static_f', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        shutil.rmtree(self.dir, True)
    
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
        
        
class TestUtilities:
    '''
    Test utility functions in external C functions.
    '''
    @classmethod
    def setUpClass(self):
        self.dir = build_ext('use_modelica_error', 'ExtFunctionTests.mo')
        self.fpath = path(self.dir, "ExtFunctionTests.mo")
    
    @classmethod
    def tearDownClass(self):
        shutil.rmtree(self.dir, True)
    
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
        nose.tools.assert_equals(count, 2)
        
def build_ext(target, mofile):
    """
    Build a library for an external function.
    """
    platform = get_platform_dir()
    if platform[:-2] == 'win':
        bin = path(os.environ['MINGW_HOME'],'bin')
        make = '%s CC=%s AR=%s' % (path(bin,'mingw32-make'), path(bin,'gcc'), path(bin,'ar'))
        cmd = "gnumake Makefile "+target
    else:
        make = 'make'
        cmd = '%s PLATFORM=%s clean %s' % (make, platform, target)
    
    src = path(get_files_path(), 'Modelica')
    dst = create_temp_dir()
    shutil.copytree(path(src, 'Resources'), path(dst, 'Resources'))
    shutil.copy(path(src, mofile), dst)
    old = os.getcwd()
    os.chdir(path(dst, 'Resources', 'src'))
    subprocess.call(cmd, shell=True)
    os.chdir(old)
    
    return dst
