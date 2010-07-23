# -*- coding: utf-8 -*-
"""Module containing XML parser and validator providing an XML object which 
can be used to extract information from the parsed XML file using XPath 
queries.
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

from lxml import etree
import os.path
import numpy as N

int = N.int32
N.int = N.int32
uint = N.uint32

# Alias data
NO_ALIAS = 0
ALIAS = 1
NEGATED_ALIAS = -1

# Variability
CONTINUOUS = 0
CONSTANT = 1
PARAMETER = 2
DISCRETE = 3

# Variable category
ALGEBRAIC = 0
STATE = 1
DEPENDENT_CONSTANT = 2
INDEPENDENT_CONSTANT = 3
DEPENDENT_PARAMETER = 4
INDEPENDENT_PARAMETER = 5
DERIVATIVE = 6

# causality
INTERNAL = 0
INPUT = 1
OUTPUT = 2
NONE = 3

# types
REAL = 0
INTEGER = 1
STRING = 2
BOOLEAN = 3
ENUMERATION = 4

#=======================================================================


def _translate_xmlbool(xmlbool):
    if xmlbool == 'false':
        return False
    elif xmlbool == 'true':
        return True
    else:
        raise Exception('The xml boolean '+str(xmlbool)+
            ' does not have a valid value.')
            
def _translate_variability(variability):
    if variability == "continuous":
        return CONTINUOUS
    elif variability == "constant":
        return CONSTANT
    elif variability == "parameter":
        return PARAMETER
    elif variability == "discrete":
        return DISCRETE
    else:
        raise XMLException("Variability: "+str(variability)+" is unknown.")

def _translate_alias(alias):
    if alias == "noAlias":
        return NO_ALIAS
    elif alias == "alias":
        return ALIAS
    elif alias == "negatedAlias":
        return NEGATED_ALIAS
    else:
        raise XMLException("Alias: "+ str(alias) + " is unknown.")
            
def _translate_variable_category(category):
    if category == "algebraic":
        return ALGEBRAIC
    elif category == "state":
        return STATE
    elif category == "dependentConstant":
        return DEPENDENT_CONSTANT
    elif category == "independentConstant":
        return INDEPENDENT_CONSTANT
    elif category == "dependentParameter":
        return DEPENDENT_PARAMETER
    elif category == "independentParameter":
        return INDEPENDENT_PARAMETER
    elif category == "derivative":
        return DERIVATIVE
    else:
        raise XMLException("Variable category: "+str(category)+" is unknown.")
    
def _translate_causality(causality):
    if causality == "internal":
        return INTERNAL
    elif causality == "input":
        return INPUT
    elif causality == "output":
        return OUTPUT
    elif causality == "none":
        return NONE
    else:
        raise XMLException("Causality: "+str(causality)+" is unknown.")

def _parse_XML(filename, schemaname=''):

    """ 
    Parses and validates (optional) an XML file.

    Parses an XML file and returns an object representing the parsed 
    XML. If the optional parameter schemaname is set the XML file is 
    also validated against the XML Schema file provided before 
    parsing. 

    Parameters:
        filename -- 
            Name of XML file to parse including absolute or relative 
            path.
        schemaname --
            Name of XML Schema file including absolute or relative 
            path.
    
    Exceptions:   
        XMLException -- 
            If the XML file can not be read or is not well-formed. 
            If a schema is present and if the schema file can not be 
            read, is not well-formed or if the validation fails. 
    
    Returns:    
        Reference to the ElementTree object containing the parsed XML.
    
    """

    try:
        element_tree = etree.ElementTree(file=filename)
    except etree.XMLSyntaxError, detail:
        raise XMLException("The XML file: %s is not well-formed. %s" 
            %(filename, detail))

    if schemaname:
        try:
            schemadoc = etree.ElementTree(file=schemaname)
        except etree.XMLSyntaxError, detail:
            raise XMLException("The XMLSchema: %s is not well-formed. %s" 
                %(schemaname, detail))         
        
        schema = etree.XMLSchema(schemadoc)
    
        result = schema.validate(xmldoc)
    
        if not result:
            raise XMLException("The XML file: %s is not valid \
                according to the XMLSchema: %s." 
                %(filename, schemaname))
    
    return element_tree

class ModelDescription:

    def __init__(self, filename, schemaname=''):
        """ 
        Create an XML document object representation and an XPath 
        evaluator.
        
        Parse an XML document and create an XML document object 
        representation. Validate against XML schema before parsing if 
        the parameter schemaname is set. Instantiates an XPath evaluator 
        object for the parsed XML which can be used to evaluate XPath 
        expressions on the XML.
         
        """
        # set up cache, parse XML file and obtain the root
        self.function_cache = XMLFunctionCache()
        element_tree = _parse_XML(filename, schemaname)
        root = element_tree.getroot()
        
        # populate vref tuple already here in init (done during 
        # _parse_element_tree) since this tuple will be used in almost 
        # all "complex methods"
        self._vrefs = []
        self._vrefs_noAlias = []
        
        # build internal data structure from XML file
        self._parse_element_tree(root)
        
        # create tuple
        self._vrefs = tuple(self._vrefs)
        self._vrefs_noAlias = tuple(self._vrefs_noAlias)

    def _parse_element_tree(self, root):
        """ Parse the XML element tree and build up internal data 
            structure. """
        
        # model (root) attributes
        self._fill_attributes(root)
            
        # unit definitions
        self._fill_unit_definitions(root)
        
        # type definitions
        self._fill_type_definitions(root)
        
        # default experiment
        self._fill_default_experiment(root)
        
        # vendor annotations
        self._fill_vendor_annotations(root)
        
        # model variables
        self._fill_model_variables(root)
        
        # fill optimization
        self._fill_optimization(root)
      
    def _fill_attributes(self, root):
        # declare attributes with default values
        self._attributes = {'fmiVersion':'',
                           'modelName':'',
                           'modelIdentifier':'',
                           'guid':'',
                           'description':'',
                           'author':'',
                           'version':'',
                           'generationTool':'',
                           'generationDateAndTime':'',
                           'variableNamingConvention':'flat',
                           'numberOfContinuousStates':'',
                           'numberOfEventIndicators':''}
                           
        # update attribute dict with attributes from XML file
        self._attributes.update(root.attrib) 
            
    def _fill_unit_definitions(self, root):
        self._unit_definitions = []
        
        e_unitdefs = root.find('UnitDefinitions')
        if e_unitdefs != None:
            # list of base units (xml elements)
            e_baseunits = e_unitdefs.getchildren()
            for e_baseunit in e_baseunits:
                self._unit_definitions.append(BaseUnit(e_baseunit))
                
    def _fill_type_definitions(self, root):
        self._type_definitions = []
        
        e_typedefs = root.find('TypeDefinitions')
        if e_typedefs != None:
            # list of types
            e_types = e_typedefs.getchildren()
            for e_type in e_types:
                self._type_definitions.append(Type(e_type))
                
    def _fill_default_experiment(self, root):
        self._default_experiment = None
        
        e_defaultexperiment = root.find('DefaultExperiment')
        if e_defaultexperiment != None:
            self._default_experiment = DefaultExperiment(
                e_defaultexperiment)
    
    def _fill_vendor_annotations(self, root):
        self._vendor_annotations = []
        
        e_vendorannotations = root.find('VendorAnnotations')
        if e_vendorannotations != None:
            # list of tools
            e_tools = e_vendorannotations.getchildren()
            for e_tool in e_tools:
                self._vendor_annotations.append(Tool(e_tool))
                
    def _fill_model_variables(self, root):
        self._model_variables = []
        self._model_variables_dict = {}
        
        e_modelvariables = root.find('ModelVariables')
        if e_modelvariables != None:
            # list of scalar variables
            e_scalarvariables = e_modelvariables.getchildren()
            for e_scalarvariable in e_scalarvariables:
                sv = ScalarVariable(e_scalarvariable)
                self._model_variables.append(sv)
                
                # fill model variables dicts
                self._model_variables_dict[sv.get_name()] = sv
                
                # fill vref and vref no alias lists
                self._vrefs.append(sv.get_value_reference())
                if sv.get_alias() == NO_ALIAS:
                    self._vrefs_noAlias.append(sv.get_value_reference())
                
    def _fill_optimization(self, root):
        self._optimization = None
        
        try:
            opt=root.nsmap['opt']
        except KeyError:
            # no optimization part in xml
            return
            
        ns="{"+opt+"}"
        e_optimization = root.find(ns+'Optimization')
        if e_optimization != None:
            self._optimization = Optimization(e_optimization)
            
    def get_fmi_version(self):
        return self._attributes['fmiVersion']
        
    def get_model_name(self):
        return self._attributes['modelName']
        
    def get_model_identifier(self):
        return self._attributes['modelIdentifier']
        
    def get_guid(self):
        return self._attributes['guid']
        
    def get_description(self):
        return self._attributes['description']
    
    def get_author(self):
        return self._attributes['author']
        
    def get_version(self):
        if self._attributes['version'] == '':
            return None
        return float(self._attributes['version'])
        
    def get_generation_tool(self):
        return self._attributes['generationTool']
        
    def get_generation_date_and_time(self):
        return self._attributes['generationDateAndTime']
        
    def get_variable_naming_convention(self):
        return self._attributes['variableNamingConvention']
        
    def get_number_of_continuous_states(self):
        if self._attributes['numberOfContinuousStates'] == '':
            return None
        return int(self._attributes['numberOfContinuousStates'])
        
    def get_number_of_event_indicators(self):
        if self._attributes['numberOfEventIndicators'] == '':
            return None
        return int(self._attributes['numberOfEventIndicators'])
        
    def get_unit_definitions(self):
        return self._unit_definitions
        
    def get_type_definitions(self):
        return self._type_definitions
        
    def get_default_experiment(self):
        return self._default_experiment
        
    def get_vendor_annotations(self):
        return self._vendor_annotations
        
    def get_model_variables(self):
        return self._model_variables
        
    def get_optimization(self):
        return self._optimization
        
    # ========== Here begins the more complex functions ================
    
    def get_value_reference(self, variablename, ignore_cache=False):
        """
        Get the value reference given a variable name.
        
        Parameters:
            variablename -- the name of the variable
            
        Returns:
            The value reference for the variable passed as argument. 
        
        Raises exception if variable was not found.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_value_reference', 
                variablename)
                
        sv = self._model_variables_dict.get(variablename)
        if sv != None:
            return sv.get_value_reference()
        else:
            raise XMLException("Variable: "+str(variablename)+" was not \
                found in model.")
        
    def is_alias(self, variablename, ignore_cache=False):
        """ Return true is variable is an alias or negated alias.
        
        Raises exception if variable was not found.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_alias', 
                variablename)
                
        sv = self._model_variables_dict.get(variablename)
        if sv != None:
            return (sv.get_alias() != NO_ALIAS)
        else:
            raise XMLException("Variable: "+str(variablename)+" was not \
                found in model.")

    def is_negated_alias(self, variablename, ignore_cache=False):
        """ Return true is variable is a negated alias. 
        
        Raises exception if variable was not found.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_negated_alias', 
                variablename)
                
        sv = self._model_variables_dict.get(variablename)
        if sv != None:
            return (sv.get_alias() == NEGATED_ALIAS)
        else:
            raise XMLException("Variable: "+str(variablename)+" was not \
                found in model.")
        
    def is_constant(self, variablename, ignore_cache=False):
        """ Return true if variable is a constant and false if not. 
        
        Raises exception if variable was not found.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_constant', 
                variablename)
                
        sv = self._model_variables_dict.get(variablename)
        if sv != None:
            return sv.get_variability() == CONSTANT
        else:
            raise XMLException("Variable: "+str(variablename)+" was not \
                found in model.")
        
    def get_data_type(self, variablename, ignore_cache=False):
        """ Get data type of variable. 
        
        Returns: Variable type, REAL, INTEGER, BOOLEAN or STRING.
        
        Raises exception if variable was not found.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_data_type', 
                variablename)
                
        sv = self._model_variables_dict.get(variablename)
        if sv != None:
            type = sv.get_fundamental_type()
            if isinstance(type, Real):
                return REAL
            elif isinstance(type, Integer):
                return INTEGER
            elif isinstance(type, String):
                return STRING
            elif isinstance(type, Boolean):
                return BOOLEAN
            elif isinstance(type, Enumeration):
                return ENUMERATION
            else:
                raise XMLException("Unknown type for variable: "+ 
                    str(variablename))
        else:
            raise XMLException("Variable: "+str(variablename)+" was not \
                found in model.")

    def get_aliases_for_variable(self, variablename, ignore_cache=False):
        """ Return list of all alias variables belonging to the aliased 
            variable along with a list of booleans indicating whether the 
            alias variable should be negated or not.
            
            Returns empty lists if variable has no alias variables.
            
            Returns None if variable cannot be found in model.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_aliases_for_variable', 
                variablename)
                
        aliasnames = []
        isnegated = []
        
        variable = self._model_variables_dict.get(variablename)
        if variable != None:
            for sv in self.get_model_variables():
                if sv.get_value_reference() == variable.get_value_reference() and \
                    sv.get_name()!=variablename:
                    aliasnames.append(sv.get_name())
                    isnegated.append(sv.get_alias()== NEGATED_ALIAS)
            return aliasnames, isnegated
        return None

    def get_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the variables in a model.

        Returns:
            List of tuples containing value references and names 
            respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_names',
                include_alias)

        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                names.append(sv.get_name())
            return zip(tuple(self._vrefs),tuple(names))

        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS:
                names.append(sv.get_name())
        return zip(tuple(self._vrefs_noAlias),tuple(names))
        
        
    def get_variable_aliases(self, ignore_cache=False):
        """ Extract the alias data for each variable in the model.
        
        Returns:
            List of tuples containing value references and alias data 
            respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_aliases')
        
        alias_data = []
        scalarvariables = self.get_model_variables()
        for sv in scalarvariables:
            alias_data.append(sv.get_alias())
        return zip(tuple(self._vrefs),tuple(alias_data))

    def get_variable_descriptions(self, include_alias=True, 
        ignore_cache=False):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            List of tuples containing value reference and description 
            respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_variable_descriptions', include_alias)
            
        descriptions = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                descriptions.append(sv.get_description())
            return zip(tuple(self._vrefs),tuple(descriptions))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS:
                descriptions.append(sv.get_description())
        return zip(tuple(self._vrefs_noAlias),tuple(descriptions))
        
    def get_variable_variabilities(self, include_alias=True, 
        ignore_cache=False):
        """ Get the variability of the variables in the model.
        
        Returns:
            List of tuples containing value reference and variability 
            respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_variable_variabilities', include_alias)
        
        variabilities = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                variabilities.append(sv.get_variability())
            return zip(tuple(self._vrefs),tuple(variabilities))
        
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS:
                variabilities.append(sv.get_variability())
        return zip(tuple(self._vrefs_noAlias),tuple(variabilities))

    def get_variable_nominal_attributes(self, include_alias=True, 
            ignore_cache=False):
        """ Get the nominal attribute of the variables in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            nominal attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_variable_nominal_attributes', include_alias)
        
        nominals = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if isinstance(ftype, Real):
                    nominals.append(ftype.get_nominal())
                else:
                    nominals.append(None)
            return zip(tuple(self._vrefs),tuple(nominals))
        
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if sv.get_alias() == NO_ALIAS:
                if isinstance(ftype, Real):
                    nominals.append(ftype.get_nominal())
                else:
                    nominals.append(None)
        return zip(tuple(self._vrefs_noAlias),tuple(nominals))

    def get_variable_start_attributes(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the variables in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_variable_start_attributes', include_alias)
        
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                start_attributes.append(
                    sv.get_fundamental_type().get_start())
            return zip(tuple(self._vrefs), tuple(start_attributes))
       
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS:
                start_attributes.append(
                    sv.get_fundamental_type().get_start())
        return zip(tuple(self._vrefs_noAlias), tuple(start_attributes))
        
    def get_all_real_variables(self, include_alias=True, 
        ignore_cache=False):
        """ Get all real variables in the model.
        
        Returns:
            List of all ScalarVariables of type Real.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_all_real_variables', include_alias)
                
        return self._get_all_variables(Real, include_alias)
        
    def get_all_string_variables(self, include_alias=True, 
        ignore_cache=False):
        """ Get all string variables in the model.
        
        Returns:
            List of all ScalarVariables of type String.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_all_string_variables', include_alias)
                
        return self._get_all_variables(String, include_alias)
        
    def get_all_integer_variables(self, include_alias=True, 
        ignore_cache=False):
        """ Get all integer variables in the model.
        
        Returns:
            List of all ScalarVariables of type Integer.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_all_integer_variables', include_alias)
                
        return self._get_all_variables(Integer, include_alias)

    def get_all_boolean_variables(self, include_alias=True, 
        ignore_cache=False):
        """ Get all boolean variables in the model.
        
        Returns:
            List of all ScalarVariables of type Boolean.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_all_boolean_variables', include_alias)
                
        return self._get_all_variables(Boolean, include_alias)

        
    def _get_all_variables(self, type, include_alias):
        
        typevars = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if isinstance(sv.get_fundamental_type(), type):
                    typevars.append(sv)
            return typevars
            
        for sv in scalarvariables:
            if isinstance(sv.get_fundamental_type(), type) and \
                sv.get_alias() == NO_ALIAS:
                    typevars.append(sv)
        return typevars

    def get_p_opt_variable_names(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get the names of all optimized independent parameters.
        
        Returns:
            List of tuples containing value reference and name 
            respectively.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_p_opt_variable_names', include_alias)
        
        vrefs = []
        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variability() == PARAMETER and \
                    sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
            return zip(tuple(vrefs), tuple(names))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variability() == PARAMETER and \
                sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
        return zip(tuple(vrefs), tuple(names))
                
    def get_dx_variable_names(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get the names of all derivatives.
        
        Returns:
            List of tuples containing value reference and name 
            respectively.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_variable_names', include_alias)
        
        vrefs = []
        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
            return zip(tuple(vrefs), tuple(names))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
        return zip(tuple(vrefs), tuple(names))
                    
    def get_x_variable_names(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get the names of all states.
        
        Returns:
            List of tuples containing value reference and name 
            respectively.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_variable_names', include_alias)
        
        vrefs = []
        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
            return zip(tuple(vrefs), tuple(names))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
        return zip(tuple(vrefs), tuple(names))
                    
    def get_u_variable_names(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get the names of all inputs.
        
        Returns:
            List of tuples containing value reference and name 
            respectively.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_variable_names', include_alias)
        
        vrefs = []
        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
            return zip(tuple(vrefs), tuple(names))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_causality() == INPUT and \
               sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
        return zip(tuple(vrefs), tuple(names))

    def get_w_variable_names(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get the names of all algebraic variables.
        
        Returns:
            List of tuples containing value reference and name 
            respectively.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_variable_names', include_alias)
        
        vrefs = []
        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
            return zip(tuple(vrefs), tuple(names))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_causality() != INPUT and \
               sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    names.append(sv.get_name())
        return zip(tuple(vrefs), tuple(names))

    def get_p_opt_start(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the independent paramenters 
            (variability:parameter, free: true) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_p_opt_start', include_alias)
        
        vrefs = []
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variability() == PARAMETER and \
                    sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
            return zip(tuple(vrefs), tuple(start_attributes))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variability() == PARAMETER and \
                sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
        return zip(tuple(vrefs), tuple(start_attributes))
                
    def get_dx_start(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the derivatives 
            (variable_category:derivative) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_start', include_alias)
        
        vrefs = []
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
            return zip(tuple(vrefs), tuple(start_attributes))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
        return zip(tuple(vrefs), tuple(start_attributes))
                    
    def get_x_start(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the states 
            (variable_category:state) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_start', include_alias)
        
        vrefs = []
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
            return zip(tuple(vrefs), tuple(start_attributes))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
        return zip(tuple(vrefs), tuple(start_attributes))
                    
    def get_u_start(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the inputs 
            (variable_category:algebraic, causality: input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_start', include_alias)
        
        vrefs = []
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
            return zip(tuple(vrefs), tuple(start_attributes))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_causality() == INPUT and \
               sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
        return zip(tuple(vrefs), tuple(start_attributes))

    def get_w_start(self, include_alias=True, 
        ignore_cache=False):
        """ Get the start attributes of the algebraic variables 
            (variable_category:algebraic, causality: not input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            start attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_start', include_alias)
        
        vrefs = []
        start_attributes = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
            return zip(tuple(vrefs), tuple(start_attributes))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
               sv.get_causality() != INPUT and \
               sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    start_attributes.append(sv.get_fundamental_type().get_start())
        return zip(tuple(vrefs), tuple(start_attributes))

    def get_p_opt_initial_guess(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and initial guess attribute for all optimized 
        independent parameters (variability:parameter, free: true).
        
        Returns:
            List of tuples containing value reference and value of 
            initial guess attribute respectively.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_initial_guess', include_alias)
        vrefs = []
        initial_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Enumeration) and \
                    sv.get_variability() == PARAMETER and \
                    ftype.get_free() == True:
                        
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
            return zip(tuple(vrefs), tuple(initial_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Enumeration) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variability() == PARAMETER and \
                ftype.get_free() == True:
                    
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
        return zip(tuple(vrefs), tuple(initial_values))

    def get_dx_initial_guess(self, include_alias=True, 
        ignore_cache=False):
        """ Get the initial guess attribute of the derivatives 
            (variable_category:derivative) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            initial guess attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_initial_guess', include_alias)
        
        vrefs = []
        initial_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Enumeration) and \
                    sv.get_variable_category() == DERIVATIVE:
                        
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
            return zip(tuple(vrefs), tuple(initial_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Enumeration) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == DERIVATIVE:
                   
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
        return zip(tuple(vrefs), tuple(initial_values))

    def get_x_initial_guess(self, include_alias=True, 
        ignore_cache=False):
        """ Get the initial guess attributes of the states 
            (variable_category:state) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            initial guess attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_initial_guess', include_alias)
        
        vrefs = []
        initial_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Enumeration) and \
                    sv.get_variable_category() == STATE:
                    
                        vrefs.append(sv.get_value_reference())
                        initial_values.append(ftype.get_initial_guess())
            return zip(tuple(vrefs), tuple(initial_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Enumeration) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == STATE:
                    
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
        return zip(tuple(vrefs), tuple(initial_values))

    def get_u_initial_guess(self, include_alias=True, 
        ignore_cache=False):
        """ Get the initial guess attributes of the inputs 
            (variable_category:algebraic, causality: input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            initial guess attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_initial_guess', include_alias)
        
        vrefs = []
        initial_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Enumeration) and \
                    sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                    
                        vrefs.append(sv.get_value_reference())
                        initial_values.append(ftype.get_initial_guess())
            return zip(tuple(vrefs), tuple(initial_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Enumeration) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
        return zip(tuple(vrefs), tuple(initial_values))

    def get_w_initial_guess(self, include_alias=True, 
        ignore_cache=False):
        """ Get the initial guess attributes of the algebraic variables 
            (variable_category:algebraic, causality: not input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            initial guess attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_initial_guess', include_alias)
        
        vrefs = []
        initial_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Enumeration) and \
                    sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                        
                        vrefs.append(sv.get_value_reference())
                        initial_values.append(ftype.get_initial_guess())
            return zip(tuple(vrefs), tuple(initial_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Enumeration) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    initial_values.append(ftype.get_initial_guess())
        return zip(tuple(vrefs), tuple(initial_values))

    def get_p_opt_min(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and min attribute for all optimized 
        independent parameters (variability:parameter, free: true).
        
        Returns:
            List of tuples containing value reference and value of 
            min attribute respectively.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_min', include_alias)
        vrefs = []
        min_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variability() == PARAMETER and \
                    ftype.get_free() == True:
                        
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
            return zip(tuple(vrefs), tuple(min_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variability() == PARAMETER and \
                ftype.get_free() == True:
                    
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
        return zip(tuple(vrefs), tuple(min_values))

    def get_dx_min(self, include_alias=True, 
        ignore_cache=False):
        """ Get the min attribute of the derivatives 
            (variable_category:derivative) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            min attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_min', include_alias)
        
        vrefs = []
        min_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variable_category() == DERIVATIVE:
                        
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
            return zip(tuple(vrefs), tuple(min_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == DERIVATIVE:
                   
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
        return zip(tuple(vrefs), tuple(min_values))

    def get_x_min(self, include_alias=True, 
        ignore_cache=False):
        """ Get the min attributes of the states 
            (variable_category:state) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            min attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_min', include_alias)
        
        vrefs = []
        min_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variable_category() == STATE:
                        
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
            return zip(tuple(vrefs), tuple(min_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == STATE:
                    
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
        return zip(tuple(vrefs), tuple(min_values))

    def get_u_min(self, include_alias=True, 
        ignore_cache=False):
        """ Get the min attributes of the inputs 
            (variable_category:algebraic, causality: input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            min attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_min', include_alias)
        
        vrefs = []
        min_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                        
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
            return zip(tuple(vrefs), tuple(min_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
        return zip(tuple(vrefs), tuple(min_values))

    def get_w_min(self, include_alias=True, 
        ignore_cache=False):
        """ Get the min attributes of the algebraic variables 
            (variable_category:algebraic, causality: not input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            min attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_min', include_alias)
        
        vrefs = []
        min_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                        
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
            return zip(tuple(vrefs), tuple(min_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    min_values.append(ftype.get_min())
        return zip(tuple(vrefs), tuple(min_values))

    def get_p_opt_max(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and max attribute for all optimized 
        independent parameters (variability:parameter, free: true).
        
        Returns:
            List of tuples containing value reference and value of 
            max attribute respectively.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_max', include_alias)
        vrefs = []
        max_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variability() == PARAMETER and \
                    ftype.get_free() == True:
                        
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
            return zip(tuple(vrefs), tuple(max_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variability() == PARAMETER and \
                ftype.get_free() == True:
                    
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
        return zip(tuple(vrefs), tuple(max_values))

    def get_dx_max(self, include_alias=True, 
        ignore_cache=False):
        """ Get the max attribute of the derivatives 
            (variable_category:derivative) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            max attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_max', include_alias)
        
        vrefs = []
        max_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variable_category() == DERIVATIVE:
                        
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
            return zip(tuple(vrefs), tuple(max_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == DERIVATIVE:
                   
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
        return zip(tuple(vrefs), tuple(max_values))

    def get_x_max(self, include_alias=True, 
        ignore_cache=False):
        """ Get the max attributes of the states 
            (variable_category:state) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            max attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_max', include_alias)
        
        vrefs = []
        max_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_variable_category() == STATE:
                        
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
            return zip(tuple(vrefs), tuple(max_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == STATE:
                    
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
        return zip(tuple(vrefs), tuple(max_values))

    def get_u_max(self, include_alias=True, 
        ignore_cache=False):
        """ Get the max attributes of the inputs 
            (variable_category:algebraic, causality: input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            max attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_max', include_alias)
        
        vrefs = []
        max_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                        
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
            return zip(tuple(vrefs), tuple(max_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
        return zip(tuple(vrefs), tuple(max_values))

    def get_w_max(self, include_alias=True, 
        ignore_cache=False):
        """ Get the max attributes of the algebraic variables 
            (variable_category:algebraic, causality: not input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            max attribute respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_max', include_alias)
        
        vrefs = []
        max_values = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                ftype = sv.get_fundamental_type()
                if not isinstance(ftype, String) and not \
                    isinstance(ftype, Boolean) and \
                    sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                        
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
            return zip(tuple(vrefs), tuple(max_values))
            
        for sv in scalarvariables:
            ftype = sv.get_fundamental_type()
            if not isinstance(ftype, String) and not \
                isinstance(ftype, Boolean) and \
                sv.get_alias() == NO_ALIAS and \
                sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    
                    vrefs.append(sv.get_value_reference())
                    max_values.append(ftype.get_max())
        return zip(tuple(vrefs), tuple(max_values))

    def get_p_opt_islinear(self, include_alias=True, ignore_cache=False):
        """ 
        Get value reference and boolean value describing if variable 
        appears linearly in all equations and constraints for all optimized 
        independent parameters.
        
        Returns:
            List of tuples containing value reference and value of 
            is linear element respectively.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_islinear', include_alias)

        vrefs = []
        is_linear = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variability() == PARAMETER and \
                    sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
            return zip(tuple(vrefs), tuple(is_linear))
            
        for sv in scalarvariables:
            if sv.get_variability() == PARAMETER and \
                sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
        return zip(tuple(vrefs), tuple(is_linear))

    def get_dx_islinear(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and boolean value describing if variable 
        appears linearly in all equations and constraints for all 
        derivatives (variable_category:derivative) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            is linear element respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_islinear', include_alias)
        
        vrefs = []
        is_linear = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
            return zip(tuple(vrefs), tuple(is_linear))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == DERIVATIVE:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
        return zip(tuple(vrefs), tuple(is_linear))

    def get_x_islinear(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and boolean value describing if variable 
        appears linearly in all equations and constraints for all states 
        (variable_category:state) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            is linear element respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_islinear', include_alias)
        
        vrefs = []
        is_linear = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
            return zip(tuple(vrefs), tuple(is_linear))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == STATE:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
        return zip(tuple(vrefs), tuple(is_linear))

    def get_u_islinear(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and boolean value describing if variable 
        appears linearly in all equations and constraints for all inputs 
        (variable_category:algebraic, causality: input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            is linear element respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_islinear', include_alias)
        
        vrefs = []
        is_linear = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
            return zip(tuple(vrefs), tuple(is_linear))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_causality() == INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
        return zip(tuple(vrefs), tuple(is_linear))

    def get_w_islinear(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and boolean value describing if variable 
        appears linearly in all equations and constraints for all 
        algebraic variables (variable_category:algebraic, 
        causality: not input) in the model.
        
        Returns:
            List of tuples containing value reference and value of 
            is linear element respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_islinear', 
                include_alias)
        
        vrefs = []
        is_linear = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
            return zip(tuple(vrefs), tuple(is_linear))
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_causality() != INPUT and \
                sv.get_variable_category() == ALGEBRAIC:
                    vrefs.append(sv.get_value_reference())
                    is_linear.append(sv.get_is_linear())
        return zip(tuple(vrefs), tuple(is_linear))
        
    def get_dx_linear_timed_variables(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and linear timed variables for all derivatives 
        (variable_category:derivative) in the model.

        Returns:
            List of tuples with value reference and list of linear time 
            variables respectively. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_dx_linear_timed_variables', include_alias)

        tot_timepoints = []
        scalarvariables = self.get_model_variables()

        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == DERIVATIVE:
                    vref = sv.get_value_reference()
                    timepoints = []
                    
                    for tp in sv.get_is_linear_timed_variables():
                        timepoints.append(tp.get_is_linear())
                    
                    tot_timepoints.append((vref, timepoints))
            return tot_timepoints
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == DERIVATIVE:
                vref = sv.get_value_reference()
                timepoints = []
                
                for tp in sv.get_is_linear_timed_variables():
                    timepoints.append(tp.get_is_linear())
                
                tot_timepoints.append((vref, timepoints))
        return tot_timepoints
        
    def get_x_linear_timed_variables(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and linear timed variables for all states 
        (variable_category:state) in the model.

        Returns:
            List of tuples with value reference and list of linear time 
            variables respectively. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_x_linear_timed_variables', include_alias)

        tot_timepoints = []
        scalarvariables = self.get_model_variables()

        if include_alias:
            for sv in scalarvariables:
                if sv.get_variable_category() == STATE:
                    vref = sv.get_value_reference()
                    timepoints = []
                    
                    for tp in sv.get_is_linear_timed_variables():
                        timepoints.append(tp.get_is_linear())
                    
                    tot_timepoints.append((vref, timepoints))
            return tot_timepoints
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_variable_category() == STATE:
                vref = sv.get_value_reference()
                timepoints = []
                
                for tp in sv.get_is_linear_timed_variables():
                    timepoints.append(tp.get_is_linear())
                
                tot_timepoints.append((vref, timepoints))
        return tot_timepoints

    def get_u_linear_timed_variables(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and linear timed variables for all inputs 
        (variable_category:algebraic, causality: input) in the model.

        Returns:
            List of tuples with value reference and list of linear time 
            variables respectively. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_u_linear_timed_variables', include_alias)

        tot_timepoints = []
        scalarvariables = self.get_model_variables()

        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                    vref = sv.get_value_reference()
                    timepoints = []
                    
                    for tp in sv.get_is_linear_timed_variables():
                        timepoints.append(tp.get_is_linear())
                    
                    tot_timepoints.append((vref, timepoints))
            return tot_timepoints
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_causality() == INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                vref = sv.get_value_reference()
                timepoints = []
                
                for tp in sv.get_is_linear_timed_variables():
                    timepoints.append(tp.get_is_linear())
                
                tot_timepoints.append((vref, timepoints))
        return tot_timepoints

    def get_w_linear_timed_variables(self, include_alias=True, 
        ignore_cache=False):
        """ 
        Get value reference and linear timed variables for all algebraic 
        variables (variable_category:algebraic, causality: not input) in 
        the model.

        Returns:
            List of tuples with value reference and list of linear time 
            variables respectively. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_w_linear_timed_variables', include_alias)

        tot_timepoints = []
        scalarvariables = self.get_model_variables()

        if include_alias:
            for sv in scalarvariables:
                if sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                    vref = sv.get_value_reference()
                    timepoints = []
                    
                    for tp in sv.get_is_linear_timed_variables():
                        timepoints.append(tp.get_is_linear())
                    
                    tot_timepoints.append((vref, timepoints))
            return tot_timepoints
            
        for sv in scalarvariables:
            if sv.get_alias() == NO_ALIAS and \
                sv.get_causality() != INPUT and \
                    sv.get_variable_category() == ALGEBRAIC:
                vref = sv.get_value_reference()
                timepoints = []
                
                for tp in sv.get_is_linear_timed_variables():
                    timepoints.append(tp.get_is_linear())
                
                tot_timepoints.append((vref, timepoints))
        return tot_timepoints

    def get_p_opt_value_reference(self, ignore_cache=False):
        """ 
        Get value reference for all optimized independent parameters.
        
        Returns:
            List of value reference for all optimized independent 
            parameters.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 
                'get_p_opt_value_reference', None)
                
        vrefs = []
        
        for sv in self.get_model_variables():
            if sv.get_variability() == PARAMETER and \
                sv.get_fundamental_type().get_free() == True:
                    vrefs.append(sv.get_value_reference())
        return vrefs

    def get_external_libraries(self, ignore_cache=False):
        """ Get all external library entries and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_libraries', None)
        
        libraries = []
        
        tools = self.get_vendor_annotations()
        for tool in tools:
            if tool.get_name() == 'JModelica':
                annotations = tool.get_annotations()
                for annotation in annotations:
                    if annotation.get_name() == 'Library':
                        libraries.append(annotation.get_value())
        return libraries
        
    def get_external_includes(self, ignore_cache=False):
        """Get all external file includes and return as list."""
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_includes', None)
        
        includes = []
        
        tools = self.get_vendor_annotations()
        for tool in tools:
            if tool.get_name() == 'JModelica':
                annotations = tool.get_annotations()
                for annotation in annotations:
                    if annotation.get_name() == 'Include':
                        includes.append(annotation.get_value())
        return includes
        
    def get_external_lib_dirs(self, ignore_cache=False):
        """ Get all external library directories and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_lib_dirs', None)
            
        libdirs = []
        
        tools = self.get_vendor_annotations()
        for tool in tools:
            if tool.get_name() == 'JModelica':
                annotations = tool.get_annotations()
                for annotation in annotations:
                    if annotation.get_name() == 'LibraryDirectory':
                        libdirs.append(annotation.get_value())
        return libdirs
        
    def get_external_incl_dirs(self, ignore_cache=False):
        """ Get all external include directories and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_incl_dirs', None)
            
        includedirs = []
        
        tools = self.get_vendor_annotations()
        for tool in tools:
            if tool.get_name() == 'JModelica':
                annotations = tool.get_annotations()
                for annotation in annotations:
                    if annotation.get_name() == 'IncludeDirectory':
                        includedirs.append(annotation.get_value())
        return includedirs

    def get_opt_starttime(self, ignore_cache=False):
        """ Get the optimization interval start time. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_opt_starttime', 
                None)
                
        optimization = self.get_optimization()
        
        if optimization == None:
            return None
        
        return optimization.get_interval_start_time().get_value()

    def get_opt_finaltime(self, ignore_cache=False):
        """ Get the optimization interval final time. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_opt_finaltime', 
                None)
                
        optimization = self.get_optimization()
        
        if optimization == None:
            return None
        
        return optimization.get_interval_final_time().get_value()
        
    def get_opt_starttime_free(self, ignore_cache=False):
        """ Get the optimization interval start time free attribute. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_opt_starttime_free', 
                None)
                
        optimization = self.get_optimization()
        
        if optimization == None:
            return None
        
        return optimization.get_interval_start_time().get_free()

    def get_opt_finaltime_free(self, ignore_cache=False):
        """ Get the optimization interval final time free attribute. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_opt_finaltime_free', 
                None)
                
        optimization = self.get_optimization()
        
        if optimization == None:
            return None
        
        return optimization.get_interval_final_time().get_free()
        
    def get_opt_timepoints(self, ignore_cache=False):
        """ Get the optimization time points. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_opt_timepoints', 
                None)
                
        optimization = self.get_optimization()
        
        if optimization == None:
            return None
            
        time_points = []
        
        for tp in optimization.get_time_points():
            time_points.append(tp.get_value())
        
        return time_points
    
# ============== Here begins the XML element classes ===================
    
class BaseUnit:
    
    def __init__(self, element):
        # attributes
        self._attributes = {'unit':''}
        
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
            
        # set list of display units
        self._display_unit_definitions = [];
        # fill list by calling constructor for DisplayUnitDefinition for each element
        e_unitdefs = element.getchildren()
        for e_unitdef in e_unitdefs:
            self._display_unit_definitions.append(DisplayUnitDefinition(e_unitdef))
            
    def get_unit(self):
        return self._attributes['unit']
            
    def get_display_units(self):
        return self._display_unit_definitions
        
class DisplayUnitDefinition:
    
    def __init__(self, element):
        # attributes
        self._attributes = {'displayUnit':'',
                            'gain':'1.0',
                            'offset':'0.0'}
        
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_display_unit(self):
        return self._attributes['displayUnit']
        
    def get_gain(self):
        return float(self._attributes['gain'])
        
    def get_offset(self):
        return float(self._attributes['offset'])
        
class Type:
    
    def __init__(self, element):
        # attributes
        self._attributes = {'name':'',
                            'description':''}
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
        
        # get fundamental type (should only be one)
        e_ftype = element.getchildren()[0]
        if e_ftype.tag == 'RealType':
            self._fundamentaltype = RealType(e_ftype)
        elif e_ftype.tag == 'IntegerType':
            self._fundamentaltype = IntegerType(e_ftype)
        elif e_ftype.tag == 'BooleanType':
            self._fundamentaltype = BooleanType(e_ftype)
        elif e_ftype.tag == 'StringType':
            self._fundamentaltype = StringType(e_ftype)
        elif e_ftype.tag == 'EnumerationType':
            self._fundamentaltype = EnumerationType(e_ftype)
        else:
            raise XMLException("fundamental type (TypeDefinitions)"+str(e_ftype.tag)+" is unknown")

    def get_name(self):
        return self._attributes['name']
        
    def get_description(self):
        return self._attributes['description']
        
    def get_fundamental_type(self):
        return self._fundamentaltype
        
class RealType:
    
    def __init__(self, element):
        self._attributes = {'quantity':'',
                            'unit':'',
                            'displayUnit':'',
                            'relativeQuantity':'false',
                            'min':'',
                            'max':'',
                            'nominal':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_quantity(self):
        return self._attributes['quantity']
    
    def get_unit(self):
        return self._attributes['unit']
        
    def get_display_unit(self):
        return self._attributes['displayUnit']
        
    def get_relative_quantity(self):
        return _translate_xmlbool(self._attributes['relativeQuantity'])
    
    def get_min(self):
        if self._attributes['min'] == '':
            return None
        return float(self._attributes['min'])
        
    def get_max(self):
        if self._attributes['max'] == '':
            return None
        return float(self._attributes['max'])
        
    def get_nominal(self):
        if self._attributes['nominal'] == '':
            return None
        return float(self._attributes['nominal'])
        
class IntegerType:
    
    def __init__(self, element):
        self._attributes = {'quantity':'',
                            'min':'',
                            'max':''}
    
    def get_quantity(self):
        return self._attributes['quantity']
        
    def get_min(self):
        if self._attributes['min'] == '':
            return None
        return int(self._attributes['min'])
        
    def get_max(self):
        if self._attributes['max'] == '':
            return None
        return int(self._attributes['max'])

class BooleanType: pass

class StringType: pass

class EnumerationType:
    
    def __init__(self, element):
        self._attributes = {'quantity':'',
                            'min':'',
                            'max':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

        # items
        self._items = []
        e_items = element.getchildren()
        for e_item in e_items:
            self._items.append(Item(e_item))
                            
    def get_quantity(self):
        return self._attributes['quantity']
        
    def get_min(self):
        if self._attributes['min'] == '':
            return None
        return int(self._attributes['min'])
        
    def get_max(self):
        if self._attributes['max'] == '':
            return None
        return int(self._attributes['max'])
        
    def get_items(self):
        return self._items

class Item:
    
    def __init__(self, element):
        self._attributes = {'name':'',
                            'description':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
        
    def get_name(self):
        return self._attributes['name']
        
    def get_description(self):
        return self._attributes['description']

class DefaultExperiment:
    
    def __init__(self, element):
        self._attributes = {'startTime':'',
                            'stopTime':'',
                            'tolerance':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
    
    def get_start_time(self):
        if self._attributes['startTime'] == '':
            return None
        return float(self._attributes['startTime'])
        
    def get_stop_time(self):
        if self._attributes['stopTime'] == '':
            return None
        return float(self._attributes['stopTime'])
        
    def get_tolerance(self):
        if self._attributes['tolerance'] == '':
            return None
        return float(self._attributes['tolerance'])
        
class Tool:

    def __init__(self, element):
        self._attributes = {'name':''}
        
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
        
        # annotations
        self._annotations = []
        e_annotations = element.getchildren()
        for e_annotation in e_annotations:
            self._annotations.append(Annotation(e_annotation))
        
    def get_name(self):
        return self._attributes['name']

    def get_annotations(self):
        return self._annotations
        
class Annotation:
    
    def __init__(self, element):
        self._attributes = {'name':'',
                            'value':''}
        
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_name(self):
        return self._attributes['name']
        
    def get_value(self):
        return self._attributes['value']
        
class ScalarVariable:
    
    def __init__(self, element):
        self._attributes = {'name':'',
                            'valueReference':'',
                            'description':'',
                            'variability':'continuous',
                            'causality':'internal',
                            'alias':'noAlias'}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
 
        # get fundamental type (must be one of Real, Integer, Boolean, String, Enumeration)
        e_ftype = element.getchildren()[0]
        if e_ftype.tag == 'Real':
            self._fundamental_type = Real(e_ftype)
        elif e_ftype.tag == 'Integer':
            self._fundamental_type = Integer(e_ftype)
        elif e_ftype.tag == 'Boolean':
            self._fundamental_type = Boolean(e_ftype)
        elif e_ftype.tag == 'String':
            self._fundamental_type = String(e_ftype)
        elif e_ftype.tag == 'Enumeration':
            self._fundamental_type = Enumeration(e_ftype)
        else:
            raise XMLException("ScalarVariable: "+self._attributes['name']+
                " does not have a valid fundamental type.")

        # direct dependency
        self._direct_dependency = None
        e_directdependency = element.find('DirectDependency')
        if e_directdependency != None:
            self._direct_dependency = DirectDependency(e_directdependency)
            
        #### Qualified Name here ####
        
        # isLinear
        self._is_linear = element.find('isLinear')
        if self._is_linear != None:
            self._is_linear = _translate_xmlbool(self._is_linear.text)
            
        # isLinearTimedVariables
        self._is_linear_timed_variables = []
        e_lineartimedvariables = element.find('isLinearTimedVariables')
        if e_lineartimedvariables != None:
            e_tpoints = e_lineartimedvariables.getchildren()
            for e_tp in e_tpoints:
                self._is_linear_timed_variables.append(TimePoint(e_tp))
                
        # variableCategory
        e_variablecategory = element.find('VariableCategory')
        if e_variablecategory == None:
            self._variable_category = 'algebraic'
        else:
            self._variable_category = e_variablecategory.text

    def get_name(self):
        return self._attributes['name']
        
    def get_value_reference(self):
        if self._attributes['valueReference'] == '':
            return None
        return int(self._attributes['valueReference'])
        
    def get_description(self):
        return self._attributes['description']
        
    def get_variability(self):
        return _translate_variability(self._attributes['variability'])
        
    def get_causality(self):
        return _translate_causality(self._attributes['causality'])
        
    def get_alias(self):
        return _translate_alias(self._attributes['alias'])
        
    def get_fundamental_type(self):
        return self._fundamental_type
        
    def get_direct_dependency(self):
        return self._direct_dependency
        
    def get_is_linear(self):
        return self._is_linear
        
    def get_is_linear_timed_variables(self):
        return self._is_linear_timed_variables
    
    def get_variable_category(self):
        return _translate_variable_category(self._variable_category)
        
class Real:
    
    def __init__(self, element):
        self._attributes = {'declaredType':'',
                            'quantity':'',
                            'unit':'',
                            'displayUnit':'',
                            'relativeQuantity':'false',
                            'min':'',
                            'max':'',
                            'nominal':'',
                            'start':'',
                            'fixed':'',
                            'free':'',
                            'initialGuess':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_declared_type(self):
        return self._attributes['declaredType']
        
    def get_quantity(self):
        return self._attributes['quantity']
        
    def get_unit(self):
        return self._attributes['unit']
        
    def get_display_unit(self):
        return self._attributes['displayUnit']
        
    def get_relative_quantity(self):
        return _translate_xmlbool(self._attributes['relativeQuantity'])
        
    def get_min(self):
        min = self._attributes['min']
        if min == '':
            return None
        return float(min)
        
    def get_max(self):
        max = self._attributes['max']
        if max == '':
            return None
        return float(max)

    def get_nominal(self):
        nominal = self._attributes['nominal']
        if nominal == '':
            return None
        return float(nominal)

    def get_start(self):
        start = self._attributes['start']
        if start == '':
            return None
        return float(start)

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return _translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if free == '':
            return None
        return _translate_xmlbool(free)

    def get_initial_guess(self):
        initialguess = self._attributes['initialGuess']
        if initialguess == '':
            return None
        return float(initialguess)
        
class Integer:
    
    def __init__(self, element):
        self._attributes = {'declaredType':'',
                            'quantity':'',
                            'min':'',
                            'max':'',
                            'start':'',
                            'fixed':'',
                            'free':'',
                            'initialGuess':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_declared_type(self):
        return self._attributes['declaredType']
        
    def get_quantity(self):
        return self._attributes['quantity']
                
    def get_min(self):
        min = self._attributes['min']
        if min == '':
            return None
        return int(min)
        
    def get_max(self):
        max = self._attributes['max']
        if max == '':
            return None
        return int(max)

    def get_start(self):
        start = self._attributes['start']
        if start == '':
            return None
        return int(start)

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return _translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if free == '':
            return None
        return _translate_xmlbool(free)

    def get_initial_guess(self):
        initialguess = self._attributes['initialGuess']
        if initialguess == '':
            return None
        return int(initialguess)
        
class Boolean:
    
    def __init__(self, element):
        self._attributes = {'declaredType':'',
                            'start':'',
                            'fixed':'',
                            'free':'',
                            'initialGuess':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_declared_type(self):
        return self._attributes['declaredType']
        
    def get_start(self):
        start = self._attributes['start']
        if start == '':
            return None
        return _translate_xmlbool(start)

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return _translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if free == '':
            return None
        return _translate_xmlbool(free)

    def get_initial_guess(self):
        initialguess = self._attributes['initialGuess']
        if initialguess == '':
            return None
        return _translate_xmlbool(initialguess)

class String:
    
    def __init__(self, element):
        self._attributes = {'declaredType':'',
                            'start':'',
                            'fixed':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_declared_type(self):
        return self._attributes['declaredType']
        
    def get_start(self):
        return self._attributes['start']

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return _translate_xmlbool(fixed)


class Enumeration:
    
    def __init__(self, element):
        self._attributes = {'declaredType':'',
                            'quantity':'',
                            'min':'',
                            'max':'',
                            'start':'',
                            'fixed':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_declared_type(self):
        return self._attributes['declaredType']
        
    def get_quantity(self):
        return self._attributes['quantity']

    def get_min(self):
        min = self._attributes['min']
        if min == '':
            return None
        return int(min)
        
    def get_max(self):
        max = self._attributes['max']
        if max == '':
            return None
        return int(max)

    def get_start(self):
        start = self._attributes['start']
        if start == '':
            return None
        return int(start)

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return _translate_xmlbool(fixed)

class DirectDependency:
    
    def __init__(self, element):
        self._names = []
        e_names = element.getchildren()
        for e_name in e_names:
            self._names.append(e_name.text)
            
    def get_names(self):
        return self._names

class TimePoint:
    
    def __init__(self, element):
        self._attributes = {'index':'',
                            'isLinear':''}
                            
        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)

    def get_index(self):
        index = self._attributes['index']
        if index == '':
            return None
        else:
            return int(index)
            
    def get_is_linear(self):
        is_linear = self._attributes['isLinear']
        if is_linear == '':
            return None
        else:
            return _translate_xmlbool(is_linear)
            
class Optimization:
    
    def __init__(self, element):
        self._attributes = {'static':''}

        # update attribute dict with attributes from XML file
        self._attributes.update(element.attrib)
        
        # namespace
        opt=element.nsmap['opt']
        ns="{"+opt+"}"        
        
        # interval start time
        self._interval_start_time = None
        e_intervalstartt = element.find(ns+'IntervalStartTime')
        if e_intervalstartt != None:
            self._interval_start_time = Opt_IntervalTime(e_intervalstartt)
            
        # interval final time
        self._interval_final_time = None
        e_intervalfinalt = element.find(ns+'IntervalFinalTime')
        if e_intervalfinalt != None:
            self._interval_final_time = Opt_IntervalTime(e_intervalfinalt)
            
        # time points
        # bad xml schema construction - consider redoing
        self._time_points = []
        e_timepoints = element.find(ns+'TimePoints')
        if e_timepoints != None:
            e_indexes = e_timepoints.findall(ns+"Index")
            e_values = e_timepoints.findall(ns+"Value")
            
            for i, e_index in enumerate(e_indexes):
                self._time_points.append(Opt_TimePoint(e_index, e_values[i]))
                
    def get_static(self):
        if self._attributes['static'] == '':
            return None
        return _translate_xmlbool(self._attributes['static'])
            
    def get_interval_start_time(self):
        return self._interval_start_time
        
    def get_interval_final_time(self):
        return self._interval_final_time
        
    def get_time_points(self):
        return self._time_points
        
class Opt_IntervalTime:
    
    def __init__(self, element):
        opt=element.nsmap['opt']
        ns="{"+opt+"}"
        
        # value
        e_value = element.find(ns+"Value")
        if e_value != None:
            self._value = float(e_value.text)
        else:
            self._value = None

        # free
        e_free = element.find(ns+"Free")
        if e_free != None:
            self._free = _translate_xmlbool(e_free.text)
        else:
            self._free = None
            
        # initial guess
        e_initialguess = element.find(ns+"InitialGuess")
        if e_initialguess != None:
            self._initial_guess = float(e_initialguess.text)
        else:
            self._initial_guess = None
            
    
    def get_value(self):
        return self._value

    def get_free(self):
        return self._free
        
    def get_initial_guess(self):
        return self._initial_guess
    
class Opt_TimePoint:
    
    def __init__(self, e_index, e_value):
        self._index = e_index.text
        self._value = e_value.text
        
    def get_index(self):
        return int(self._index)
        
    def get_value(self):
        return float(self._value)


#=======================================================================



class XMLFunctionCache:
    """ Class representing cache for loaded XML doc.
    
        Function return values from function calls in XMLDoc are 
        saved in a dict structure. The first time a function call is
        made for a particular instance of XMLDoc will result in a 
        new entry in the internal cache (dict). If the function has an 
        argument, the function entry will get the value equal to a new 
        dict with return values dependent on function argument.
        
        Note: The current version only supports functions with no or one 
        argument.
    
    """
    
    def __init__(self):
        """ Create internal cache (dict). """
        self.cache={}
        
    def add(self, obj, function, key=None):
        """ Add a function call to cache and save result dependent on 
            the argument key. If key is None, the function has no arguments 
            and the dict entry will simply contain one value which is the 
            return value for the specific function. If key is not none, the 
            value of the dict entry will contain yet another dict with an entry 
            for each argument to the function.
        """
        # load xmlparser-function
        f = getattr(obj, function)
        # check if there is a key (argument to function f)
        # and get result (call function)
        if key!=None:
            result = f(key, ignore_cache=True)
        else:
            result = f(ignore_cache=True)
        # check if function is already in cache
        if not self.cache.has_key(function):
            # function is not in cache so add both function 
            # and return result which is either a dict or 
            # "normal" value entry dependent on key
            if key!=None:
                self.cache[function] = {key:result}
            else:
                self.cache[function] = result
        else:
            # function is in cache so add result for the 
            # specific argument
            values = self.cache.get(function)
            # ...should not have to do this check, 
            # have we got this far key can not be = None
            # but keep for now
            if key!=None:
                values[key]=result
            else:
                result=values
        return result                        
                    
    def get(self, obj, function, key=None):
        """ Get the function return value (cached value) for 
            the specific function and key.
            
        """
        # Get function result value/values from cache
        values = self.cache.get(function)
        # check if function could be found in cache
        if values!=None:
            # if key is none then values is = the function return value
            if key is None:
                return values
            # otherwise, use the key (function arg) to get the correct value
            result = values.get(key)
            # check if found in cache
            if result!=None:
                #return result is found
                return result
        # result was not found - add to cache
        return self.add(obj, function, key)
        

#class XMLDoc(XMLBaseDoc):
    #""" Class representing a parsed XML file containing model variable meta data. """

    #def get_data_type(self, variablename):
        #""" Get data type of variable. """
        #types = self.get_data_types()
        #return types.get(variablename)
        
    #def get_data_types(self, ignore_cache=False):
        #if not ignore_cache:
            #return self.function_cache.get(self, 'get_data_types')

        #nodes=self._xpatheval("//ScalarVariable")
        #keys = self._xpatheval("//ScalarVariable/@name")
        
        #vals = []
        #for node in nodes:
            #children=node.getchildren()
            #vals.append(children[0].tag)
        #d={}
        #for index, key in enumerate(keys):
            #d[str(key)]=str(vals[index])
        #return d



                
    #def _cast_values(self, keys, vals):
        #d={}
        #for index, key in enumerate(keys):
            #type_ = self.get_data_type(key)
            #if type_ == 'Real':
                #d[str(key)]= float(vals[index])
            #elif type_ == 'Integer':
                #d[str(key)]= int(vals[index])
            #elif type_ == 'Boolean':
                #d[str(key)]= (vals[index]=="true")
            #elif type_ == 'String':
                #d[str(key)]= str(vals[index])
            #else:
                #pass
                ## enumeration not supported yet      
        #return d

        
    #def is_static(self, ignore_cache=False):
        #""" Return True if Optimica static attribute is set and equal to true, otherwise False."""
        #if not ignore_cache:
            #return self.function_cache.get(self, 'is_static', None)
        #static = self._xpatheval("opt:Optimization/@static")
        #if len(static) > 0:
            #return static[0]=='true'
        #return False
        
 
class XMLBaseDoc:
    
    """ Base class representing a parsed XML file."""
    
    def __init__(self, filename, schemaname=''):
        """ 
        Create an XML document object representation and an XPath evaluator.
        
        Parse an XML document and create an XML document object 
        representation. Validate against XML schema before parsing if the 
        parameter schemaname is set. Instantiates an XPath evaluator object 
        for the parsed XML which can be used to evaluate XPath expressions on 
        the XML.
         
        """
        self.function_cache = XMLFunctionCache()
        self._doc = _parse_XML(filename, schemaname)
        root = self._doc.getroot()
        self._xpatheval = etree.XPathEvaluator(self._doc, namespaces=root.nsmap)
            
class XMLValuesDoc(XMLBaseDoc):
    
    """ 
    Class representing a parsed XML file containing values for all 
    independent parameters. 
    
    """
                
    def get_iparam_values(self):
        """ 
        Extract name and value for all independent parameters in the 
        XML document.
        
        Returns:   
            Dict with variable name as key and parameter as value.
            
        """
        keys = self._xpatheval("//*/@name")
        vals = self._xpatheval("//*/@value")
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        names=[]
        iparam_values=[]
        for index, key in enumerate(keys):
            names.append(str(key))
            type_ = self.get_parameter_type(str(key))
            if type_ == 'RealParameter':
                iparam_values.append(float(vals[index]))
            elif type_ == 'IntegerParameter':
                iparam_values.append(int(vals[index]))
            elif type_ == 'BooleanParameter':
                iparam_values.append(vals[index]=="true")
            elif type_ == 'StringParameter':
                iparam_values.append(str(vals[index]))
            else:
                pass
                # enumeration not supported yet
        return dict(zip(names, iparam_values))
    
    def get_parameter_type(self, variablename):
        type_ = self._xpatheval("//IndependentParameters/node()[@name=\""+str(variablename)+"\"]")
        if len(type_) > 0:
            return type_[0].tag
        return None
        
             
class XMLException(Exception):
    
    """ Class for all XML related errors that can occur in this module. """
    
    pass
