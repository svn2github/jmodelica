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

from jmodelica.tests import testattr
from jmodelica.tests import get_files_path
from jmodelica.compiler import ModelicaCompiler
from jmodelica.compiler import OptimicaCompiler
import jmodelica as jm


mc = ModelicaCompiler()
ModelicaCompiler.set_log_level(ModelicaCompiler.LOG_ERROR)
mc.set_boolean_option('state_start_values_fixed',True)

oc = OptimicaCompiler()
OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
oc.set_boolean_option('state_start_values_fixed',True)

jm_home = jm.environ['JMODELICA_HOME']

class Test_Compiler:
    """ This class tests the compiler module. """
    
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
        self.fpath_mc = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack_no_opt.mo')
        self.cpath_mc = "Pendulum_pack.Pendulum"

        self.fpath_oc = os.path.join(get_files_path(), 'Modelica', 'Pendulum_pack.mop')
        self.cpath_oc = "Pendulum_pack.Pendulum_Opt"

    @testattr(stddist = True)
    def test_compile(self):
        """
        Test that compilation is possible with compiler 
        and that all obligatory files are created. 
        """

        # detect platform specific shared library file extension
        suffix = ''
        if sys.platform == 'win32':
            suffix = '.dll'
        elif sys.platform == 'darwin':
            suffix = '.dylib'
        else:
            suffix = '.so'
            
        mc.compile_model(self.cpath_mc, self.fpath_mc)
        
        fname = self.cpath_mc.replace('.','_',1)
        assert os.access(fname+'.xml',os.F_OK) == True, \
               fname+'.xml'+" was not created."
        
        assert os.access(fname+'_values.xml', os.F_OK) == True, \
               fname+'_values.xml'+" was not created."
        
        assert os.access(fname+'.c', os.F_OK) == True, \
               fname+'.c'+" was not created."        
        
        assert os.access(fname+suffix, os.F_OK) == True, \
               fname+suffix+" was not created."

    @testattr(stddist = True)
    def test_optimica_compile(self):
        """
        Test that compilation is possible with optimicacompiler
        and that all obligatory files are created. 
        """
    
        # detect platform specific shared library file extension
        suffix = ''
        if sys.platform == 'win32':
            suffix = '.dll'
        elif sys.platform == 'darwin':
            suffix = '.dylib'
        else:
            suffix = '.so'
            
        oc.compile_model(self.cpath_oc, self.fpath_oc)
        
        fname = self.cpath_oc.replace('.','_',1)
        assert os.access(fname+'.xml',os.F_OK) == True, \
               fname+'.xml'+" was not created."
        
        assert os.access(fname+'_values.xml', os.F_OK) == True, \
               fname+'_values.xml'+" was not created."
            
        assert os.access(fname+'.c', os.F_OK) == True, \
               fname+'.c'+" was not created."        
        
        assert os.access(fname+suffix, os.F_OK) == True, \
               fname+suffix+" was not created."
               
    @testattr(stddist = True)
    def test_compile_wtarget_alg(self):
        """ Test that it is possible to compile (compiler.py) with target algorithms. """
        mc.compile_model(self.cpath_mc, self.fpath_mc, target='algorithms')
    
    @testattr(stddist = True)
    def test_optimica_compile_wtarget_alg(self):
        """ Test that it is possible to compile (optimicacompiler.py) with target algorithms. """
        oc.compile_model(self.cpath_oc, self.fpath_oc, target='algorithms')

    @testattr(ipopt = True)
    def test_compile_wtarget_ipopt(self):
        """ Test that it is possible to compile (compiler.py) with target ipopt. """
        mc.compile_model(self.cpath_mc, self.fpath_mc, target='ipopt')

    @testattr(ipopt = True)
    def test_optimica_compile_wtarget_ipopt(self):
        """ Test that it is possible to compile (optimicacompiler.py) with target ipopt. """
        oc.compile_model(self.cpath_oc, self.fpath_oc, target='ipopt')

    @testattr(stddist = True)
    def test_stepbystep(self):
        """ Test that it is possible to compile (compiler.py) step-by-step. """
        sourceroot = mc.parse_model(self.fpath_mc)
        icd = mc.instantiate_model(sourceroot, self.cpath_mc)
        fclass = mc.flatten_model(icd)
        mc.compile_binary(self.cpath_mc.replace('.','_',1))

    @testattr(stddist = True)
    def test_optimica_stepbystep(self):
        """ Test that it is possible to compile (optimicacompiler.py) step-by-step. """
        sourceroot = oc.parse_model(self.fpath_oc)
        icd = oc.instantiate_model(sourceroot, self.cpath_oc)
        fclass = oc.flatten_model(icd)
        oc.compile_binary(self.cpath_oc.replace('.','_',1))

    @testattr(stddist = True)
    def test_compiler_error(self):
        """ Test that a CompilerError is raised if compilation errors are found in the model."""
        path = os.path.join(get_files_path(), 'Modelica','CorruptCodeGenTests.mo')
        cl = 'CorruptCodeGenTests.CorruptTest1'
        nose.tools.assert_raises(jm.compiler.CompilerError, mc.compile_model, cl, path)
        nose.tools.assert_raises(jm.compiler.CompilerError, oc.compile_model, cl, path)

    @testattr(stddist = True)
    def test_class_not_found_error(self):
        """ Test that a ModelicaClassNotFoundError is raised if model class is not found. """
        errorcl = 'NonExisting.Class'
        nose.tools.assert_raises(jm.compiler.ModelicaClassNotFoundError, mc.compile_model, errorcl, self.fpath_mc)
        nose.tools.assert_raises(jm.compiler.OptimicaClassNotFoundError, oc.compile_model, errorcl, self.fpath_oc)

    @testattr(stddist = True)
    def test_IO_error(self):
        """ Test that an IOError is raised if the model file is not found. """          
        errorpath = os.path.join(get_files_path(), 'Modelica','NonExistingModel.mo')
        nose.tools.assert_raises(IOError, mc.compile_model, self.cpath_mc, errorpath)
        nose.tools.assert_raises(IOError, oc.compile_model, self.cpath_oc, errorpath)

    @testattr(stddist = True)
    def test_setget_modelicapath(self):
        """ Test modelicapath setter and getter. """
        newpath = os.path.join(jm_home,'ThirdParty','MSL')
        mc.set_modelicapath(newpath)
        nose.tools.assert_equal(mc.get_modelicapath(),newpath)
        nose.tools.assert_equal(oc.get_modelicapath(),newpath)
    

    @testattr(stddist = True)
    def test_setget_XML_tpl(self):
        """ Test XML template setter and getter. """
        newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmodelica_model_description.tpl')
        mc.set_XML_tpl(newtemplate)
        nose.tools.assert_equal(mc.get_XML_tpl(), newtemplate)
    
