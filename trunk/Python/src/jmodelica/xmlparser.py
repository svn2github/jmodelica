# -*- coding: utf-8 -*-
"""Module containing XML parser and validator providing an XML object which can be used to 
    extract information from the parsed XML file using XPath queries.
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

def _parse_XML(filename, schemaname=''):
    """ Parses and validates (optional) an XML file and returns an
        object representing the parsed XML.
    
        @param filename: 
            Name of XML file to parse including absolute or relative path.
        @param schemaname: 
            Name of XML Schema file including absolute or relative path (if any).
        
        @raise XMLException: 
            If the XML file can not be read or is not well-formed. If a schema is 
            present and if the schema file can not be read, is not well-formed 
            or if the validation fails. 
        
        @return: 
            Reference to the ElementTree object containing the parsed XML.
    """
    
    #fpath = os.path.join(filepath,filename)
    #schpath = os.path.join(schemapath,schemaname)
    
    try:
        xmldoc = etree.ElementTree(file=filename)
    except etree.XMLSyntaxError, detail:
        raise XMLException("The XML file: %s is not well-formed. %s" %(filename, detail))
    except IOError, detail:
        raise XMLException("I/O error reading the XML file: %s. %s" %(filename, detail))
    
    if schemaname:
        try:
            schemadoc = etree.ElementTree(file=schemaname)
        except etree.XMLSyntaxError, detail:
            raise XMLException("The XMLSchema: %s is not well-formed. %s" %(schemaname, detail))
        except IOError, detail:
            raise XMLException("I/O error reading the XMLSchema file: %s. %s" %(schemaname, detail))
         
            
        schema = etree.XMLSchema(schemadoc)
        
        result = schema.validate(xmldoc)
        
        if not result:
            raise XMLException("The XML file: %s is not valid according to the XMLSchema: %s." %(filename, schemaname))
        
    return xmldoc


class XMLdoc:
    """ Base class representing a parsed XML file.
    """
    
    def __init__(self, filename, schemaname=''):
        _doc = _parse_XML(filename, schemaname)
        self._xpatheval = etree.XPathEvaluator(_doc)

class XMLVariablesDoc(XMLdoc):
    """ Class representing a parsed XML file containing model variable meta data.
    """
       
    def _get_real_start_attributes(self):
        """ Help function which extracts the ValueReference and Start attribute for all Real
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """
        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Real\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Start/text()")
        
        return dict(zip(keys,vals))

    def _get_int_start_attributes(self):
        """ Help function which extracts the ValueReference and Start attribute for all Integer
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Integer\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/IntegerAttributes/Start/text()")
        
        return dict(zip(keys,vals))
    
    def _get_string_start_attributes(self):
        """ Help function which extracts the ValueReference and Start attribute for all String
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"String\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/StringAttributes/Start/text()")
        
        return dict(zip(keys,vals))

    def _get_boolean_start_attributes(self):
        """ Help function which extracts the ValueReference and Start attribute for all Boolean
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Boolean\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/BooleanAttributes/Start/text()")
        
        return dict(zip(keys,vals))

           
    def get_start_attributes(self):
        """ Extracts ValueReference and Start attribute for all variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """
        result=self._get_real_start_attributes()
        result.update(self._get_int_start_attributes())
        result.update(self._get_string_start_attributes())
        result.update(self._get_boolean_start_attributes())
        
        return result

class XMLValuesDoc(XMLdoc):
    """ Class representing a parsed XML file containing values for all independent parameters.
    """
        
    def _get_boolean_values(self):
        """ Help function which extracts the ValueReference and value for all Boolean
            independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        keys = self._xpatheval("//BooleanParameter/ValueReference/text()")
        vals = self._xpatheval("//BooleanParameter/Value/text()")

        return dict(zip(keys,vals))

    def _get_string_values(self):
        """ Help function which extracts the ValueReference and value for all String
            independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        keys = self._xpatheval("//StringParameter/ValueReference/text()")
        vals = self._xpatheval("//StringParameter/Value/text()")

        return dict(zip(keys,vals))

    def _get_integer_values(self):
        """ Help function which extracts the ValueReference and value for all Integer
            independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        keys = self._xpatheval("//IntegerParameter/ValueReference/text()")
        vals = self._xpatheval("//IntegerParameter/Value/text()")

        return dict(zip(keys,vals))

    def _get_real_values(self):
        """ Help function which extracts the ValueReference and value for all Real
            independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        keys = self._xpatheval("//RealParameter/ValueReference/text()")
        vals = self._xpatheval("//RealParameter/Value/text()")

        return dict(zip(keys,vals))
        
    def get_iparam_values(self):
        """ Extracts ValueReference and value for all independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        result = self._get_boolean_values()
        result.update(self._get_string_values())
        result.update(self._get_integer_values())
        result.update(self._get_real_values())

        return result
        
       
class XMLException(Exception):
    pass