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


#=======================================================================


def translate_xmlbool(xmlbool):
    if xmlbool == 'false':
        return False
    elif xmlbool == 'true':
        return True
    else:
        raise Exception('The xml boolean '+str(xmlbool)+' does not have a valid value.')

class ModelDescription:

    def __init__(self, filename, schemaname=''):
        """ 
        Create an XML document object representation and an XPath evaluator.
        
        Parse an XML document and create an XML document object 
        representation. Validate against XML schema before parsing if the 
        parameter schemaname is set. Instantiates an XPath evaluator object 
        for the parsed XML which can be used to evaluate XPath expressions on 
        the XML.
         
        """
        # set up cache, parse XML file and obtain the root
        self.function_cache = XMLFunctionCache()
        element_tree = self._parse_XML(filename, schemaname)
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
        
    def _parse_XML(self, filename, schemaname=''):
    
        """ 
        Parses and validates (optional) an XML file.
    
        Parses an XML file and returns an object representing the parsed XML.
        If the optional parameter schemaname is set the XML file is also validated
        against the XML Schema file provided before parsing. 
    
        Parameters:
            filename -- 
                Name of XML file to parse including absolute or relative path.
            schemaname --
                Name of XML Schema file including absolute or relative path.
        
        Exceptions:   
            XMLException -- 
                If the XML file can not be read or is not well-formed. If a schema 
                is present and if the schema file can not be read, is not 
                well-formed or if the validation fails. 
        
        Returns:    
            Reference to the ElementTree object containing the parsed XML.
        
        """
    
        try:
            element_tree = etree.ElementTree(file=filename)
        except etree.XMLSyntaxError, detail:
            raise XMLException("The XML file: %s is not well-formed. %s" %(filename, detail))
    
        if schemaname:
            try:
                schemadoc = etree.ElementTree(file=schemaname)
            except etree.XMLSyntaxError, detail:
                raise XMLException("The XMLSchema: %s is not well-formed. %s" %(schemaname, detail))         
            
            schema = etree.XMLSchema(schemadoc)
        
            result = schema.validate(xmldoc)
        
            if not result:
                raise XMLException("The XML file: %s is not valid according to the XMLSchema: %s." %(filename, schemaname))
        
        return element_tree

    def _parse_element_tree(self, root):
        """ Parse the XML element tree and build up internal data structure. """
        
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
            self._default_experiment = DefaultExperiment(e_defaultexperiment)
    
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
        
        e_modelvariables = root.find('ModelVariables')
        if e_modelvariables != None:
            # list of scalar variables
            e_scalarvariables = e_modelvariables.getchildren()
            for e_scalarvariable in e_scalarvariables:
                sv = ScalarVariable(e_scalarvariable)
                self._model_variables.append(sv)
                
                # fill vref and vref no alias lists
                self._vrefs.append(sv.get_value_reference())
                if sv.get_alias() == "noAlias":
                    self._vrefs_noAlias.append(sv.get_value_reference())
                
    def _fill_optimization(self, root):
        self._optimization = None
        
        opt=root.nsmap['opt']
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

    def get_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the variables in a model.

        Returns:
            Tuple of two tuples containing value references and names respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_names',include_alias)

        names = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                names.append(sv.get_name())
            return zip(tuple(self._vrefs),tuple(names))

        for sv in scalarvariables:
            if sv.get_alias() == 'noAlias':
                names.append(sv.get_name())
        return zip(tuple(self._vrefs_noAlias),tuple(names))
        
        
    def get_variable_aliases(self, ignore_cache=False):
        """ Extract the alias data for each variable in the model.
        
        Returns:
            Tuple of two tuples containing value references and alias data respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_aliases')
        
        alias_data = []
        scalarvariables = self.get_model_variables()
        for sv in scalarvariables:
            alias = sv.get_alias()
            if alias == "noAlias":
                alias_data.append(NO_ALIAS)
            elif alias == "alias":
                alias_data.append(ALIAS)
            elif alias == "negatedAlias":
                alias_data.append(NEGATED_ALIAS)
            else:
                raise XMLException("Alias attribute for variable: "+sv.get_name() + 
                    " does not have a valid value")
        return zip(tuple(self._vrefs),tuple(alias_data))

    def get_variable_descriptions(self, include_alias=True, ignore_cache=False):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Tuple of two tuples containing value reference and description respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_variable_descriptions', include_alias)
            
        descriptions = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                descriptions.append(sv.get_description())
            return zip(tuple(self._vrefs),tuple(descriptions))
            
        for sv in scalarvariables:
            if sv.get_alias() == "noAlias":
                descriptions.append(sv.get_description())
        return zip(tuple(self._vrefs_noAlias),tuple(descriptions))
        
    def get_variable_variabilities(self, include_alias=True, ignore_cache=False):
        """ Get the variability of the variables in the model.
        
        Returns:
            Tuple of two tuples containing value reference and variability respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_variable_variabilities', include_alias)
        
        variabilities = []
        scalarvariables = self.get_model_variables()
        
        if include_alias:
            for sv in scalarvariables:
                variabilities.append(self._translate_variability(sv.get_variability()))
            return zip(tuple(self._vrefs),tuple(variabilities))
        
        for sv in scalarvariables:
            if sv.get_alias() == 'noAlias':
                variabilities.append(self._translate_variability(sv.get_variability()))
        return zip(tuple(self._vrefs_noAlias),tuple(variabilities))

    
    #def get_variable_names(self, include_alias=True, ignore_cache=False):
        #"""
        #Extract the names of the variables in a model.

        #Returns:
            #Tuple of two tuples containing value references and names respectively.
        #"""
        #if not ignore_cache:
            #return self.function_cache.get(self,'get_variable_names',include_alias)

        #names = []
        #scalarvariables = self.get_model_variables()
        
        #if include_alias:
            #for sv in scalarvariables:
                #names.append(sv.get_name())
            #return (tuple(self._vrefs),tuple(names))

        #for sv in scalarvariables:
            #if sv.get_alias() == 'noAlias':
                #names.append(sv.get_name())
        #return (tuple(self._vrefs_noAlias),tuple(names))
        
        
    #def get_variable_aliases(self, ignore_cache=False):
        #""" Extract the alias data for each variable in the model.
        
        #Returns:
            #Tuple of two tuples containing value references and alias data respectively.
        #"""
        #if not ignore_cache:
            #return self.function_cache.get(self,'get_variable_aliases')
        
        #alias_data = []
        #scalarvariables = self.get_model_variables()
        #for sv in scalarvariables:
            #alias = sv.get_alias()
            #if alias == "noAlias":
                #alias_data.append(NO_ALIAS)
            #elif alias == "alias":
                #alias_data.append(ALIAS)
            #elif alias == "negatedAlias":
                #alias_data.append(NEGATED_ALIAS)
            #else:
                #raise XMLException("Alias attribute for variable: "+sv.get_name() + 
                    #" does not have a valid value")
        #return (tuple(self._vrefs),tuple(alias_data))

    #def get_variable_descriptions(self, include_alias=True, ignore_cache=False):
        #"""
        #Extract the descriptions of the variables in a model.

        #Returns:
            #Tuple of two tuples containing value reference and description respectively.
        #"""
        #if not ignore_cache:
            #return self.function_cache.get(self, 'get_variable_descriptions', include_alias)
            
        #descriptions = []
        #scalarvariables = self.get_model_variables()
        
        #if include_alias:
            #for sv in scalarvariables:
                #descriptions.append(sv.get_description())
            #return (tuple(self._vrefs),tuple(descriptions))
            
        #for sv in scalarvariables:
            #if sv.get_alias() == "noAlias":
                #descriptions.append(sv.get_description())
        #return (tuple(self._vrefs_noAlias),tuple(descriptions))
        
    #def get_variable_variabilities(self, include_alias=True, ignore_cache=False):
        #""" Get the variability of the variables in the model.
        
        #Returns:
            #Tuple of two tuples containing value reference and variability respectively.
        #"""
        #if not ignore_cache:
            #return self.function_cache.get(self, 'get_variable_variabilities', include_alias)
        
        #variabilities = []
        #scalarvariables = self.get_model_variables()
        
        #if include_alias:
            #for sv in scalarvariables:
                #variabilities.append(self._translate_variability(sv.get_variability()))
            #return (tuple(self._vrefs),tuple(variabilities))
        
        #for sv in scalarvariables:
            #if sv.get_alias() == 'noAlias':
                #variabilities.append(self._translate_variability(sv.get_variability()))
        #return (tuple(self._vrefs_noAlias),tuple(variabilities))

                    
    def _translate_variability(self, variability):
        if variability == "continuous":
            translated_variability = CONTINUOUS
        elif variability == "constant":
            translated_variability = CONSTANT
        elif variability == "parameter":
            translated_variability = PARAMETER
        elif variability == "discrete":
            translated_variability = DISCRETE
        else:
            raise XMLException("Variability: "+str(variability)+" is unknown.")
        return translated_variability


        
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
        return translate_xmlbool(self._attributes['relativeQuantity'])
    
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
            self._is_linear = translate_xmlbool(self._is_linear.text)
            
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
        return self._attributes['variability']
        
    def get_causality(self):
        return self._attributes['causality']
        
    def get_alias(self):
        return self._attributes['alias']
        
    def get_fundamental_type(self):
        return self._fundamental_type
        
    def get_direct_dependency(self):
        return self._direct_dependency
        
    def get_is_linear(self):
        return self._is_linear
        
    def get_is_linear_timed_variables(self):
        return self._is_linear_timed_variables
        
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
        return translate_xmlbool(self._attributes['relativeQuantity'])
        
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
        return translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if fixed == '':
            return None
        return translate_xmlbool(free)

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
        return translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if fixed == '':
            return None
        return translate_xmlbool(free)

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
        return translate_xmlbool(start)

    def get_fixed(self):
        fixed = self._attributes['fixed']
        if fixed == '':
            return None
        return translate_xmlbool(fixed)
        
    def get_free(self):
        free = self._attributes['free']
        if fixed == '':
            return None
        return translate_xmlbool(free)

    def get_initial_guess(self):
        initialguess = self._attributes['initialGuess']
        if initialguess == '':
            return None
        return translate_xmlbool(initialguess)

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
        return translate_xmlbool(fixed)


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
        return translate_xmlbool(fixed)

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
            return translate_xmlbool(is_linear)
            
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
        return translate_xmlbool(self._attributes['static'])
            
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
            self._free = translate_xmlbool(e_free.text)
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
        
