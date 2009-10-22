""" Test module for testing the xmlparser
"""

import os

import nose
import nose.tools
import numpy as n

from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
import jmodelica.xmlparser as xp


jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.sep+'Python'+os.sep+'jmodelica'+os.sep+'examples'

model = os.sep+'files'+os.sep+'CSTR.mo'
fpath = jm_home+path_to_examples+model
cpath = "CSTR.CSTR_Opt"

fname = cpath.replace('.','_',1)

#type defs
int = n.int32

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
    oc = OptimicaCompiler()
    oc.set_boolean_option('state_start_values_fixed',True)
    oc.compile_model(fpath, cpath)
        
@testattr(stddist = True)
def test_create_XMLVariablesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLVariablesDoc object. 
    """
    filename = fname+'_variables.xml'
    assert xp.XMLVariablesDoc(filename) is not None, \
           "Could not create XMLVariablesDoc from XML file: "+filename

@testattr(stddist = True)
def test_create_XMLValuesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLValuesDoc object. 
    """
    
    filename = fname+'_values.xml'
    assert xp.XMLValuesDoc(filename) is not None, \
           "Could not create XMLValuesDoc from XML file: "+filename

@testattr(stddist = True)
def test_create_XMLProblVariablesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLProblVariablesDoc object.
    """
    filename = fname+'_problvariables.xml'
    assert xp.XMLProblVariablesDoc(filename) is not None, \
           "Could not create XMLProblVariablesDoc from XML file: "+filename

@testattr(stddist = True)
def test_xmlvariablesdoc_methods():
    """ 
    Test that all XMLVariablesDoc methods are callable and returns the 
    correct data type. 
    """
    xmldoc = xp.XMLVariablesDoc(fname+'_variables.xml')
    
    t_get_valueref.description = 'test XMLVariablesDoc.get_valueref'
    t_get_data_type.description = 'test XMLVariablesDoc.get_data_type'
    t_get_variable_names.description = 'test XMLVariablesDoc.get_variable_names'
    t_get_derivative_names.description = 'test XMLVariablesDoc.get_derivative_names'
    t_get_differentiated_variable_names.description = 'test XMLVariablesDoc.get_differentiated_variable_names'
    t_get_input_names.description = 'test XMLVariablesDoc.get_input_names'
    t_get_algebraic_variable_names.description = 'test XMLVariablesDoc.get_algebraic_variable_names'
    t_get_p_opt_names.description = 'test XMLVariablesDoc.get_p_opt_names'
    t_get_variable_descriptions.description = 'test XMLVariablesDoc.get_variable_descriptions'
    t_get_start_attributes.description = 'test XMLVariablesDoc.get_start_attributes'
    t_get_dx_start_attributes.description = 'test XMLVariables.get_dx_start_attributes' 
    t_get_x_start_attributes.description = 'test XMLVariables.get_x_start_attributes'
    t_get_u_start_attributes.description = 'test XMLVariables.get_u_start_attributes'
    t_get_w_start_attributes.description = 'test XMLVariables.get_w_start_attributes'
    t_get_p_opt_variable_refs.description = 'test XMLVariablesDoc.get_p_opt_variable_refs'
    t_get_w_initial_guess_values.description = 'test XMLVariablesDoc.get_w_initial_guess_values'
    t_get_u_initial_guess_values.description = ' test XMLVariablesDoc.get_u_initial_guess_values'
    t_get_dx_initial_guess_values.description = ' test XMLVariablesDoc.get_dx_initial_guess_values'
    t_get_x_initial_guess_values.description = ' test XMLVariablesDoc.get_x_initial_guess_values'
    t_get_p_opt_initial_guess_values.description = ' test XMLVariablesDoc.get_p_opt_initial_guess_values'
    t_get_w_lb_values.description = ' test XMLVariablesDoc.get_w_lb_values'
    t_get_u_lb_values.description = ' test XMLVariablesDoc.get_u_lb_values'
    t_get_dx_lb_values.description = ' test XMLVariablesDoc.get_dx_lb_values'
    t_get_x_lb_values.description = ' test XMLVariablesDoc.get_x_lb_values'
    t_get_p_opt_lb_values.description = ' test XMLVariablesDoc.get_p_opt_lb_values'
    t_get_w_ub_values.description = ' test XMLVariablesDoc.get_w_ub_values'
    t_get_u_ub_values.description = ' test XMLVariablesDoc.get_u_ub_values'
    t_get_dx_ub_values.description = ' test XMLVariablesDoc.get_dx_ub_values'
    t_get_x_ub_values.description = ' test XMLVariablesDoc.get_x_ub_values'
    t_get_p_opt_ub_values.description = ' test XMLVariablesDoc.get_p_opt_ub_values'   
    t_get_w_lin_values.description = ' test XMLVariablesDoc.get_w_lin_values'
    t_get_u_lin_values.description = ' test XMLVariablesDoc.get_u_lin_values'
    t_get_dx_lin_values.description = ' test XMLVariablesDoc.get_dx_lin_values'
    t_get_x_lin_values.description = ' test XMLVariablesDoc.get_x_lin_values'
    t_get_p_opt_lin_values.description = ' test XMLVariablesDoc.get_p_opt_lin_values'   
    t_get_w_lin_tp_values.description = ' test XMLVariablesDoc.get_w_lin_tp_values'
    t_get_u_lin_tp_values.description = ' test XMLVariablesDoc.get_u_lin_tp_values'
    t_get_dx_lin_tp_values.description = ' test XMLVariablesDoc.get_dx_lin_tp_values'
    t_get_x_lin_tp_values.description = ' test XMLVariablesDoc.get_x_lin_tp_values'
    
    yield t_get_valueref, xmldoc
    yield t_get_data_type, xmldoc
    yield t_get_variable_names, xmldoc
    yield t_get_derivative_names, xmldoc
    yield t_get_differentiated_variable_names, xmldoc
    yield t_get_input_names, xmldoc
    yield t_get_algebraic_variable_names, xmldoc
    yield t_get_p_opt_names, xmldoc
    yield t_get_variable_descriptions, xmldoc
    yield t_get_start_attributes, xmldoc
    yield t_get_dx_start_attributes, xmldoc
    yield t_get_x_start_attributes, xmldoc
    yield t_get_u_start_attributes, xmldoc
    yield t_get_w_start_attributes, xmldoc
    yield t_get_p_opt_variable_refs, xmldoc
    yield t_get_w_initial_guess_values, xmldoc
    yield t_get_u_initial_guess_values, xmldoc
    yield t_get_dx_initial_guess_values, xmldoc
    yield t_get_x_initial_guess_values, xmldoc
    yield t_get_p_opt_initial_guess_values, xmldoc
    yield t_get_w_lb_values, xmldoc
    yield t_get_u_lb_values, xmldoc
    yield t_get_dx_lb_values, xmldoc
    yield t_get_x_lb_values, xmldoc
    yield t_get_p_opt_lb_values, xmldoc
    yield t_get_w_ub_values, xmldoc
    yield t_get_u_ub_values, xmldoc
    yield t_get_dx_ub_values, xmldoc
    yield t_get_x_ub_values, xmldoc
    yield t_get_p_opt_ub_values, xmldoc
    yield t_get_w_lin_values, xmldoc
    yield t_get_u_lin_values, xmldoc
    yield t_get_dx_lin_values, xmldoc
    yield t_get_x_lin_values, xmldoc
    yield t_get_p_opt_lin_values, xmldoc
    yield t_get_w_lin_tp_values, xmldoc
    yield t_get_u_lin_tp_values, xmldoc
    yield t_get_dx_lin_tp_values, xmldoc
    yield t_get_x_lin_tp_values, xmldoc
    
@testattr(stddist = True)
def test_xmlvaluesdoc_methods():
    """ 
    Test that all the XMLValuesDoc methods are callable and returns 
    the correct data type.
    """
    xmldoc = xp.XMLValuesDoc(fname+'_values.xml')
    
    t_get_iparam_values.description = 'test XMLValuesDoc.get_iparam_values'
    
    yield t_get_iparam_values, xmldoc
    
@testattr(stddist = True)
def test_xmlproblvariablesdoc_methods():
    """
    Test that all the XMLProblVariablesDoc methods are callable and 
    returns the correct data type.
    """
    xmldoc = xp.XMLProblVariablesDoc(fname+'_problvariables.xml')
    
    t_get_starttime.description = ' test XMLProblVariables.get_starttime'
    t_get_starttime_free.description = ' test XMLProblVariables.get_starttime_free'
    t_get_finaltime.description = ' test XMLProblVariables.get_finaltime'
    t_get_finaltime_free.description = ' test XMLProblVariables.get_finaltime_free'
    t_get_timepoints.description = ' test XMLProblVariables.get_timepoints'

    yield t_get_starttime, xmldoc
    yield t_get_starttime_free, xmldoc
    yield t_get_finaltime, xmldoc
    yield t_get_finaltime_free, xmldoc
    yield t_get_timepoints, xmldoc

@testattr(stddist = True)
def t_get_valueref(xmldoc):
    ref = xmldoc.get_valueref('u')
    assert ref.__class__ is int, \
        "XMLVariablesDoc.get_valueref did not return int."
        
@testattr(stddist = True)
def t_get_data_type(xmldoc):
    ref = xmldoc.get_valueref('u')
    type = xmldoc.get_data_type(ref)
    assert type.__class__ is str, \
        "XMLVariablesDoc.get_data_type did not return string."
    nose.tools.assert_equal(type,'Real'),  \
        "XMLVariablesDoc.get_data_type for variable u did not return Real."

@testattr(stddist = True)
def t_get_variable_names(xmldoc):
    d = xmldoc.get_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"       
    
@testattr(stddist = True)
def t_get_derivative_names(xmldoc):
    d = xmldoc.get_derivative_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"    

@testattr(stddist = True)
def t_get_differentiated_variable_names(xmldoc):
    d = xmldoc.get_differentiated_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"  

@testattr(stddist = True)    
def t_get_input_names(xmldoc):
    d = xmldoc.get_input_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"  

@testattr(stddist = True)    
def t_get_algebraic_variable_names(xmldoc):
    d = xmldoc.get_algebraic_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"  

@testattr(stddist = True)    
def t_get_p_opt_names(xmldoc):
    d = xmldoc.get_p_opt_names()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"  

@testattr(stddist = True)    
def t_get_variable_descriptions(xmldoc):
    d = xmldoc.get_variable_descriptions()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is str, \
            "Variable name is not string"  

@testattr(stddist = True)
def t_get_start_attributes(xmldoc):
    d = xmldoc.get_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "Start attribute of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "Start attribute of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Start attribute of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Start attribute of String is not str."
        else:
            pass
            # enumeration not supported
            
@testattr(stddist = True)
def t_get_dx_start_attributes(xmldoc):
    d = xmldoc.get_dx_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "Start attribute of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "Start attribute of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Start attribute of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Start attribute of String is not str."
        else:
            pass
            # enumeration not supported
            
@testattr(stddist = True)
def t_get_x_start_attributes(xmldoc):
    d = xmldoc.get_x_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "Start attribute of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "Start attribute of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Start attribute of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Start attribute of String is not str."
        else:
            pass
            # enumeration not supported            

@testattr(stddist = True)
def t_get_u_start_attributes(xmldoc):
    d = xmldoc.get_u_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "Start attribute of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "Start attribute of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Start attribute of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Start attribute of String is not str."
        else:
            pass
            # enumeration not supported
            
@testattr(stddist = True)
def t_get_w_start_attributes(xmldoc):
    d = xmldoc.get_w_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "Start attribute of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "Start attribute of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Start attribute of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Start attribute of String is not str."
        else:
            pass
            # enumeration not supported             

@testattr(stddist = True)
def t_get_p_opt_variable_refs(xmldoc):
    refs = xmldoc.get_p_opt_variable_refs()   
    for ref in refs:
        assert ref.__class__ is int, \
           "Value ref is not int."

@testattr(stddist = True)
def t_get_w_initial_guess_values(xmldoc):
    d = xmldoc.get_w_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real variable is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer variable is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "value of Boolean variable is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "value of String variable is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_u_initial_guess_values(xmldoc):
    d = xmldoc.get_u_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_dx_initial_guess_values(xmldoc):
    d = xmldoc.get_dx_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_x_initial_guess_values(xmldoc):
    d = xmldoc.get_x_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_p_opt_initial_guess_values(xmldoc):
    d = xmldoc.get_p_opt_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_w_lb_values(xmldoc):
    d = xmldoc.get_w_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_u_lb_values(xmldoc):
    d = xmldoc.get_u_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_dx_lb_values(xmldoc):
    d = xmldoc.get_dx_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_x_lb_values(xmldoc):
    d = xmldoc.get_x_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_p_opt_lb_values(xmldoc):
    d = xmldoc.get_p_opt_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_w_ub_values(xmldoc):
    d = xmldoc.get_w_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_u_ub_values(xmldoc):
    d = xmldoc.get_u_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_dx_ub_values(xmldoc):
    d = xmldoc.get_dx_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_x_ub_values(xmldoc):
    d = xmldoc.get_x_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_p_opt_ub_values(xmldoc):
    d = xmldoc.get_p_opt_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_data_type(key)
        if type == 'Real':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'Integer':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'Boolean':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'String':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_w_lin_values(xmldoc):
    d = xmldoc.get_w_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is bool, \
                "Is linear value is not bool."

@testattr(stddist = True)
def t_get_u_lin_values(xmldoc):
    d = xmldoc.get_u_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is bool, \
                "Is linear value is not bool."

@testattr(stddist = True)
def t_get_dx_lin_values(xmldoc):
    d = xmldoc.get_dx_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is bool, \
                "Is linear value is not bool."

@testattr(stddist = True)
def t_get_x_lin_values(xmldoc):
    d = xmldoc.get_x_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is bool, \
                "Is linear value is not bool."

@testattr(stddist = True)
def t_get_p_opt_lin_values(xmldoc):
    d = xmldoc.get_p_opt_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        assert value.__class__ is bool, \
                "Is linear value is not bool."

@testattr(stddist = True)
def t_get_w_lin_tp_values(xmldoc):
    d = xmldoc.get_w_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."

@testattr(stddist = True)
def t_get_u_lin_tp_values(xmldoc):
    d = xmldoc.get_u_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."

@testattr(stddist = True)
def t_get_dx_lin_tp_values(xmldoc):
    d = xmldoc.get_dx_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."

@testattr(stddist = True)
def t_get_x_lin_tp_values(xmldoc):
    d = xmldoc.get_x_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."
                
@testattr(stddist = True)
def t_get_iparam_values(xmldoc):
    d = xmldoc.get_iparam_values()
    for key, value in d.iteritems():
        assert key.__class__ is int, \
            "Value reference is not int"
        type = xmldoc.get_parameter_type(key)
        if type == 'RealParameter':
            assert value.__class__ is float, \
                "value of Real is not float."
        elif type == 'IntegerParameter':
            assert value.__class__ is int, \
                "value of Integer is not int."
        elif type == 'BooleanParameter':
            assert value.__class__ is bool, \
                "Initial guess value of Boolean is not bool."
        elif type == 'StringParameter':
            assert value.__class__ is str, \
                "Initial guess value of String is not str."
        else:
            pass
            # enumeration not supported

@testattr(stddist = True)
def t_get_starttime(xmldoc):
    time = xmldoc.get_starttime()
    assert time.__class__ is float, \
        "XMLProblVariablesDoc.get_starttime did not return float."
    
@testattr(stddist = True)
def t_get_starttime_free(xmldoc):
    b = xmldoc.get_starttime_free()
    assert b.__class__ is bool, \
            "XMLProblVariablesDoc.get_starttime_free did not return boolean."
    
@testattr(stddist = True)
def t_get_finaltime(xmldoc):
    time = xmldoc.get_finaltime()
    assert time.__class__ is float, \
        "XMLProblVariablesDoc.get_finaltime did not return float."
    
@testattr(stddist = True)
def t_get_finaltime_free(xmldoc):
    b = xmldoc.get_finaltime_free()
    assert b.__class__ is bool, \
            "XMLProblVariablesDoc.get_finaltime_free did not return boolean."
    
@testattr(stddist = True)
def t_get_timepoints(xmldoc):
    timepoints = xmldoc.get_timepoints()
    for tp in timepoints:
        assert tp.__class__ is float, \
            "timepoint is not float."
