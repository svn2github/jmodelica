""" Test module for testing the xmlparser
"""

import os

import nose

import jmodelica.optimicacompiler as oc
import jmodelica.xmlparser as xp


jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.sep+'Python'+os.sep+'jmodelica'+os.sep+'examples'

model = os.sep+'pendulum'+os.sep+'Pendulum_pack.mo'
fpath = jm_home+path_to_examples+model
cpath = "Pendulum_pack.Pendulum_Opt"

fname = cpath.replace('.','_',1)

def setup():
    """ 
    Setup test module. Compile test model (only needs to be done once) and 
    set log level. 
    """
    oc.set_log_level(oc.LOG_ERROR)
    oc.compile_model(fpath, cpath)
        
def test_create_XMLVariablesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLVariablesDoc object. 
    """
    filename = fname+'_variables.xml'
    assert xp.XMLVariablesDoc(filename) is not None, \
           "Could not create XMLVariablesDoc from XML file: "+filename

def test_create_XMLValuesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLValuesDoc object. 
    """
    
    filename = fname+'_values.xml'
    assert xp.XMLValuesDoc(filename) is not None, \
           "Could not create XMLValuesDoc from XML file: "+filename

def test_create_XMLProblVariablesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLProblVariablesDoc object.
    """
    filename = fname+'_problvariables.xml'
    assert xp.XMLProblVariablesDoc(filename) is not None, \
           "Could not create XMLProblVariablesDoc from XML file: "+filename

def test_xmlvariablesdoc_methods():
    """ 
    Test that all XMLVariablesDoc methods are callable and returns the 
    correct data type. 
    """
    xmldoc = xp.XMLVariablesDoc(fname+'_variables.xml')
    
    t_get_start_attributes.description = 'test XMLVariablesDoc.get_start_attributes'
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
    
    yield t_get_start_attributes, xmldoc
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
    
def test_xmlvaluesdoc_methods():
    """ 
    Test that all the XMLValuesDoc methods are callable and returns 
    the correct data type.
    """
    xmldoc = xp.XMLValuesDoc(fname+'_values.xml')
    
    t_get_iparam_values.description = 'test XMLValuesDoc.get_iparam_values'
    
    yield t_get_iparam_values, xmldoc
    
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

def t_get_start_attributes(xmldoc):
    d = xmldoc.get_start_attributes()
    assert d.__class__ is dict, \
           "XMLVariablesDoc.get_start_attributes did not return correctly."

def t_get_p_opt_variable_refs(xmldoc):
    l = xmldoc.get_p_opt_variable_refs()
    assert l.__class__ is list, \
           "XMLVariablesDoc.get_p_opt_variable_refs did not return correctly."

def t_get_w_initial_guess_values(xmldoc):
    d = xmldoc.get_w_initial_guess_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_w_initial_guess_values did not return correctly."

def t_get_u_initial_guess_values(xmldoc):
    d = xmldoc.get_u_initial_guess_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_u_initial_guess_values did not return correctly."

def t_get_dx_initial_guess_values(xmldoc):
    d = xmldoc.get_dx_initial_guess_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_dx_initial_guess_values did not return correctly."

def t_get_x_initial_guess_values(xmldoc):
    d = xmldoc.get_x_initial_guess_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_x_initial_guess_values did not return correctly."

def t_get_p_opt_initial_guess_values(xmldoc):
    d = xmldoc.get_p_opt_initial_guess_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_p_opt_initial_guess_values did not return correctly."

def t_get_w_lb_values(xmldoc):
    d = xmldoc.get_w_lb_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_w_lb_values did not return correctly."

def t_get_u_lb_values(xmldoc):
    d = xmldoc.get_u_lb_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_u_lb_values did not return correctly."

def t_get_dx_lb_values(xmldoc):
    d = xmldoc.get_dx_lb_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_dx_lb_values did not return correctly."

def t_get_x_lb_values(xmldoc):
    d = xmldoc.get_x_lb_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_x_lb_values did not return correctly."

def t_get_p_opt_lb_values(xmldoc):
    d = xmldoc.get_p_opt_lb_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_p_opt_lb_values did not return correctly."

def t_get_w_ub_values(xmldoc):
    d = xmldoc.get_w_ub_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_w_ub_values did not return correctly."

def t_get_u_ub_values(xmldoc):
    d = xmldoc.get_u_ub_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_u_ub_values did not return correctly."

def t_get_dx_ub_values(xmldoc):
    d = xmldoc.get_dx_ub_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_dx_ub_values did not return correctly."

def t_get_x_ub_values(xmldoc):
    d = xmldoc.get_x_ub_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_x_ub_values did not return correctly."

def t_get_p_opt_ub_values(xmldoc):
    d = xmldoc.get_p_opt_ub_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_p_opt_ub_values did not return correctly."

def t_get_w_lin_values(xmldoc):
    d = xmldoc.get_w_lin_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_w_lin_values did not return correctly."

def t_get_u_lin_values(xmldoc):
    d = xmldoc.get_u_lin_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_u_lin_values did not return correctly."

def t_get_dx_lin_values(xmldoc):
    d = xmldoc.get_dx_lin_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_dx_lin_values did not return correctly."

def t_get_x_lin_values(xmldoc):
    d = xmldoc.get_x_lin_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_x_lin_values did not return correctly."

def t_get_p_opt_lin_values(xmldoc):
    d = xmldoc.get_p_opt_lin_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_p_opt_lin_values did not return correctly."

def t_get_w_lin_tp_values(xmldoc):
    d = xmldoc.get_w_lin_tp_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_w_lin_tp_values did not return correctly."

def t_get_u_lin_tp_values(xmldoc):
    d = xmldoc.get_u_lin_tp_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_u_lin_tp_values did not return correctly."

def t_get_dx_lin_tp_values(xmldoc):
    d = xmldoc.get_dx_lin_tp_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_dx_lin_tp_values did not return correctly."

def t_get_x_lin_tp_values(xmldoc):
    d = xmldoc.get_x_lin_tp_values()
    assert d.__class__ is dict, \
            "XMLVariablesDoc.get_x_lin_tp_values did not return correctly."

def t_get_iparam_values(xmldoc):
    d = xmldoc.get_iparam_values()
    assert d.__class__ is dict, \
            "XMLValuesDoc.get_iparam_values did not return correctly."

def t_get_starttime(xmldoc):
    f = xmldoc.get_starttime()
    try:
        float(f)
    except TypeError, e:
        pass
    except ValueError,e:
        "XMLProblVariablesDoc.get_starttime did not return correctly."
    
def t_get_starttime_free(xmldoc):
    b = xmldoc.get_starttime_free()
    assert b.__class__ is bool, \
            "XMLProblVariablesDoc.get_starttime_free did not return correctly."
    
def t_get_finaltime(xmldoc):
    f = xmldoc.get_finaltime()
    try:
        float(f)
    except TypeError,e:
        pass
    except ValueError, e:
        "XMLProblVariablesDoc.get_finaltime did not return correctly."
    
def t_get_finaltime_free(xmldoc):
    b = xmldoc.get_finaltime_free()
    assert b.__class__ is bool, \
            "XMLProblVariablesDoc.get_finaltime_free did not return correctly."
    
def t_get_timepoints(xmldoc):
    l = xmldoc.get_timepoints()
    assert l.__class__ is list, \
            "XMLProblVariablesDoc.get_timepoints did not return correctly."
