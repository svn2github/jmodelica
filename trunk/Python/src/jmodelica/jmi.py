# -*- coding: utf-8 -*-
"""Module containing the JMI interface Python wrappers.
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

# References:
#     http://www.python.org/doc/2.5.2/lib/module-ctypes.html
#     http://starship.python.net/crew/theller/ctypes/tutorial.html
#     http://www.scipy.org/Cookbook/Ctypes

import ctypes
import os.path


class JMIException(Exception):
    """ A JMI exception. """
    pass


def loadDLL(filepath):
    """Loads a model from a DLL file and returns it.
    
    The filepath can be be both with or without file suffixes (as long
    as standard file suffixes are used, that is).
    
    Example inputs that should work:
      >> lib = loadDLL('model')
      >> lib = loadDLL('model.dll')
      >> lib = loadDLL('model.so')
    . All of the above should work on the JModelica supported platforms.
    However, the first one is recommended as it is the least platform
    dependent syntax.
    
    @param filename File path without suffix.
    
    @see http://docs.python.org/library/ctypes.html
    
    """
    
    SUFFIXES_TO_APPEND = ['.so'] # Suffixes that might have to be added
    
    try:
        """Trying Windows DLL."""
        if os.path.isfile(filepath+'.dll'):
            lib = ctypes.CDLL(filepath)
            return lib
        
        filename = os.path.basename(filepath)
        (name, delimiter, suffix) = filename.rpartition('.')
        if suffix.lower() is 'dll' and os.path.isfile(filename):
            lib = ctypes.CDLL(filename)
            return lib
        
        """Trying different suffixes."""
        suffixed_files = map(lambda x: filepath+x, SUFFIXES_TO_APPEND)
        for suffixed_file in suffixed_files:
            if os.path.isfile(suffixed_file):
                lib = ctypes.CDLL(suffixed_file)
                return lib
        
        """Trying without suffix."""
        lib = ctypes.CDLL(filepath)
        return lib
                                          
    except OSError, e:
        raise JMIException("%s\nCould not load model." % e + \
                           " Please check that the" \
                           " file '%s'" % filename + \
                           " (with varying prefix) exists and is not" +
                           " corrupt.")
        
    