class XMLDoc2(XMLBaseDoc):

    def get_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the variables in a model.

        Returns:
            Tuple of two tuples containing value references and names respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_names',include_alias)
        
        if include_alias:
            names = self._xpatheval("//ScalarVariable/@name")
            vrefs = self._xpatheval("//ScalarVariable/@valueReference")
        else:
            names = self._xpatheval("//ScalarVariable/@name[../@alias=\"noAlias\"]")
            vrefs = self._xpatheval("//ScalarVariable/@valueReference[../@alias=\"noAlias\"]")
   
        if len(names)!=len(vrefs):
            raise Exception("Number of names does not equal number of value references. \
                Number of names are: "+str(len(names))+" and number of vrefs are: "+str(len(vrefs)))
                
        tup = (tuple(vrefs),tuple(names))
        return tup
        
    def get_alias_data(self, ignore_cache=False):
        """ Extract the alias data for each variable in the model.
        
        Returns:
            Tuple of two tuples containing value references and alias data respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_alias_data')
        
        vrefs = self._xpatheval("//ScalarVariable/@valueReference")
        alias_data = self._xpatheval("//ScalarVariable/@alias")
        translated_alias_data = []
        for d in alias_data:
            if d == "noAlias":
                translated_alias_data.append(NO_ALIAS)
            elif d == "alias":
                translated_alias_data.append(ALIAS)
            else:
                translated_alias_data.append(NEGATED_ALIAS)

        if len(vrefs)!=len(translated_alias_data):
            raise Exception("Number of value references does not equal number of alias data. \
                Number of vrefs are: "+str(len(vrefs))+" and number of alias data are: "+str(len(translated_alias_data)))
        
        tup = (tuple(vrefs),tuple(translated_alias_data))
        return tup
        
    def get_variable_descriptions(self, include_alias=True, ignore_cache=False):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Tuple of two tuples containing value reference and description respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_variable_descriptions', include_alias)

        if include_alias:
            vrefs = self._xpatheval("//ScalarVariable/@valueReference[../@description]")
            descriptions = self._xpatheval("//ScalarVariable/@description[../@description]")
        else:
            vrefs = self._xpatheval("//ScalarVariable/@valueReference[../@description][../@alias=\"noAlias\"]")
            descriptions = self._xpatheval("//ScalarVariable/@description[../@description][../@alias=\"noAlias\"]")
            
        if len(vrefs)!=len(descriptions):
            raise Exception("Number of value references does not equal number of descriptions. \
                Number of vrefs are: "+str(len(vrefs))+" and number of descriptions are: "+str(len(descriptions)))
                
        tup = (tuple(vrefs),tuple(descriptions))
        return tup

    def get_variabilities(self, include_alias=True, ignore_cache=False):
        """ Get the variability of the variables in the model.
        
        Returns:
            Tuple of two tuples containing value reference and variability respectively.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_variabilities', include_alias)
            
        if include_alias:
            vrefs = self._xpatheval("//ScalarVariable/@valueReference[../@variability]")
            variabilities = self._xpatheval("//ScalarVariable/@variability[../@variability]")
        else:
            vrefs = self._xpatheval("//ScalarVariable/@valueReference[../@variability][../@alias=\"noAlias\"]")
            variabilities = self._xpatheval("//ScalarVariable/@variability[../@variability][../@alias=\"noAlias\"]")
            
        translated_variabilities = []
        for v in variabilities:
            if v == "continuous":
                translated_variabilities.append(CONTINUOUS)
            elif v == "constant":
                translated_variabilities.append(CONSTANT)
            elif v == "parameter":
                translated_variabilities.append(PARAMETER)
            else:
                translated_variabilities.append(DISCRETE)
                
        if len(vrefs)!=len(translated_variabilities):
            raise Exception("Number of value references does not equal number of variabilities. \
                Number of vrefs are: "+str(len(vrefs))+" and number of variabilities are: "+str(len(translated_variabilities)))
        
        tup = (tuple(vrefs),tuple(translated_variabilities))
        return tup