#@testattr(stddist = True)
#def test_setget_XMLTemplate():
#    """ Test XML template setter and getter. """
#    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_variables_template.xml')
#    oc.set_XMLVariablesTemplate(newtemplate)
#    nose.tools.assert_equal(oc.get_XMLVariablesTemplate(), newtemplate)
    
    @testattr(stddist = True)
    def test_setget_XML_values_tpl(self):
        """ Test XML values template setter and getter. """
        newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmodelica_model_values.tpl')
        mc.set_XML_values_tpl(newtemplate)
        nose.tools.assert_equal(mc.get_XML_values_tpl(), newtemplate)

#@testattr(stddist = True)
#def test_setget_XMLValuesTemplate():
#    """ Test XML values template setter and getter. """
#    newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_modelica_values_template.xml')
#    oc.set_XMLValuesTemplate(newtemplate)
#    nose.tools.assert_equal(oc.get_XMLValuesTemplate(), newtemplate)
    
    @testattr(stddist = True)
    def test_setget_cTemplate(self):
        """ Test c template setter and getter. """
        newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_modelica_template.c')
        mc.set_cTemplate(newtemplate)
        nose.tools.assert_equal(mc.get_cTemplate(), newtemplate)

    @testattr(stddist = True)
    def test_setget_cTemplate(self):
        """ Test c template setter and getter. """
        newtemplate = os.path.join(jm_home, 'CodeGenTemplates','jmi_optimica_template.c')
        oc.set_cTemplate(newtemplate)
        nose.tools.assert_equal(oc.get_cTemplate(), newtemplate)

    @testattr(stddist = True)
    def test_parse_multiple(self):
        """ Test that it is possible to parse two model files. """
        lib = os.path.join(get_files_path(), 'Modelica','CSTRLib.mo')
        opt = os.path.join(get_files_path(), 'Modelica','CSTR2_Opt.mo')
        oc.parse_model([lib, opt])

    @testattr(stddist = True)
    def test_compile_multiple(self):
        """ Test that it is possible to compile two model files. """
        lib = os.path.join(get_files_path(), 'Modelica','CSTRLib.mo')
        opt = os.path.join(get_files_path(), 'Modelica','CSTR2_Opt.mo')
        oc.compile_model('CSTR2_Opt', [lib,opt])

    @testattr(stddist = True)
    def test_setget_boolean_option(self):
        """ Test boolean option setter and getter. """
        option = 'halt_on_warning'
        value = mc.get_boolean_option(option)
        # change value of option
        mc.set_boolean_option(option, not value)
        nose.tools.assert_equal(mc.get_boolean_option(option), not value)
        # option should be of type bool
        assert isinstance(mc.get_boolean_option(option), bool)
        # reset to original value
        mc.set_boolean_option(option, value)
    
    @testattr(stddist = True)
    def test_setget_boolean_option_error(self):
        """ Test that boolean option getter raises the proper error. """
        option = 'nonexist_boolean'
        #try to get an unknown option
        nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_boolean_option, option)

