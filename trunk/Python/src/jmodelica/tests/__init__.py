"""JModelica test package.

This __init__.py file holds functions used to load
"""

import os
import sys
import os, os.path
import jmodelica.jmi as pyjmi

__all__ = ['optimization','initialization','simulation','general','test_compiler','test_examples','test_fmi','test_init','test_io','test_jmi','test_jmiwrappers','test_linearization','test_xmlparser']

#create working directory for tests
if sys.platform == 'win32':
    _p = os.path.join(os.environ['JMODELICA_HOME'],'tests')
else:
    _p = os.path.join(os.environ['HOME'],'jmodelica.org','tests')

if not os.path.exists(_p):
    try:
        os.mkdir(_p)
    except Exception:
        _p = ""
if _p:
    os.chdir(_p)


def testattr(**kwargs):
    """Add attributes to a test function/method/class.
    
    This function is needed to be able to add
      @attr(slow = True)
    for functions.
    
    """
    def wrap(func):
        func.__dict__.update(kwargs)
        return func
    return wrap


def get_example_path():
    """Get the absolute path to the examples directory."""
    
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, 'Python', 'jmodelica', 'examples', 'files')   

#def load_example_standard_model(libname, mofile=None, optpackage=None):
#    """ Load and return a jmodelica.jmi.Model from DLL file libname residing in
#        the example path.
#        
#    If the DLL file does not exist this method tries to build it if mofile and
#    optpackage are specified.
#    
#    Keyword parameters:
#    mofile -- the Modelica file used to build the DLL file.
#    optpackage -- the Optimica package in the mofile which is to be compiled.
#    
#    """
#    return pyjmi.load_model(libname, get_example_path(), mofile, optpackage,
#                            'optimica')