class XMLDoc(XMLBaseDoc):
    """ Class representing a parsed XML file containing model variable meta data. """
        
#    def get_valueref(self, variablename, ignore_cache=False):
#        """
#        Extract the ValueReference given a variable name.
#        
#        Parameters:
#            variablename -- the name of the variable
#            
#        Returns:
#            The ValueReference for the variable passed as argument.
#        """
#        if not ignore_cache:
#            return self.function_cache.get(self, 'get_valueref', variablename)
#            
#        ref = self._xpatheval("//ScalarVariable/@valueReference [../@name=\""+variablename+"\"]")
#        if len(ref) > 0:
#            return int(ref[0])
#        else:
#            return None

    def get_valueref(self, variablename):
        """
        Extract the ValueReference given a variable name.
        
        Parameters:
            variablename -- the name of the variable
            
        Returns:
            The ValueReference for the variable passed as argument.
        """
        names_and_refs = self.get_variable_names()
        return names_and_refs.get(variablename)
        
    def is_alias(self, variablename, ignore_cache=False):
        """ Return true is variable is an alias or negated alias. """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_alias', variablename)

        alias = self._xpatheval("//ScalarVariable/@alias[../@name=\""+str(variablename)+"\"]")
        if len(alias)>0:
            return (alias[0] == "alias" or alias[0] == "negatedAlias")
        else:
            raise Exception("The variable: "+str(variablename)+" can not be found in XML document.")
        
    def is_negated_alias(self, variablename, ignore_cache=False):
        """ Return if variable is a negated alias or not. 
        
            Raises exception if variable is not found in XML document.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_negated_alias', variablename)

        negated_alias = self._xpatheval("//ScalarVariable/@alias[../@name=\""+str(variablename)+"\"]")
        if len(negated_alias)>0:
            return (negated_alias[0] == "negatedAlias")
        else:
            raise Exception("The variable: "+str(variablename)+" can not be found in XML document.")
        
    def is_constant(self, variablename, ignore_cache=False):
        """ Find out if variable is a constant.
        
        Raises exception if variable is not found in XML document.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'is_constant', variablename)

        variability = self._xpatheval("//ScalarVariable/@variability[../@name=\""+str(variablename)+"\"]")
        if len(variability) > 0:
            return (variability[0] == "constant")
        else:
            raise Exception("The variable: "+str(variablename)+" can not be found in XML document.")
        
    def get_aliases(self, aliased_variable, ignore_cache=False):
        """ Return list of all alias variables belonging to the aliased 
            variable along with a list of booleans indicating whether the 
            alias variable should be negated or not.
            
            Raises exception if argument is not in model.

            Returns:
                A list consisting of the alias variable names and another
                list consisting of booleans indicating if the corresponding
                alias is negated.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_aliases', aliased_variable)

        # get value reference of aliased variable
        val_ref = self.get_valueref(aliased_variable)
        if val_ref!=None:
            aliases = self._xpatheval("//ScalarVariable/@name[../@alias!=\"noAlias\"]\
                [../@valueReference=\""+str(val_ref)+"\"]")
            aliasnames=[]
            isnegated=[]
            for index, alias in enumerate(aliases):
                if str(aliased_variable)!=str(alias):
                    aliasnames.append(str(alias))
                    aliasvalue = self._xpatheval("//ScalarVariable/@alias[../@name=\""+str(alias)+"\"]")
                    isnegated.append(str(aliasvalue[0])=="negatedAlias")
            return aliasnames, isnegated
        else:
            raise Exception("The variable: "+str(aliased_variable)+" can not be found in model.")
        
#    def get_variable_description(self, variablename, ignore_cache=False):
#        """ Return the description of a variable. """
#        if not ignore_cache:
#            return self.function_cache.get(self, 'get_variable_description', variablename)
#
#        description= self._xpatheval("//ScalarVariable/@description[../@name=\""+str(variablename)+"\"]")
#        if len(description)>0:
#            return str(description[0])
#        else:
#            None
            
    def get_variable_description(self, variablename):
        """ Return the description of a variable. """
        descriptions = self.get_variable_descriptions()
        return descriptions.get(variablename)
    
#    def get_data_type(self, variablename, ignore_cache=False):
#        """ Get data type of variable. """
#        if not ignore_cache:
#            return self.function_cache.get(self, 'get_data_type', variablename)
#
#        node=self._xpatheval("//ScalarVariable[@name=\""+str(variablename)+"\"]")
#        if len(node)>0:
#            children=node[0].getchildren()
#            if len(children)>0:
#                return children[0].tag
#        return None

    def get_data_type(self, variablename):
        """ Get data type of variable. """
        types = self.get_data_types()
        return types.get(variablename)
        
    def get_data_types(self, ignore_cache=False):
        if not ignore_cache:
            return self.function_cache.get(self, 'get_data_types')

        nodes=self._xpatheval("//ScalarVariable")
        keys = self._xpatheval("//ScalarVariable/@name")
        
        vals = []
        for node in nodes:
            children=node.getchildren()
            vals.append(children[0].tag)
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=str(vals[index])
        return d
       

    def get_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the variables in a model.

        Returns:
            Dict with variable name as key and value reference as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self,'get_variable_names',include_alias)
        
        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name")
            vals = self._xpatheval("//ScalarVariable/@valueReference")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../@alias=\"noAlias\"]")      
   
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))           
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=uint(vals[index])
        return d


    def get_derivative_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the derivatives in a model.

        Returns:
            Dict with variable name as key and value reference as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_derivative_names', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference [../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference [../VariableCategory=\"derivative\"][../@alias=\"noAlias\"]")
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))           
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=uint(vals[index])
        return d
        
    def get_differentiated_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the differentiated variables in a model.

        Returns:
            Dict with variable name as key and value reference as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_differentiated_variable_names', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../VariableCategory=\"state\"][../@alias=\"noAlias\"]")
           
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))            
        d = {}
        for index, key in enumerate(keys):
            d[str(key)] = uint(vals[index])
        return d

    def get_input_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the inputs in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_input_names', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../@alias=\"noAlias\"]")
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d = {}
        for index, key in enumerate(keys):
            d[str(key)] = uint(vals[index])
        return d

    def get_algebraic_variable_names(self, include_alias=True, ignore_cache=False):
        """
        Extract the names of the algebraic variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_algebraic_variable_names', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"][../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))       
        d = {}
        for index, key in enumerate(keys):
            d[str(key)] = uint(vals[index])
        return d

    def get_p_opt_names(self, include_alias=True, ignore_cache=False):
        """ 
        Extract the names for all optimized independent parameters.
        
        Returns:
            Dict with ValueReference as key and name as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_names', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"]\
                [../*/@free=\"true\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../@variability=\"parameter\"]\
                [../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"]\
                [../*/@free=\"true\"][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@valueReference[../@variability=\"parameter\"]\
                [../*/@free=\"true\"][../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d = {}
        for index, key in enumerate(keys):
            d[str(key)] = uint(vals[index])
        return d

    def get_variable_descriptions(self, include_alias=True, ignore_cache=False):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Dict with name as key and description as value.
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_variable_descriptions', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@description]")
            vals = self._xpatheval("//ScalarVariable/@description[../@description]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@description][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/@description[../@description][../@alias=\"noAlias\"]")
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))       
        d={}
        for index, key in enumerate(keys):
            d[str(key)]=str(vals[index])
        return d
                
    def _cast_values(self, keys, vals):
        d={}
        for index, key in enumerate(keys):
            type_ = self.get_data_type(key)
            if type_ == 'Real':
                d[str(key)]= float(vals[index])
            elif type_ == 'Integer':
                d[str(key)]= int(vals[index])
            elif type_ == 'Boolean':
                d[str(key)]= (vals[index]=="true")
            elif type_ == 'String':
                d[str(key)]= str(vals[index])
            else:
                pass
                # enumeration not supported yet      
        return d

    def get_nominal_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and nominal attribute for all variables 
        in the XML document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_nominal_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../*/@nominal]")
            vals = self._xpatheval("//ScalarVariable/*/@nominal")
        else:  
            keys = self._xpatheval("//ScalarVariable/@name[../@alias=\"noAlias\"][../*/@nominal]")
            vals = self._xpatheval("//ScalarVariable/*/@nominal[../../@alias=\"noAlias\"]")
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
#        keys = map(N.int,keys)
#        vals = map(N.float,vals)
        return self._cast_values(keys, vals)

    
    def get_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and Start attribute for all variables 
        in the XML document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name")
            vals = self._xpatheval("//ScalarVariable/*/@start")
        else:  
            keys = self._xpatheval("//ScalarVariable/@name[../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../@alias=\"noAlias\"]")   
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
#        keys = map(N.int,keys)
#        vals = map(N.float,vals)
        return self._cast_values(keys, vals)

    def get_p_opt_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and start values for all optimized 
        independent parameters.
        
        Returns:
            Dict with variable name as key and start attribute as value.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name\
                [../@variability=\"parameter\"][../*/@free=\"true\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start\
                [../../@variability=\"parameter\"][../../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"]\
                [../*/@free=\"true\"][../@alias=\"noAlias\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../@variability=\"parameter\"]\
                [../../*/@free=\"true\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)


    def get_dx_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and Start attribute for all derivatives in the 
        XML document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"][../*/@start]\
                [../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"derivative\"]\
                [../../@alias=\"noAlias\"]")
                 
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)

    def get_x_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and Start attribute for all differentiated 
        variables in the XML document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"][../*/@start]\
                [../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"state\"]\
                [../../@alias=\"noAlias\"]")
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)

    def get_u_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and Start attribute for all inputs in the XML 
        document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"][../*/@start][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"][../../@alias=\"noAlias\"]")            
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)

    def get_w_start_attributes(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and Start attribute for all algebraic variables 
        in the XML document.
            
        Returns:
            Dict with variable name as key and Start attribute as value.
             
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_start_attributes', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"][../*/@start]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"]\
                [../@causality!=\"input\"][../*/@start][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@start[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"][../../@alias=\"noAlias\"]")            
             
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_p_opt_variable_refs(self, ignore_cache=False):
        """ 
        Extract value reference for all optimized independent parameters.
        
        Returns:
            List of value reference for all optimized independent parameters.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_variable_refs', None)

        refs = self._xpatheval("//ScalarVariable/@valueReference[../@variability=\"parameter\"]\
            [../*/@free=\"true\"]")
        valrefs=[]
        for ref in refs:
            valrefs.append(int(ref))
        return valrefs
    
    def get_w_initial_guess_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and InitialGuess values for all algebraic 
        variables.
        
        Returns:
            Dict with variable name as key and InitialGuess as value.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_initial_guess_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"][../@alias=\"noAlias\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_u_initial_guess_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and InitialGuess values for all input 
        variables.
        
        Returns:
            Dict with variable name as key and InitialGuess as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_initial_guess_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../@alias=\"noAlias\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"][../../@alias=\"noAlias\"]")
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_dx_initial_guess_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and InitialGuess values for all derivative 
        variables.
        
        Returns:
            Dict with variable name as key and InitialGuess as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_initial_guess_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess\
                [../../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"]\
                [../@alias=\"noAlias\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../VariableCategory=\"derivative\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_x_initial_guess_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and InitialGuess values for all differentiated 
        variables.
        
        Returns:
            Dict with variable name as key and InitialGuess as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_initial_guess_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess\
                [../../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"]\
                [../@alias=\"noAlias\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../VariableCategory=\"state\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))        
        return self._cast_values(keys, vals)
    
    def get_p_opt_initial_guess_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and InitialGuess values for all optimized 
        independent parameters.
        
        Returns:
            Dict with variable name as key and InitialGuess as value.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_initial_guess_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name\
                [../@variability=\"parameter\"][../*/@free=\"true\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess\
                [../../@variability=\"parameter\"][../../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"]\
                [../*/@free=\"true\"][../@alias=\"noAlias\"][../*/@initialGuess]")
            vals = self._xpatheval("//ScalarVariable/*/@initialGuess[../../@variability=\"parameter\"]\
                [../../*/@free=\"true\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)

    def get_w_lb_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and lower bound values for all algebraic 
        variables.
        
        Returns:
            Dict with variable name as key and lower bound as value.
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_lb_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                                   [../@causality!=\"input\"] [../*/@min]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                                   [../@causality!=\"input\"] [../*/@min][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_u_lb_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and lower bound values for all input 
        variables.
        
        Returns:
            Dict with variable name as key and lower bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_lb_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"] [../*/@min]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"][../*/@min][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))            
        return self._cast_values(keys, vals)
    
    def get_dx_lb_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and lower bound values for all derivative 
        variables.
        
        Returns:
            Dict with variable name as key and lower bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_lb_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../*/@min]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../*/@min][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"derivative\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))        
        return self._cast_values(keys, vals)
    
    def get_x_lb_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and lower bound values for all differentiated 
        variables.
        
        Returns:
            Dict with variable name as key and lower bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_lb_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"]\
                [../*/@min]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"]\
                [../*/@min][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../VariableCategory=\"state\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_p_opt_lb_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and lower bound values for all optimized 
        independent parameters.
        
        Returns:
            Dict with variable name as key and lower bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_lb_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"] \
                                   [../*/@free=\"true\"] [../*/@min]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../@variability=\"parameter\"] \
                                   [../../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"] \
                                   [../*/@free=\"true\"] [../*/@min][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@min[../../@variability=\"parameter\"] \
                                   [../../*/@free=\"true\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)

    def get_w_ub_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and upper bound values for all algebraic 
        variables.
        
        Returns:
            Dict with variable name as key and upper bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_ub_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"] [../*/@max]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"] [../*/@max][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"algebraic\"] \
                [../../@causality!=\"input\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))           
        return self._cast_values(keys, vals)

    def get_u_ub_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and upper bound values for all input variables.
        
        Returns:
            Dict with variable name as key and upper bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_ub_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"] [../*/@max]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"][../*/@max][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"][../../@alias=\"noAlias\"]")    
 
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_dx_ub_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and upper bound values for all derivative 
        variables.
        
        Returns:
            Dict with variable name as key and upper bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_ub_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../*/@max]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../*/@max][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"derivative\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    
    def get_x_ub_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and upper bound values for all differentiated 
        variables.
        
        Returns:
            Dict with variable name as key and upper bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_ub_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../*/@max]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../*/@max][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../VariableCategory=\"state\"]\
                [../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))        
        return self._cast_values(keys, vals)
    
    def get_p_opt_ub_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and upper bound values for all optimized 
        independent parameters.
        
        Returns:
            Dict with variable name as key and upper bound as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_ub_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"] \
                                   [../*/@free=\"true\"] [../*/@max]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../@variability=\"parameter\"] \
                                   [../../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"] \
                                   [../*/@free=\"true\"][../*/@max][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/*/@max[../../@variability=\"parameter\"] \
                                   [../../*/@free=\"true\"][../../@alias=\"noAlias\"]")        
 
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        return self._cast_values(keys, vals)
    

    def get_w_lin_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and boolean value describing if variable 
        appears linearly in all equations and constraints for all algebraic 
        variables.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.
            
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_lin_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"] [../isLinear]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()\
                [../../VariableCategory=\"algebraic\"][../../@causality!=\"input\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"][../isLinear][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()\
                [../../VariableCategory=\"algebraic\"][../../@causality!=\"input\"][../../@alias=\"noAlias\"]")

        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d={}
        for index, key in enumerate(keys):
            d[str(key)] = (vals[index]=="true")
        return d

    def get_u_lin_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and boolean value describing if variable 
        appears linearly in all equations and constraints for all input 
        variables.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_lin_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"] [../isLinear]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"] \
                [../VariableCategory=\"algebraic\"] [../isLinear][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()[../../@causality=\"input\"] \
                [../../VariableCategory=\"algebraic\"][../../@alias=\"noAlias\"]")            
          
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d={}
        for index, key in enumerate(keys):
            d[str(key)] = (vals[index]=="true")
        return d
   
    def get_dx_lin_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and boolean value describing if variable 
        appears linearly in all equations and constraints for all derivative 
        variables.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_lin_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../isLinear]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()\
                [../../VariableCategory=\"derivative\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../isLinear][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()\
                [../../VariableCategory=\"derivative\"][../../@alias=\"noAlias\"]")       
      
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d={}
        for index, key in enumerate(keys):
            d[str(key)] = (vals[index]=="true")
        return d
    
    def get_x_lin_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and boolean value describing if variable 
        appears linearly in all equations and constraints for all 
        differentiated variables.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_lin_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../isLinear]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()[../../VariableCategory=\"state\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../isLinear][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()[../../VariableCategory=\"state\"]\
                [../../@alias=\"noAlias\"]")      
  
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d={}
        for index, key in enumerate(keys):
            d[str(key)] = (vals[index]=="true")
        return d
    
    def get_p_opt_lin_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and boolean value describing if variable 
        appears linearly in all equations and constraints for all optimized 
        independent parameters.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_p_opt_lin_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name\
                [../@variability=\"parameter\"][../*/@free=\"true\"][../isLinear]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()\
                [../../@variability=\"parameter\"][../../*/@free=\"true\"]")
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@variability=\"parameter\"]\
                [../*/@free=\"true\"][../isLinear][../@alias=\"noAlias\"]")
            vals = self._xpatheval("//ScalarVariable/isLinear/text()[../../@variability=\"parameter\"]\
                [../../*/@free=\"true\"][../../@alias=\"noAlias\"]")                
               
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        d={}
        for index, key in enumerate(keys):
            d[str(key)] = (vals[index]=="true")
        return d

    def get_w_lin_tp_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and linear timed variables for all algebraic 
        variables.
        
        Returns:
            Dict with variable name as key and boolean isLinear as value.

        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_w_lin_tp_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"] [../isLinearTimedVariables]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"algebraic\"][../../../@causality!=\"input\"] \
                    [../../../@name=\""+key+"\"]")
                vals.append(tp)
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"algebraic\"] \
                [../@causality!=\"input\"] [../isLinearTimedVariables][../@alias=\"noAlias\"]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"algebraic\"][../../../@causality!=\"input\"] \
                    [../../../@name=\""+key+"\"][../../../@alias=\"noAlias\"]")
                vals.append(tp)            
                  
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        names = []
        timepoints_islinear = []
        
        for index, key in enumerate(keys):
            names.append(str(key))
            # get list of timepoints for each valueref
            tps = vals[index]
            casted_tps = []
            for tp in tps:
                casted_tps.append(tp == "true")    
            timepoints_islinear.append(casted_tps)             
        return dict(zip(names, timepoints_islinear))

    def get_u_lin_tp_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and linear timed variables for all input 
        variables.
        
        Returns:
            Dict with variable name as key and list of linear time variables 
            as value. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_u_lin_tp_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../isLinearTimedVariables]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../@causality=\"input\"][../../../VariableCategory=\"algebraic\"]\
                    [../../../@name=\""+key+"\"]")
                vals.append(tp)
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../@causality=\"input\"]\
                [../VariableCategory=\"algebraic\"][../isLinearTimedVariables][../@alias=\"noAlias\"]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../@causality=\"input\"][../../../VariableCategory=\"algebraic\"]\
                    [../../../@name=\""+key+"\"][../../../@alias=\"noAlias\"]")
                vals.append(tp)           
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        names = []
        timepoints_islinear = []
        
        for index, key in enumerate(keys):
            names.append(str(key))
            # get list of timepoints for each valueref
            tps = vals[index]
            casted_tps = []
            for tp in tps:
                casted_tps.append(tp == "true")
            timepoints_islinear.append(casted_tps)             
        return dict(zip(names, timepoints_islinear))
    
    def get_dx_lin_tp_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and linear timed variables for all derivative 
        variables.

        Returns:
            Dict with variable name as key and list of linear time variables 
            as value. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_dx_lin_tp_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../isLinearTimedVariables]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"derivative\"][../../../@name=\""+str(key)+"\"]")
                vals.append(tp)
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"derivative\"] \
                [../isLinearTimedVariables][../@alias=\"noAlias\"]")
            vals = []
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"derivative\"][../../../@name=\""+str(key)+"\"][../../../@alias=\"noAlias\"]")
                vals.append(tp)            
                 
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        names = []
        timepoints_islinear = []
        
        for index, key in enumerate(keys):
            names.append(str(key))
            # get list of timepoints for each valueref
            tps = vals[index]
            casted_tps = []
            for tp in tps:
                casted_tps.append(tp == "true")
            timepoints_islinear.append(casted_tps)             
        return dict(zip(names, timepoints_islinear))
    
    def get_x_lin_tp_values(self, include_alias=True, ignore_cache=False):
        """ 
        Extract variable name and linear timed variables for all 
        differentiated variables.

        Returns:
            Dict with variable name as key and list of linear time variables 
            as value. 
        
        """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_x_lin_tp_values', include_alias)

        if include_alias:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../isLinearTimedVariables]")
            vals = []        
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"state\"][../../../@name=\""+key+"\"]")
                vals.append(tp)
        else:
            keys = self._xpatheval("//ScalarVariable/@name[../VariableCategory=\"state\"] \
                [../isLinearTimedVariables][../@alias=\"noAlias\"]")
            vals = []        
            for key in keys:
                tp = self._xpatheval("//ScalarVariable/isLinearTimedVariables/TimePoint/@isLinear\
                    [../../../VariableCategory=\"state\"][../../../@name=\""+key+"\"][../../../@alias=\"noAlias\"]")
                vals.append(tp)            
            
        if len(keys)!=len(vals):
            raise Exception("Number of vals does not equal number of keys. \
                Number of vals are: "+str(len(vals))+" and number of keys are: "+str(len(keys)))
        names = []
        timepoints_islinear = []
        
        for index, key in enumerate(keys):
            names.append(str(key))
            # get list of timepoints for each valueref
            tps = vals[index]
            casted_tps = []
            for tp in tps:
                casted_tps.append(tp == "true")
            timepoints_islinear.append(casted_tps)             
        return dict(zip(names, timepoints_islinear))
    
    def get_starttime(self, ignore_cache=False):
        """ Extract the interval start time. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_starttime', None)

        time = self._xpatheval("//opt:IntervalStartTime/opt:Value/text()")
        if len(time) > 0:
            return float(time[0])
        return None

    def get_starttime_free(self, ignore_cache=False):
        """ Extract the start time free attribute value. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_starttime_free', None)

        free = self._xpatheval("//opt:IntervalStartTime/opt:Free/text()")
        if len(free) > 0:
            return (free[0]=="true")
        return None
    
    def get_finaltime(self, ignore_cache=False):
        """ Extract the interval final time. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_finaltime', None)

        time = self._xpatheval("//opt:IntervalFinalTime/opt:Value/text()")
        if len(time) > 0:
            return float(time[0])
        return None

    def get_finaltime_free(self, ignore_cache=False):
        """ Extract the final time free attribute value. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_finaltime_free', None)

        free = self._xpatheval("//opt:IntervalFinalTime/opt:Free/text()")
        if len(free) > 0:
            return (free[0]=="true")
        return None

    def get_timepoints(self, ignore_cache=False):
        """ Extract all time points. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_timepoints', None)

        vals = self._xpatheval("//opt:TimePoints/opt:Value/text()")
        timepoints = []
        for tp in vals:
            timepoints.append(float(tp))
        return timepoints
        
    def get_external_libraries(self, ignore_cache=False):
        """ Extract all external library entries and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_libraries', None)
        return self._xpatheval("//VendorAnnotations/*/Annotation/@value [../@name=\"Library\"]")
        
    def get_external_includes(self, ignore_cache=False):
        """Extract all external file includes and return as list."""
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_includes', None)
        return self._xpatheval("//VendorAnnotations/*/Annotation/@value [../@name=\"Include\"]")
        
    def get_external_lib_dirs(self, ignore_cache=False):
        """ Extract all external library directories and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_lib_dirs', None)
        return self._xpatheval("//VendorAnnotations/*/Annotation/@value [../@name=\"LibraryDirectory\"]")
        
    def get_external_incl_dirs(self, ignore_cache=False):
        """ Extract all external include directories and return as list. """
        if not ignore_cache:
            return self.function_cache.get(self, 'get_external_incl_dirs', None)
        return self._xpatheval("//VendorAnnotations/*/Annotation/@value [../@name=\"IncludeDirectory\"]")
        
    def is_static(self, ignore_cache=False):
        """ Return True if Optimica static attribute is set and equal to true, otherwise False."""
        if not ignore_cache:
            return self.function_cache.get(self, 'is_static', None)
        static = self._xpatheval("opt:Optimization/@static")
        if len(static) > 0:
            return static[0]=='true'
        return False
        
            
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
