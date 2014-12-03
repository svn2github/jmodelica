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

""" Test module for testing the compiler module.
 
"""

import os, os.path
import sys

import nose
import nose.tools

from tests_jmodelica import testattr, get_files_path
from pymodelica.compiler_wrappers import ModelicaCompiler
from pymodelica.compiler_wrappers import OptimicaCompiler
from pymodelica import compile_jmu
from pymodelica import compile_fmu
import pymodelica as pym


class Test_Compiler:
    """ This class tests the compiler class. """
    
    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.mc = ModelicaCompiler()
        cls.oc = OptimicaCompiler()
        cls.jm_home = pym.environ['JMODELICA_HOME']        
        cls.fpath_mc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cls.cpath_mc = "Pendulum_pack.Pendulum"
        cls.fpath_oc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack.mop')
        cls.cpath_oc = "Pendulum_pack.Pendulum_Opt"
            
    @testattr(stddist = True)
    def test_compile_JMU(self):
        """
        Test that it is possible to compile a JMU from a .mo file with 
        ModelicaCompiler.
        """
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'jmu', None,  '.')
        
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.jmu',os.F_OK) == True, fname+'.jmu'+" was not created."
        os.remove(fname+'.jmu')

    @testattr(stddist = True)
    def test_optimica_compile_JMU(self):
        """
        Test that it is possible to compile a JMU from a .mop file with 
        OptimicaCompiler. 
        """     
        Test_Compiler.oc.compile_Unit(Test_Compiler.cpath_oc, [Test_Compiler.fpath_oc], 'jmu', None, '.')
        
        fname = Test_Compiler.cpath_oc.replace('.','_',1)
        assert os.access(fname+'.jmu',os.F_OK) == True, \
               fname+'.jmu'+" was not created."
        os.remove(fname+'.jmu')
    
    @testattr(stddist = True)
    def test_compile_FMUME10(self):
        """
        Test that it is possible to compile an FMU ME version 1.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me', '1.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')

    @testattr(stddist = True)
    def test_compile_FMUCS10(self):
        """
        Test that it is possible to compile an FMU CS version 1.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'cs', '1.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist = True)
    def test_compile_FMUME20(self):
        """
        Test that it is possible to compile an FMU ME version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist = True)
    def test_compile_FMUCS20(self):
        """
        Test that it is possible to compile an FMU CS version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'cs', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')
        
    @testattr(stddist = True)
    def test_compile_FMUMECS20(self):
        """
        Test that it is possible to compile an FMU MECS version 2.0 from a .mo 
        file with ModelicaCompiler.
        """ 
        Test_Compiler.mc.compile_Unit(Test_Compiler.cpath_mc, [Test_Compiler.fpath_mc], 'me+cs', '2.0', '.')
        fname = Test_Compiler.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.fmu',os.F_OK) == True, \
               fname+'.fmu'+" was not created."
        os.remove(fname+'.fmu')

    @testattr(stddist = True)
    def test_stepbystep(self):
        """ Test that it is possible to compile step-by-step with ModelicaCompiler. """
        target = Test_Compiler.mc.create_target_object("me", "1.0")
        sourceroot = Test_Compiler.mc.parse_model(Test_Compiler.fpath_mc)
        icd = Test_Compiler.mc.instantiate_model(sourceroot, Test_Compiler.cpath_mc, target)
        fclass = Test_Compiler.mc.flatten_model(icd, target)
        Test_Compiler.mc.generate_code(fclass, target)

    @testattr(stddist = True)
    def test_optimica_stepbystep(self):
        """ Test that it is possible to compile step-by-step with OptimicaCompiler. """
        target = Test_Compiler.oc.create_target_object("me", "1.0")
        sourceroot = Test_Compiler.oc.parse_model(Test_Compiler.fpath_oc)
        icd = Test_Compiler.oc.instantiate_model(sourceroot, Test_Compiler.cpath_oc, target)
        fclass = Test_Compiler.oc.flatten_model(icd, target)
        Test_Compiler.oc.generate_code(fclass, target)

    @testattr(stddist = True)
    def test_compiler_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the model."""
        path = os.path.join(get_files_path(), 'Modelica','CorruptCodeGenTests.mo')
        cl = 'CorruptCodeGenTests.CorruptTest1'
        nose.tools.assert_raises(pym.compiler_exceptions.CompilerError, Test_Compiler.mc.compile_Unit, cl, [path], 'jmu', None, '.')
        nose.tools.assert_raises(pym.compiler_exceptions.CompilerError, Test_Compiler.oc.compile_Unit, cl, [path], 'jmu', None, '.')

    '''
    @testattr(stddist = True)
    def test_class_not_found_error(self):
        """ Test that a ModelicaClassNotFoundError is raised if model class is not found. """
        errorcl = 'NonExisting.Class'
        nose.tools.assert_raises(pym.compiler_exceptions.ModelicaClassNotFoundError, Test_Compiler.mc.compile_JMU, errorcl, [self.fpath_mc], '.')
        nose.tools.assert_raises(pym.compiler_exceptions.ModelicaClassNotFoundError, Test_Compiler.oc.compile_JMU, errorcl, [self.fpath_oc], '.')
        nose.tools.assert_raises(pym.compiler_exceptions.ModelicaClassNotFoundError, pym.compile_fmu, errorcl, self.fpath_mc, separate_process=True)
        nose.tools.assert_raises(pym.compiler_exceptions.ModelicaClassNotFoundError, pym.compile_jmu, errorcl, self.fpath_oc, separate_process=True)

    @testattr(stddist = True)
    def test_IO_error(self):
        """ Test that an IOError is raised if the model file is not found. """
        errorpath = os.path.join(get_files_path(), 'Modelica','NonExistingModel.mo')
        nose.tools.assert_raises(IOError, Test_Compiler.mc.compile_JMU, Test_Compiler.cpath_mc, [errorpath], '.')
        nose.tools.assert_raises(IOError, Test_Compiler.oc.compile_JMU, Test_Compiler.cpath_oc, [errorpath], '.')
        nose.tools.assert_raises(IOError, pym.compile_fmu, Test_Compiler.cpath_mc, errorpath, separate_process=True)
        nose.tools.assert_raises(IOError, pym.compile_jmu, Test_Compiler.cpath_oc, errorpath, separate_process=True)
    '''
    @testattr(stddist = True)
    def test_setget_modelicapath(self):
        """ Test modelicapath setter and getter. """
        newpath = os.path.join(Test_Compiler.jm_home,'ThirdParty','MSL')
        Test_Compiler.mc.set_modelicapath(newpath)
        nose.tools.assert_equal(Test_Compiler.mc.get_modelicapath(),newpath)
        nose.tools.assert_equal(Test_Compiler.oc.get_modelicapath(),newpath)
    
    @testattr(stddist = True)
    def test_parse_multiple(self):
        """ Test that it is possible to parse two model files. """
        lib = os.path.join(get_files_path(), 'Modelica','CSTRLib.mo')
        opt = os.path.join(get_files_path(), 'Modelica','CSTR2_Opt.mo')
        Test_Compiler.oc.parse_model([lib, opt])

    @testattr(stddist = True)
    def test_compile_multiple(self):
        """ Test that it is possible to compile two model files. """
        lib = os.path.join(get_files_path(), 'Modelica','CSTRLib.mo')
        opt = os.path.join(get_files_path(), 'Modelica','CSTR2_Opt.mo')
        Test_Compiler.oc.compile_Unit('CSTR2_Opt', [lib,opt], 'jmu', None, '.')

    @testattr(stddist = True)
    def test_setget_boolean_option(self):
        """ Test boolean option setter and getter. """
        option = 'halt_on_warning'
        value = Test_Compiler.mc.get_boolean_option(option)
        # change value of option
        Test_Compiler.mc.set_boolean_option(option, not value)
        nose.tools.assert_equal(Test_Compiler.mc.get_boolean_option(option), not value)
        # option should be of type bool
        assert isinstance(Test_Compiler.mc.get_boolean_option(option), bool)
        # reset to original value
        Test_Compiler.mc.set_boolean_option(option, value)
    
    @testattr(stddist = True)
    def test_setget_boolean_option_error(self):
        """ Test that boolean option getter raises the proper error. """
        option = 'nonexist_boolean'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_boolean_option, option)

    @testattr(stddist = True)
    def test_setget_integer_option(self):
        """ Test integer option setter and getter. """
        option = 'log_level'
        default_value = Test_Compiler.mc.get_integer_option(option)
        new_value = 1
        # change value of option
        Test_Compiler.mc.set_integer_option(option, new_value)
        nose.tools.assert_equal(Test_Compiler.mc.get_integer_option(option), new_value)
        # option should be of type int
        assert isinstance(Test_Compiler.mc.get_integer_option(option),int)
        # reset to original value
        Test_Compiler.mc.set_integer_option(option, default_value)
    
    @testattr(stddist = True)
    def test_setget_integer_option_error(self):
        """ Test that integer option getter raises the proper error. """
        option = 'nonexist_integer'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_integer_option, option) 

    @testattr(stddist = True)
    def test_setget_real_option(self):
        """ Test real option setter and getter. """
        option = 'events_tol_factor'
        default_value = Test_Compiler.mc.get_real_option(option)
        new_value = 1.0e-5
        # change value of option
        Test_Compiler.mc.set_real_option(option, new_value)
        nose.tools.assert_equal(Test_Compiler.mc.get_real_option(option), new_value)
        # option should be of type int
        assert isinstance(Test_Compiler.mc.get_real_option(option),float)
        # reset to original value
        Test_Compiler.mc.set_real_option(option, default_value)
    
    @testattr(stddist = True)
    def test_setget_real_option_error(self):
        """ Test that real option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_real_option, option)

    @testattr(stddist = True)
    def test_setget_string_option(self):
        """ Test string option setter and getter. """
        option = 'extra_lib_dirs'
        default_value = Test_Compiler.mc.get_string_option(option)
        setvalue = 'option 1'
        # change value of option
        Test_Compiler.mc.set_string_option(option, setvalue)
        nose.tools.assert_equal(Test_Compiler.mc.get_string_option(option), setvalue)
        # option should be of type str
        assert isinstance(Test_Compiler.mc.get_string_option(option),basestring)
        # reset to original value
        Test_Compiler.mc.set_string_option(option, default_value)
    
    @testattr(stddist = True)
    def test_setget_string_option_error(self):
        """ Test that string option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(pym.compiler_exceptions.UnknownOptionError, Test_Compiler.mc.get_string_option, option)
            
    @testattr(stddist = True)
    def test_compile_no_mofile(self):
        """ 
        Test that compiling without mo-file (load class from libraries in 
        MODELICAPATH) works.
        """
        cpath = "Modelica.Electrical.Analog.Examples.CauerLowPassAnalog"
        Test_Compiler.mc.compile_Unit(cpath, [], 'jmu', None, '.')        
        fname = cpath.replace('.','_')
        assert os.access(fname+'.jmu',os.F_OK) == True, \
               fname+'.jmu'+" was not created."
        os.remove(fname+'.jmu')

    @testattr(stddist = True)
    def TO_ADDtest_MODELICAPATH(self):
        """ Test that the MODELICAPATH is loaded correctly.
    
        This test does currently not pass since changes of global
        environment variable MODELICAPATH does not take effect
        after OptimicaCompiler has been used a first time."""
    
        curr_dir = os.path.dirname(os.path.abspath(__file__));
        self.jm_home = os.environ['JMODELICA_HOME']
        model = os.path.join('files','Test_MODELICAPATH.mo')
        fpath = os.path.join(curr_dir,model)
        cpath = "Test_MODELICAPATH"
        fname = cpath.replace('.','_',1)
            
        pathElSep = ''
        if sys.platform == 'win32':
            pathElSep = ';'
        else:
            pathElSep = ':'
    
        modelica_path = os.environ['MODELICAPATH']
        os.environ['MODELICAPATH'] = os.environ['MODELICAPATH'] + pathElSep + \
                                     os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc1') + pathElSep + \
                                     os.path.join(curr_dir,'files','MODELICAPATH_test','LibLoc2')
    
        comp_res = 1
        try:
            oc.compile_model(cpath, fpath)
        except:
            comp_res = 0
    
        assert comp_res==1, "Compilation failed in test_MODELICAPATH"
        
class Test_Compiler_functions:
    """ This class tests the compiler functions. """

    @classmethod
    def setUpClass(cls):
        """
        Sets up the test class.
        """
        cls.fpath_mc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack_no_opt.mo')
        cls.cpath_mc = "Pendulum_pack.Pendulum"
        cls.fpath_oc = os.path.join(get_files_path(), 'Modelica', 
            'Pendulum_pack.mop')
        cls.cpath_oc = "Pendulum_pack.Pendulum_Opt"
    
    @testattr(stddist = True)
    def test_compile_fmu_illegal_target_error(self):
        """Test that an exception is raised when an incorrect target is given to compile_fmu"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        #Incorrect target.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="notValidTarget")
        #Incorrect target that contains the valid target 'me'.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="men") 
        #Incorrect version, correct target 'me'.
        nose.tools.assert_raises(pym.compiler_exceptions.IllegalCompilerArgumentError, pym.compile_fmu, cl, path, target="me", version="notValidVersion") 
               
    @testattr(stddist = True)
    def test_compile_fmu_mop(self):
        """
        Test that it is possible to compile an FMU from a .mop file with 
        pymodelica.compile_fmu.
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_oc, 
            separate_process=False)

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)

    @testattr(stddist = True)
    def test_compile_fmu_mop_separate_process(self):
        """
        Test that it is possible to compile an FMU from a .mop file with 
        pymodelica.compile_fmu using separate process.
        """
        fmuname = compile_fmu(Test_Compiler_functions.cpath_mc, Test_Compiler_functions.fpath_oc)

        assert os.access(fmuname, os.F_OK) == True, \
               fmuname+" was not created."
        os.remove(fmuname)
    
    @testattr(stddist = True)
    def test_compile_jmu(self):
        """
        Test that it is possible to compile a JMU from a .mop file with 
        pymodelica.compile_jmu.
        """
        jmuname = compile_jmu(Test_Compiler_functions.cpath_oc, Test_Compiler_functions.fpath_oc, 
            separate_process=False)

        assert os.access(jmuname, os.F_OK) == True, \
               jmuname+" was not created."
        os.remove(jmuname)
    
    @testattr(stddist = True)
    def test_compile_jmu_separate_process(self):
        """
        Test that it is possible to compile a JMU from a .mop file with 
        pymodelica.compile_jmu using separate process.
        """
        jmuname = compile_jmu(Test_Compiler_functions.cpath_oc, Test_Compiler_functions.fpath_oc)

        assert os.access(jmuname, os.F_OK) == True, \
               jmuname+" was not created."
        os.remove(jmuname)

    @testattr(stddist = True)
    def test_compiler_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the model."""
        path = os.path.join(get_files_path(), 'Modelica','CorruptCodeGenTests.mo')
        cl = 'CorruptCodeGenTests.CorruptTest1'
        nose.tools.assert_raises(pym.compiler_exceptions.CompilerError, pym.compile_fmu, cl, path)
        nose.tools.assert_raises(pym.compiler_exceptions.CompilerError, pym.compile_jmu, cl, path)
    
    @testattr(stddist = True)
    def test_compiler_modification_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the modification on the classname."""
        path = os.path.join(get_files_path(), 'Modelica','Diode.mo')
        err = pym.compiler_exceptions.CompilerError
        nose.tools.assert_raises(err, pym.compile_fmu, 'Diode(wrong_name=2)', path)
        nose.tools.assert_raises(err, pym.compile_fmu, 'Diode(===)', path)

    @testattr(windows = True)
    def test_compile_fmu_me_1_64bit(self):
        """Test that it is possible to compile an FMU-ME 1.0 64bit FMU on Windows"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        pym.compile_fmu(cl, path, platform='win64')

    @testattr(windows = True)
    def test_compile_fmu_me_2_64bit(self):
        """Test that it is possible to compile an FMU-ME 2.0 64bit FMU on Windows"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        pym.compile_fmu(cl, path, version='2.0', platform='win64')

    @testattr(windows = True)
    def test_compile_fmu_cs_1_64bit(self):
        """Test that it is possible to compile an FMU-CS 1.0 64bit FMU on Windows"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        pym.compile_fmu(cl, path, target='cs', platform='win64')

    @testattr(windows = True)
    def test_compile_fmu_cs_2_64bit(self):
        """Test that it is possible to compile an FMU-CS 2.0 64bit FMU on Windows"""
        cl = Test_Compiler_functions.cpath_mc 
        path = Test_Compiler_functions.fpath_mc
        pym.compile_fmu(cl, path, target='cs', version='2.0', platform='win64')