# There are no integer options yet
#    @testattr(stddist = True)
#    def test_setget_integer_option(self):
#        """ Test integer option setter and getter. """
#        option = 'integer_testoption'
#        setvalue = 10
#        # create new option
#        mc.set_integer_option(option, setvalue)
#        nose.tools.assert_equal(mc.get_integer_option(option), setvalue)
#        # change value of option
#        setvalue = 100
#        mc.set_integer_option(option, setvalue)
#        nose.tools.assert_equal(mc.get_integer_option(option), setvalue)
#        # option should be of type int
#        assert isinstance(mc.get_integer_option(option),int)
    
    @testattr(stddist = True)
    def test_setget_integer_option_error(self):
        """ Test that integer option getter raises the proper error. """
        option = 'nonexist_integer'
        #try to get an unknown option
        nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_integer_option, option) 

# There are no real options yet
#    @testattr(stddist = True)
#    def test_setget_real_option(self):
#        """ Test real option setter and getter. """
#        option = 'real_testoption'
#        setvalue = 10.0
#        # create new option
#        mc.set_real_option(option, setvalue)
#        nose.tools.assert_equal(mc.get_real_option(option), setvalue)
#        # change value of option
#        setvalue = 100.0
#        mc.set_real_option(option, setvalue)
#        nose.tools.assert_equal(mc.get_real_option(option), setvalue)
#        # option should be of type float
#        assert isinstance(mc.get_real_option(option),float)
    
    @testattr(stddist = True)
    def test_setget_real_option_error(self):
        """ Test that real option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_real_option, option)

    @testattr(stddist = True)
    def test_setget_string_option(self):
        """ Test string option setter and getter. """
        option = 'extra_lib_dirs'
        value = mc.get_string_option(option)
        setvalue = 'option 1'
        # change value of option
        mc.set_string_option(option, setvalue)
        nose.tools.assert_equal(mc.get_string_option(option), setvalue)
        # option should be of type str
        assert isinstance(mc.get_string_option(option),str)
        # reset to original value
        mc.set_string_option(option, value)
    
    @testattr(stddist = True)
    def test_setget_string_option_error(self):
        """ Test that string option getter raises the proper error. """
        option = 'nonexist_real'
        #try to get an unknown option
        nose.tools.assert_raises(jm.compiler.UnknownOptionError, mc.get_string_option, option)

    @testattr(ipopt = True)
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
            oc.compile_model(cpath, fpath, target='ipopt')
        except:
            comp_res = 0
    
        assert comp_res==1, "Compilation failed in test_MODELICAPATH"
    
