#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2011 Modelon AB
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

#from distutils.core import setup, Extension
from distutils.ccompiler import new_compiler
from distutils.command.build_clib import build_clib
import distutils
import os as O
from numpy.distutils.misc_util import Configuration
from numpy.distutils.core import setup

NAME = "PyFMI"
AUTHOR = "Modelon AB"
AUTHOR_EMAIL = ""
VERSION = "1.0b1"
LICENSE = "GPL"
URL = "http://www.jmodelica.org"
DOWNLOAD_URL = "http://www.jmodelica.org/page/12"
DESCRIPTION = "A package for working with dynamic models compliant with the Functional Mock-Up Interface standard."
PLATFORMS = ["Linux", "Windows", "MacOS X"]
CLASSIFIERS = [ 'Programming Language :: Python',
                'Operating System :: MacOS :: MacOS X',
                'Operating System :: Microsoft :: Windows',
                'Operating System :: Unix']

LONG_DESCRIPTION = """
PyFMI is a package for loading and interacting with Functional Mock-Up 
Units (FMUs), which are compiled dynamic models compliant with the 
Functional Mock-Up Interface (FMI), see 
http://www.functional-mockup-interface.org/ for more information.

FMI is a standard that enables tool independent exchange of dynamic 
models on binary format. Several industrial simulation platforms 
supports export of FMUs, including, Dymola, JModelica.org, OpenModelica 
and SimulationX, see http://www.functional-mockup-interface.org/tools 
for a complete list. PyFMI offers a Python interface for interacting 
with FMUs and enables for example loading of FMU models, setting of 
model parameters and evaluation of model equations.

PyFMI is available as a stand-alone package or as part of the 
JModelica.org distribution. Using PyFMI together with the Python 
simulation package Assimulo adds industrial grade simulation 
capabilities of FMUs to Python.
"""

#Hack for compiling a C-file which is not an Extension
#distutils.log.set_verbosity(1)

#comp = new_compiler(compiler="mingw32",verbose=1)
#comp.verbose=10
#obj = comp.compile(['pyfmi'+O.path.sep+'util'+O.path.sep+'FMILogger.c'])
#comp.link(comp.SHARED_LIBRARY,obj,"FMILogger")

config = Configuration()
config.add_installed_library("FMILogger",sources=['pyfmi'+O.path.sep+'util'+O.path.sep+'FMILogger.c'],install_dir='pyfmi')

setup(name=NAME,
      version=VERSION,
      license=LICENSE,
      description=DESCRIPTION,
      long_description=LONG_DESCRIPTION,
      author=AUTHOR,
      author_email=AUTHOR_EMAIL,
      url=URL,
      download_url=DOWNLOAD_URL,
      platforms=PLATFORMS,
      classifiers=CLASSIFIERS,
      #cmdclass={"build_ext":build_clib},
      package_dir = {'pyfmi':'pyfmi','pyfmi.common':'common'},
      packages=['pyfmi','pyfmi.simulation','pyfmi.examples','pyfmi.common','pyfmi.common.plotting'],
      package_data = {'pyfmi':['examples'+O.path.sep+'files'+O.path.sep+'FMUs'+O.path.sep+'*']},
      **config.todict()
      )
#ext_modules=[Extension('pyfmi.util', ['pyfmi'+O.path.sep+'util'+O.path.sep+'FMILogger.c'])]
