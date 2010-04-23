""" Test module for testing the xmlparser
"""

import os

import nose
import nose.tools
import numpy as n

from jmodelica.tests import testattr
from jmodelica.compiler import OptimicaCompiler
from jmodelica.compiler import ModelicaCompiler
import jmodelica.xmlparser as xp


jm_home = os.environ.get('JMODELICA_HOME')
path_to_examples = os.path.join('Python','jmodelica','examples')
path_to_schemas = os.path.join(jm_home,'XML')

# cstr model
cstr_model = os.path.join('files','CSTR.mo')
cstr_fpath = os.path.join(jm_home,path_to_examples,cstr_model)
cstr_cpath = "CSTR.CSTR_Opt"
cstr_fname = cstr_cpath.replace('.','_',1)

# parameter estimation model
parest_model = os.path.join('files','ParameterEstimation_1.mo')
parest_fpath = os.path.join(jm_home,path_to_examples,parest_model)
parest_cpath = "ParEst.ParEst"
parest_fname = parest_cpath.replace('.','_',1)

# vdp min time model
vdpmin_model = os.path.join('files','VDP.mo')
vdpmin_fpath = os.path.join(jm_home,path_to_examples,vdpmin_model)
vdpmin_cpath = "VDP_pack.VDP_Opt_Min_Time"
vdpmin_fname = vdpmin_cpath.replace('.','_',1)

#compilers
mc = ModelicaCompiler()
oc = OptimicaCompiler()

#type defs
int = n.int32

def setup():
    """ 
    Setup test module. Compile test models (only needs to be done once) and 
    set log level. 
    """
    OptimicaCompiler.set_log_level(OptimicaCompiler.LOG_ERROR)
    oc.set_boolean_option('state_start_values_fixed',True)
    oc.set_boolean_option('eliminate_alias_variables',True)
    # cstr model
    oc.compile_model(cstr_cpath, cstr_fpath)
    # parameter est model
    oc.compile_model(parest_cpath, parest_fpath)
    # vdp min time model
    oc.compile_model(vdpmin_cpath, vdpmin_fpath)#, 'ipopt')
    
        
