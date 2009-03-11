#!/usr/bin/python
# -*- coding: utf-8 -*-
"""@todo: Add description.
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
import jmodelica.jmi
import ctypes
import os.path

# C++ demangling: http://www.kegel.com/mangle.html

class CTypesVDPTestCase(unittest.TestCase):
    """ Test loading jmi model dll directly with ctypes """
    def setUp(self):
        self.lib = ctypes.CDLL(os.path.join(os.path.split(__file__)[0],
                                            u'examples/vdp.dll'))
    def tearDown(self):
        pass
    def testLoaded(self):
        assert isinstance(self.lib,ctypes.CDLL), "lib is not a CDLL instance"
        assert isinstance(self.lib.jmi_new,ctypes._CFuncPtr), \
            "lib.jmi_new is not a ctypes._CFuncPtr instance"
    def testJMINew(self):
        jmip = ctypes.c_voidp()
        assert(self.lib.jmi_new(ctypes.byref(jmip)) == 0,"jmi_new returned non-zero")
        assert(jmip.value != None,"jmi struct not returned correctly")

class CTypesVDPADTestCase(unittest.TestCase):
    """ Test loading jmi cppad model dll directly with ctypes """
    def setUp(self):
        self.lib = ctypes.CDLL(os.path.join(os.path.split(__file__)[0],
                                            u'examples/vdp_cppad.dll'))
    def tearDown(self):
        pass
    def testLoaded(self):
        assert isinstance(self.lib,ctypes.CDLL), "lib is not a CDLL instance"
        assert isinstance(self.lib._Z7jmi_newPP5jmi_t,ctypes._CFuncPtr), \
            "lib.jmi_new is not a ctypes._CFuncPtr instance"

    
def suite():
    suite = unittest.TestSuite()
    suit.addTest(CTypesVDPTestCase("testLoaded"))
    suit.addTest(CTypesVDPADTestCase("testLoaded"))
    suit.addTest(CTypesVDPADTestCase("testJMINew"))
    return suite


# run all tests when module is executed from command line
if __name__ == "__main__":
    unittest.main()
    
