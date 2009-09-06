"""JModelica test package.

This __init__.py file holds functions used to load
"""

import os

import jmodelica.jmi as pyjmi


def get_example_path():
    """Get the absolute path to the examples directory."""
    
    jmhome = os.environ.get('JMODELICA_HOME')
    assert jmhome is not None, "You have to specify" \
                               " JMODELICA_HOME environment" \
                               " variable."
    return os.path.join(jmhome, 'Python', 'jmodelica', 'examples', 'files')
    
    
def load_example_standard_model(libname, mofile=None, optpackage=None):
    """ Load and return a jmodelica.jmi.Model from DLL file libname residing in
        the example path.
        
    If the DLL file does not exist this method tries to build it if mofile and
    optpackage are specified.
    
    Keyword parameters:
    mofile -- the Modelica file used to build the DLL file.
    optpackage -- the Optimica package in the mofile which is to be compiled.
    
    """
    return pyjmi.load_model(libname, get_example_path(), mofile, optpackage,
                            'optimica')