@testattr(stddist = True)
def test_create_XMLDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLDoc object. 
    """
    filename = cstr_fname+'.xml'
    assert xp.XMLDoc(filename) is not None, \
           "Could not create XMLDoc from XML file: "+filename

@testattr(stddist = True)
def test_create_XMLValuesDoc():
    """ 
    Test that it is possible to parse the XML file and create a 
    XMLValuesDoc object. 
    """
    
    filename = cstr_fname+'_values.xml'
    assert xp.XMLValuesDoc(filename) is not None, \
           "Could not create XMLValuesDoc from XML file: "+filename

@testattr(stddist = True)
def test_xmldoc_methods():
    """ 
    Test that all XMLDoc methods are callable and returns the 
    correct data type. 
    """
    cstr_xmldoc = xp.XMLDoc(cstr_fname+'.xml')
    parest_xmldoc = xp.XMLDoc(parest_fname+'.xml')
    vdpmin_xmldoc = xp.XMLDoc(vdpmin_fname+'.xml')
    
    t_get_valueref.description = 'test XMLDoc.get_valueref'
    t_get_aliases.description = 'test XMLDoc.get_aliases'
    t_get_variable_description.description = 'test XMLDoc.get_variable_description'
    t_get_data_type.description = 'test XMLDoc.get_data_type'
    t_get_variable_names.description = 'test XMLDoc.get_variable_names'
    t_get_derivative_names.description = 'test XMLDoc.get_derivative_names'
    t_get_differentiated_variable_names.description = 'test XMLDoc.get_differentiated_variable_names'
    t_get_input_names.description = 'test XMLDoc.get_input_names'
    t_get_algebraic_variable_names.description = 'test XMLDoc.get_algebraic_variable_names'
    t_get_p_opt_names.description = 'test XMLDoc.get_p_opt_names'
    t_get_variable_descriptions.description = 'test XMLDoc.get_variable_descriptions'
    t_get_start_attributes.description = 'test XMLDoc.get_start_attributes'
    t_get_dx_start_attributes.description = 'test XMLDoc.get_dx_start_attributes' 
    t_get_x_start_attributes.description = 'test XMLDoc.get_x_start_attributes'
    t_get_u_start_attributes.description = 'test XMLDoc.get_u_start_attributes'
    t_get_w_start_attributes.description = 'test XMLDoc.get_w_start_attributes'
    t_get_p_opt_variable_refs.description = 'test XMLDoc.get_p_opt_variable_refs'
    t_get_w_initial_guess_values.description = 'test XMLDoc.get_w_initial_guess_values'
    t_get_u_initial_guess_values.description = ' test XMLDoc.get_u_initial_guess_values'
    t_get_dx_initial_guess_values.description = ' test XMLDoc.get_dx_initial_guess_values'
    t_get_x_initial_guess_values.description = ' test XMLDoc.get_x_initial_guess_values'
    t_get_p_opt_initial_guess_values.description = ' test XMLDoc.get_p_opt_initial_guess_values'
    t_get_w_lb_values.description = ' test XMLDoc.get_w_lb_values'
    t_get_u_lb_values.description = ' test XMLDoc.get_u_lb_values'
    t_get_dx_lb_values.description = ' test XMLDoc.get_dx_lb_values'
    t_get_x_lb_values.description = ' test XMLDoc.get_x_lb_values'
    t_get_p_opt_lb_values.description = ' test XMLDoc.get_p_opt_lb_values'
    t_get_w_ub_values.description = ' test XMLDoc.get_w_ub_values'
    t_get_u_ub_values.description = ' test XMLDoc.get_u_ub_values'
    t_get_dx_ub_values.description = ' test XMLDoc.get_dx_ub_values'
    t_get_x_ub_values.description = ' test XMLDoc.get_x_ub_values'
    t_get_p_opt_ub_values.description = ' test XMLDoc.get_p_opt_ub_values'   
    t_get_w_lin_values.description = ' test XMLDoc.get_w_lin_values'
    t_get_u_lin_values.description = ' test XMLDoc.get_u_lin_values'
    t_get_dx_lin_values.description = ' test XMLDoc.get_dx_lin_values'
    t_get_x_lin_values.description = ' test XMLDoc.get_x_lin_values'
    t_get_p_opt_lin_values.description = ' test XMLDoc.get_p_opt_lin_values'   
    t_get_w_lin_tp_values.description = ' test XMLDoc.get_w_lin_tp_values'
    t_get_u_lin_tp_values.description = ' test XMLDoc.get_u_lin_tp_values'
    t_get_dx_lin_tp_values.description = ' test XMLDoc.get_dx_lin_tp_values'
    t_get_x_lin_tp_values.description = ' test XMLDoc.get_x_lin_tp_values'    
    t_get_starttime.description = ' test XMLDoc.get_starttime'
    t_get_starttime_free.description = ' test XMLDoc.get_starttime_free'
    t_get_finaltime.description = ' test XMLDoc.get_finaltime'
    t_get_finaltime_free.description = ' test XMLDoc.get_finaltime_free'
    t_get_timepoints.description = ' test XMLDoc.get_timepoints'

    
    yield t_get_valueref, cstr_xmldoc
    yield t_get_aliases, cstr_xmldoc
    yield t_get_variable_description, cstr_xmldoc
    yield t_get_data_type, cstr_xmldoc
    yield t_get_variable_names, cstr_xmldoc
    yield t_get_derivative_names, cstr_xmldoc
    yield t_get_differentiated_variable_names, cstr_xmldoc
    yield t_get_input_names, cstr_xmldoc
    yield t_get_algebraic_variable_names, cstr_xmldoc
    yield t_get_p_opt_names, parest_xmldoc
    yield t_get_variable_descriptions, cstr_xmldoc
    yield t_get_start_attributes, cstr_xmldoc
    yield t_get_dx_start_attributes, cstr_xmldoc
    yield t_get_x_start_attributes, cstr_xmldoc
    yield t_get_u_start_attributes, cstr_xmldoc
    yield t_get_w_start_attributes, parest_xmldoc
    yield t_get_p_opt_variable_refs, parest_xmldoc
    yield t_get_w_initial_guess_values, parest_xmldoc
    yield t_get_u_initial_guess_values, cstr_xmldoc
    yield t_get_dx_initial_guess_values, cstr_xmldoc
    yield t_get_x_initial_guess_values, cstr_xmldoc
    yield t_get_p_opt_initial_guess_values, parest_xmldoc
    yield t_get_w_lb_values, cstr_xmldoc # no example in testfiles
    yield t_get_u_lb_values, vdpmin_xmldoc
    yield t_get_dx_lb_values, cstr_xmldoc # no example in testfiles
    yield t_get_x_lb_values, cstr_xmldoc # no example in testfiles
    yield t_get_p_opt_lb_values, vdpmin_xmldoc
    yield t_get_w_ub_values, cstr_xmldoc # no example in testfiles
    yield t_get_u_ub_values, vdpmin_xmldoc
    yield t_get_dx_ub_values, cstr_xmldoc # no example in testfiles
    yield t_get_x_ub_values, cstr_xmldoc # no example in testfiles
    yield t_get_p_opt_ub_values, cstr_xmldoc # no example in testfiles
    yield t_get_w_lin_values, parest_xmldoc
    yield t_get_u_lin_values, cstr_xmldoc
    yield t_get_dx_lin_values, cstr_xmldoc
    yield t_get_x_lin_values, cstr_xmldoc
    yield t_get_p_opt_lin_values, parest_xmldoc
    yield t_get_w_lin_tp_values, parest_xmldoc
    yield t_get_u_lin_tp_values, cstr_xmldoc
    yield t_get_dx_lin_tp_values, cstr_xmldoc
    yield t_get_x_lin_tp_values, cstr_xmldoc    
    yield t_get_starttime, cstr_xmldoc
    yield t_get_starttime_free, cstr_xmldoc
    yield t_get_finaltime, cstr_xmldoc
    yield t_get_finaltime_free, cstr_xmldoc
    yield t_get_timepoints, cstr_xmldoc 
    
@testattr(stddist = True)
def test_xmlvaluesdoc_methods():
    """ 
    Test that all the XMLValuesDoc methods are callable and returns 
    the correct data type.
    """
    xmldoc = xp.XMLValuesDoc(cstr_fname+'_values.xml')
    
    t_get_iparam_values.description = 'test XMLValuesDoc.get_iparam_values'
    
    yield t_get_iparam_values, xmldoc
    
@testattr(stddist = True)
def t_get_valueref(xmldoc):
    ref = xmldoc.get_valueref('u')
    assert ref.__class__ is int, \
        "XMLVariablesDoc.get_valueref did not return int."
        
@testattr(stddist = True)
def t_get_aliases(xmldoc):
    aliases, isnegated = xmldoc.get_aliases('u')
    nose.tools.assert_equal(aliases[0],'cstr.Tc')
    nose.tools.assert_equal(isnegated[0], False)
    
@testattr(stddist = True)
def t_get_variable_description(xmldoc):
    desc = xmldoc.get_variable_description('cstr.F0')
    nose.tools.assert_equal(desc, 'Inflow')
        
@testattr(stddist = True)
def t_get_data_type(xmldoc):
    type = xmldoc.get_data_type('u')
    assert type.__class__ is str, \
        "XMLVariablesDoc.get_data_type did not return string."
    nose.tools.assert_equal(type,'Real'),  \
        "XMLVariablesDoc.get_data_type for variable u did not return Real."

@testattr(stddist = True)
def t_get_variable_names(xmldoc):
    d = xmldoc.get_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    nose.tools.assert_equal(d.get('u'),26)     
    
@testattr(stddist = True)
def t_get_derivative_names(xmldoc):
    d = xmldoc.get_derivative_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    nose.tools.assert_equal(d.get('der(cost)'),20)

@testattr(stddist = True)
def t_get_differentiated_variable_names(xmldoc):
    d = xmldoc.get_differentiated_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    nose.tools.assert_equal(d.get('cstr.c'),24)

@testattr(stddist = True)    
def t_get_input_names(xmldoc):
    d = xmldoc.get_input_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    nose.tools.assert_equal(d.get('u'),26)

@testattr(stddist = True)    
def t_get_algebraic_variable_names(xmldoc):
    d = xmldoc.get_algebraic_variable_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    # no example in testfile

@testattr(stddist = True)    
def t_get_p_opt_names(xmldoc):
    d = xmldoc.get_p_opt_names()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is int, \
            "Value reference is not int"
    nose.tools.assert_equal(d.get('sys.w'),0)

@testattr(stddist = True)    
def t_get_variable_descriptions(xmldoc):
    d = xmldoc.get_variable_descriptions()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is str, \
            "Description is not string"
    nose.tools.assert_equal(d.get('cstr.F0'),'Inflow')

@testattr(stddist = True)
def t_get_start_attributes(xmldoc):
    d = xmldoc.get_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('cstr.F0'),0.0)
            
@testattr(stddist = True)
def t_get_dx_start_attributes(xmldoc):
    d = xmldoc.get_dx_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('cstr.der(T)'),0.0)
            
@testattr(stddist = True)
def t_get_x_start_attributes(xmldoc):
    d = xmldoc.get_x_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('cstr.c'),1000.0)          

@testattr(stddist = True)
def t_get_u_start_attributes(xmldoc):
    d = xmldoc.get_u_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'),350.0)
            
@testattr(stddist = True)
def t_get_w_start_attributes(xmldoc):
    d = xmldoc.get_w_start_attributes()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'),0.0)         

@testattr(stddist = True)
def t_get_p_opt_variable_refs(xmldoc):
    refs = xmldoc.get_p_opt_variable_refs()   
    for ref in refs:
        assert ref.__class__ is int, \
           "Value reference is not int."
    nose.tools.assert_equal(refs[0],0)

@testattr(stddist = True)
def t_get_w_initial_guess_values(xmldoc):
    d = xmldoc.get_w_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'), 0.0)

@testattr(stddist = True)
def t_get_u_initial_guess_values(xmldoc):
    d = xmldoc.get_u_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'),350.0)

@testattr(stddist = True)
def t_get_dx_initial_guess_values(xmldoc):
    d = xmldoc.get_dx_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('der(cost)'),0.0)

@testattr(stddist = True)
def t_get_x_initial_guess_values(xmldoc):
    d = xmldoc.get_x_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('cstr.c'),300.0)

@testattr(stddist = True)
def t_get_p_opt_initial_guess_values(xmldoc):
    d = xmldoc.get_p_opt_initial_guess_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('sys.w'),2.0)

@testattr(stddist = True)
def t_get_w_lb_values(xmldoc):
    d = xmldoc.get_w_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfiles

@testattr(stddist = True)
def t_get_u_lb_values(xmldoc):
    d = xmldoc.get_u_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'),-1.0)

@testattr(stddist = True)
def t_get_dx_lb_values(xmldoc):
    d = xmldoc.get_dx_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_x_lb_values(xmldoc):
    d = xmldoc.get_x_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_p_opt_lb_values(xmldoc):
    d = xmldoc.get_p_opt_lb_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('tf'),0.2)

@testattr(stddist = True)
def t_get_w_ub_values(xmldoc):
    d = xmldoc.get_w_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_u_ub_values(xmldoc):
    d = xmldoc.get_u_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    nose.tools.assert_equal(d.get('u'),1.0)

@testattr(stddist = True)
def t_get_dx_ub_values(xmldoc):
    d = xmldoc.get_dx_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_x_ub_values(xmldoc):
    d = xmldoc.get_x_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_p_opt_ub_values(xmldoc):
    d = xmldoc.get_p_opt_ub_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
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
    # no example in testfile

@testattr(stddist = True)
def t_get_w_lin_values(xmldoc):
    d = xmldoc.get_w_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is bool, \
                "Is linear value is not bool."
    nose.tools.assert_equal(d.get('u'),False)

@testattr(stddist = True)
def t_get_u_lin_values(xmldoc):
    d = xmldoc.get_u_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is bool, \
                "Is linear value is not bool."
    nose.tools.assert_equal(d.get('u'),False)

@testattr(stddist = True)
def t_get_dx_lin_values(xmldoc):
    d = xmldoc.get_dx_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is bool, \
                "Is linear value is not bool."
    nose.tools.assert_equal(d.get('der(cost)'),True)

@testattr(stddist = True)
def t_get_x_lin_values(xmldoc):
    d = xmldoc.get_x_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is bool, \
                "Is linear value is not bool."
    nose.tools.assert_equal(d.get('cstr.T'),False)

@testattr(stddist = True)
def t_get_p_opt_lin_values(xmldoc):
    d = xmldoc.get_p_opt_lin_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        assert value.__class__ is bool, \
                "Is linear value is not bool."
    nose.tools.assert_equal(d.get('sys.z'),False)

@testattr(stddist = True)
def t_get_w_lin_tp_values(xmldoc):
    d = xmldoc.get_w_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."
    tps = d.get('u')
    nose.tools.assert_equal(len(tps),11)
    nose.tools.assert_equal(tps[0],True)

@testattr(stddist = True)
def t_get_u_lin_tp_values(xmldoc):
    d = xmldoc.get_u_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."
    tps = d.get('u')
    nose.tools.assert_equal(tps[0],True)

@testattr(stddist = True)
def t_get_dx_lin_tp_values(xmldoc):
    d = xmldoc.get_dx_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."
    tps = d.get('der(cost)')
    nose.tools.assert_equal(tps[0],True)

@testattr(stddist = True)
def t_get_x_lin_tp_values(xmldoc):
    d = xmldoc.get_x_lin_tp_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
            "Variable name is not string"
        for val in value:
            assert val.__class__ is bool, \
                "Time point value is not bool."
    tps = d.get('cstr.c')
    nose.tools.assert_equal(tps[0],True)    
                
@testattr(stddist = True)
def t_get_iparam_values(xmldoc):
    d = xmldoc.get_iparam_values()
    for key, value in d.iteritems():
        assert key.__class__ is str, \
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
    nose.tools.assert_equal(d.get('cstr.T0'), 350.0)

@testattr(stddist = True)
def t_get_starttime(xmldoc):
    time = xmldoc.get_starttime()
    assert time.__class__ is float, \
        "XMLDoc.get_starttime did not return float."
    nose.tools.assert_equal(time,0.0)
    
@testattr(stddist = True)
def t_get_starttime_free(xmldoc):
    b = xmldoc.get_starttime_free()
    assert b.__class__ is bool, \
            "XMLDoc.get_starttime_free did not return boolean."
    nose.tools.assert_equal(b, False)
    
@testattr(stddist = True)
def t_get_finaltime(xmldoc):
    time = xmldoc.get_finaltime()
    assert time.__class__ is float, \
        "XMLDoc.get_finaltime did not return float."
    nose.tools.assert_equal(time,150.0)
    
@testattr(stddist = True)
def t_get_finaltime_free(xmldoc):
    b = xmldoc.get_finaltime_free()
    assert b.__class__ is bool, \
            "XMLDoc.get_finaltime_free did not return boolean."
    nose.tools.assert_equal(b, False)
    
@testattr(stddist = True)
def t_get_timepoints(xmldoc):
    timepoints = xmldoc.get_timepoints()
    for tp in timepoints:
        assert tp.__class__ is float, \
            "timepoint is not float."
    nose.tools.assert_equal(timepoints[0], 150.0)
    
# @testattr(stddist = True)
# def test_fmi_schema():
#     """ Test that generated XML file validates with the fmi schema. """
#     mc.set_boolean_option('generate_fmi_xml', True)
#     mc.set_boolean_option('generate_xml_equations', False)
    
#     model_mc = os.path.join('files', 'Pendulum_pack_no_opt.mo')
#     fpath_mc = os.path.join(jm_home,path_to_examples,model_mc)
#     cpath_mc = "Pendulum_pack.Pendulum"
    
#     mc.compile_model(fpath_mc, cpath_mc)
#     fname = cpath_mc.replace('.','_',1)
#     filename = fname+'.xml'
    
#     schema = 'fmiModelDescription.xsd'
#     path_to_schema = os.path.join(path_to_schemas,schema)
    
#     xmldoc = xp.XMLDoc(filename,schemaname=path_to_schema)
    
    
## Commented out tests due to #729
    
#@testattr(stddist = True)
#def test_extended_fmi_schema():
#    """ Test that generated XML file validates with the extended fmi schema. """
#    mc.set_boolean_option('generate_fmi_xml', True)
#    mc.set_boolean_option('generate_xml_equations', True)
#    
#    model_mc = os.path.join('files', 'Pendulum_pack_no_opt.mo')
#    fpath_mc = os.path.join(jm_home,path_to_examples,model_mc)
#    cpath_mc = "Pendulum_pack.Pendulum"
#    
#    mc.compile_model(fpath_mc, cpath_mc)
#    fname = cpath_mc.replace('.','_',1)
#    filename = fname+'.xml'
#    
#    schema = 'fmiExtendedModelDescription.xsd'
#    path_to_schema = os.path.join(path_to_schemas,schema)
#    
#    xmldoc = xp.XMLDoc(filename,schemaname=path_to_schema)
    
#@testattr(stddist = True)
#def test_jmodelica_schema():
#    """ Test that generated XML file validates with the jmodelica schema. """
#    mc.set_boolean_option('generate_fmi_xml', False)
#    mc.set_boolean_option('generate_xml_equations', True)
#    
#    model_mc = os.path.join('files', 'Pendulum_pack_no_opt.mo')
#    fpath_mc = os.path.join(jm_home,path_to_examples,model_mc)
#    cpath_mc = "Pendulum_pack.Pendulum"
#    
#    mc.compile_model(fpath_mc, cpath_mc)
#    fname = cpath_mc.replace('.','_',1)
#    filename = fname+'.xml'
#    
#    schema = 'jmodelicaModelDescription.xsd'
#    path_to_schema = os.path.join(path_to_schemas,schema)
#    
#    xmldoc = xp.XMLDoc(filename,schemaname=path_to_schema)
#    
#@testattr(stddist = True)
#def test_jmodelica_schema_2():
#    """ Test that generated XML file validates with the jmodelica schema. """
#    mc.set_boolean_option('generate_fmi_xml', False)
#    mc.set_boolean_option('generate_xml_equations', False)
#    
#    model_mc = os.path.join('files', 'Pendulum_pack_no_opt.mo')
#    fpath_mc = os.path.join(jm_home,path_to_examples,model_mc)
#    cpath_mc = "Pendulum_pack.Pendulum"
#    
#    mc.compile_model(fpath_mc, cpath_mc)
#    fname = cpath_mc.replace('.','_',1)
#    filename = fname+'.xml'
#    
#    schema = 'jmodelicaModelDescription.xsd'
#    path_to_schema = os.path.join(path_to_schemas,schema)
#    
#    xmldoc = xp.XMLDoc(filename,schemaname=path_to_schema)
    
#@testattr(stddist = True)
#def test_extended_fmi_schema_opt():
#    """ Test that generated XML file validates with the extended fmi schema. """
#    oc.set_boolean_option('generate_fmi_xml', True)
#    oc.set_boolean_option('generate_xml_equations', True)
#    oc.compile_model(parest_fpath, parest_cpath)
#    fname = parest_cpath.replace('.','_',1)
#    filename = fname+'.xml'
#    
#    schema = 'fmiExtendedModelDescription.xsd'
#    path_to_schema = os.path.join(path_to_schemas,schema)
#    
#    xmldoc = xp.XMLDoc(filename,schemaname=path_to_schema)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
