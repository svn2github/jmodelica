""" Test module for testing the xmlparser
"""

import os

import nose
import nose.tools
import numpy as n

from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler
from jmodelica import xmldoc


jm_home = os.environ.get('JMODELICA_HOME')
path_to_tests = os.path.join(jm_home, 'Python', 'jmodelica','tests')

# modified cstr xml
modcstr = os.path.join(path_to_tests, 'files','CSTR_CSTR_Opt_modified.xml')
md = xmldoc.ModelDescription(modcstr)

#type defs
int = n.int32
uint = n.uint32

@testattr(stddist = True)
def test_get_fmi_version():
    """
    Test xmldoc.ModelDescription.get_fmi_version method.
    
    """
    nose.tools.assert_equal(md.get_fmi_version(), '1.0')

@testattr(stddist = True)
def test_get_model_name():
    """
    Test xmldoc.ModelDescription.get_model_name method.
    
    """
    nose.tools.assert_equal(md.get_model_name(), 'CSTR.CSTR_Opt')
    
@testattr(stddist = True)
def test_get_model_identifier():
    """
    Test xmldoc.ModelDescription.get_model_identifier method.
    
    """
    nose.tools.assert_equal(md.get_model_identifier(), 'CSTR_CSTR_Opt')

@testattr(stddist = True)
def test_get_guid():
    """
    Test xmldoc.ModelDescription.get_guid method.
    
    """
    nose.tools.assert_equal(md.get_guid(), '123abc')

@testattr(stddist = True)
def test_get_description():
    """
    Test xmldoc.ModelDescription.get_description method.
    
    """
    nose.tools.assert_equal(md.get_description(), 'Modified CSTR')

@testattr(stddist = True)
def test_get_author():
    """
    Test xmldoc.ModelDescription.get_author method.
    
    """
    nose.tools.assert_equal(md.get_author(), 'tester')
    
@testattr(stddist = True)
def test_get_version():
    """
    Test xmldoc.ModelDescription.get_version method.
    
    """
    nose.tools.assert_equal(md.get_version(), 1.0)
    
@testattr(stddist = True)
def test_get_generation_tool():
    """
    Test xmldoc.ModelDescription.get_generation_tool method.
    
    """
    nose.tools.assert_equal(md.get_generation_tool(), 'JModelica')
        
@testattr(stddist = True)
def test_get_generation_date_and_time():
    """
    Test xmldoc.ModelDescription.get_generation_date_and_time method.
    
    """
    nose.tools.assert_equal(md.get_generation_date_and_time(), '2010-05-17T14:08:53')

@testattr(stddist = True)
def test_get_variable_naming_convention():
    """
    Test xmldoc.ModelDescription.get_variable_naming_convention method.
    
    """
    nose.tools.assert_equal(md.get_variable_naming_convention(), 'flat')

@testattr(stddist = True)
def test_get_number_of_continuous_states():
    """
    Test xmldoc.ModelDescription.get_number_of_continuous_states method.
    
    """
    nose.tools.assert_equal(md.get_number_of_continuous_states(), 3)
    
@testattr(stddist = True)
def test_get_number_of_event_indicators():
    """
    Test xmldoc.ModelDescription.get_number_of_event_indicators method.
    
    """
    nose.tools.assert_equal(md.get_number_of_event_indicators(), 0)    
    
@testattr(stddist = True)
def test_get_variable_names():
    """
    Test xmldoc.ModelDescription.get_variable_names method.
    
    """
    vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
    vnames = ("u", "cstr.F0", "cstr.c0", "cstr.F", "cstr.T0", "cstr.r", 
        "cstr.k0", "cstr.EdivR", "cstr.U", "cstr.rho")
        
    vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
    vnames_noalias = ("u", "cstr.F0", "cstr.F", "cstr.T0", "cstr.k0", 
        "cstr.U", "cstr.rho")
    
    # with alias
    nose.tools.assert_equal(md.get_variable_names(), zip(vrefs, vnames))
    
    # without alias
    nose.tools.assert_equal(md.get_variable_names(include_alias=False), 
        zip(vrefs_noalias, vnames_noalias))
        
@testattr(stddist = True)
def test_get_variable_aliases():
    """
    Test xmldoc.ModelDescription.get_variable_aliases method.
    
    """
    vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
    valiases = (xmldoc.NO_ALIAS, xmldoc.NO_ALIAS, xmldoc.ALIAS, 
        xmldoc.NO_ALIAS, xmldoc.NO_ALIAS, xmldoc.NEGATED_ALIAS, 
        xmldoc.NO_ALIAS, xmldoc.ALIAS, xmldoc.NO_ALIAS, xmldoc.NO_ALIAS)
        
    nose.tools.assert_equal(md.get_variable_aliases(), zip(vrefs, valiases))
    
@testattr(stddist = True)
def test_get_variable_descriptions():
    """
    Test xmldoc.ModelDescription.get_variable_descriptions method.
    
    """
    vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
    vdesc = ("", "Inflow", "Concentration of inflow", "Outflow", "", "", 
        "", "", "", "")
        
    vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
    vdesc_noalias = ("", "Inflow", "Outflow", "", "", "", "")
    
    # with alias
    nose.tools.assert_equal(md.get_variable_descriptions(), zip(vrefs, vdesc))
    
    # without alias
    nose.tools.assert_equal(md.get_variable_descriptions(include_alias=False), 
        zip(vrefs_noalias, vdesc_noalias))
    
@testattr(stddist = True)
def test_get_variable_variabilities():
    """
    Test xmldoc.ModelDescription.get_variable_variabilities method.
    
    """
    vrefs = (26, 0, 0, 2, 3, 0, 5, 5, 7, 8)
    vvars = (xmldoc.CONTINUOUS, xmldoc.PARAMETER, xmldoc.CONTINUOUS, 
        xmldoc.CONSTANT, xmldoc.PARAMETER, xmldoc.PARAMETER, 
        xmldoc.DISCRETE, xmldoc.CONTINUOUS, xmldoc.PARAMETER, 
        xmldoc.CONTINUOUS)
        
    vrefs_noalias = (26, 0, 2, 3, 5, 7, 8)
    vvars_noalias = (xmldoc.CONTINUOUS, xmldoc.PARAMETER, 
        xmldoc.CONSTANT, xmldoc.PARAMETER, xmldoc.DISCRETE, 
        xmldoc.PARAMETER, xmldoc.CONTINUOUS)
    
    # with alias
    nose.tools.assert_equal(md.get_variable_variabilities(), zip(vrefs, vvars))
    
    # without alias
    nose.tools.assert_equal(md.get_variable_variabilities(include_alias=False), 
        zip(vrefs_noalias, vvars_noalias))

    
    
    
    
    
