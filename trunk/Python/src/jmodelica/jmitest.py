#!/usr/bin/python
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

from jmi import loadDLL, JMIException

# C++ demangling: http://www.kegel.com/mangle.html

class JMIModelTestCase(unittest.TestCase):
    """A general test framework for JMI examples."""
    
    def loadDLL(self, relpath):
        """Load a test model in the JMI model example folder."""
        try:
            dll = loadDLL('../../../build/JMI/examples/' \
                          + relpath)
        except JMIException, e:
            raise JMIException("%s\nUnable to load test models." \
                               " You have probably not compiled the" \
                               " examples. Please refer to the"
                               " JModelica for more information." % e)
                               
        return dll


class CTypesVDPTestCase(JMIModelTestCase):
    """Test loading jmi model dll directly with ctypes."""
    
    def setUp(self):
        self.lib = self.loadDLL('Vdp/vdp')
        
    def testLoaded(self):
        assert(isinstance(self.lib,ctypes.CDLL), \
               "lib is not a CDLL instance")
        assert(isinstance(self.lib.jmi_new,ctypes._CFuncPtr), \
               "lib.jmi_new is not a ctypes._CFuncPtr instance")
            
    def testJMINew(self):
        jmip = ctypes.c_voidp()
        assert(self.lib.jmi_new(ctypes.byref(jmip)) == 0, \
               "jmi_new returned non-zero")
        assert(jmip.value != None, \
               "jmi struct not returned correctly")


class CTypesVDPADTestCase(JMIModelTestCase):
    """Test loading jmi cppad model dll directly with ctypes."""
    
    def setUp(self):
        self.lib = self.loadDLL('Vdp_cppad/vdp_cppad')
        
    def testLoaded(self):
        assert(isinstance(self.lib,ctypes.CDLL), \
               "lib is not a CDLL instance")
        assert(isinstance(self.lib._Z7jmi_newPP5jmi_t, \
                          ctypes._CFuncPtr), \
               "lib.jmi_new is not a ctypes._CFuncPtr instance")


def suite():
    suite = unittest.TestSuite()
    suit.addTest(CTypesVDPTestCase("testLoaded"))
    suit.addTest(CTypesVDPADTestCase("testLoaded"))
    suit.addTest(CTypesVDPADTestCase("testJMINew"))
    return suite


# run all tests when module is executed from command line
if __name__ == "__main__":
    unittest.main()
