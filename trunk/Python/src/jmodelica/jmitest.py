#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Tests of the JMI interface Python wrappers.

Some of the tests require the JMI examples to be compiled. See README
for more information.
"""
#    Copyright (C) 2009 Modelon AB
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

import unittest
import ctypes
import os.path

from jmi import load_DLL, JMIException

class JMIModelTestCase:
    """A general test framework for JMI examples."""
    
    def loadDLL(self, relpath):
        """Load a test model in the JMI model example folder.
        
        @return A DLL loaded using ctypes.
        
        Raises a JMIException on failure.
        """
        try:
            dll = load_DLL('../../../build/JMI/examples/' \
                          + relpath)
        except JMIException, e:
            raise JMIException("%s\nUnable to load test models." \
                               " You have probably not compiled the" \
                               " examples. Please refer to the"
                               " JModelica for more information." % e)
                               
        return dll


class GenericCTypesJMITestCase(JMIModelTestCase):
    """
    Tests any JMI Model DLL to see that it conforms to the DLL API.
    
    Why not testing one model is because C++ name mangling might occur.
    Therefor tests should be run on both a C and a C++ compiled model to
    make sure that they are compiled with correct
    @code {
        extern "C" {
            ...
        }
    }
    .
    
    Which DLL is set in the 'file' attribute.
    """
    
    def setUp(self):
        self.dll = self.loadDLL(self.file)
        
    def testLoaded(self):
        assert(isinstance(self.dll, ctypes.CDLL), \
               "lib is not a CDLL instance")
        assert(isinstance(self.dll.jmi_new, ctypes._CFuncPtr), \
               "lib.jmi_new is not a ctypes._CFuncPtr instance")
            
    def testJMINew(self):
        jmip = ctypes.c_voidp()
        assert(self.dll.jmi_new(ctypes.byref(jmip)) == 0, \
               "jmi_new returned non-zero")
        assert(jmip.value is not None, \
               "jmi struct not returned correctly")


class CTypesVDPTestCase(GenericCTypesJMITestCase, unittest.TestCase):
    """Test loading Van der Pol JMI model DLL directly with ctypes."""
    
    def setUp(self):
        self.file = 'Vdp/vdp'
        GenericCTypesJMITestCase.setUp(self)


class CTypesVDPADTestCase(GenericCTypesJMITestCase, unittest.TestCase):
    """
    Test loading Van der Pol JMI model DLL (compiled with CPPAD)
    directly with ctypes.
    
    """
    
    def setUp(self):
        self.file = 'Vdp_cppad/vdp_cppad'
        GenericCTypesJMITestCase.setUp(self)


# run all tests when module is executed from command line
if __name__ == "__main__":
    unittest.main()
