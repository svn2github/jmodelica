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
    
    def get_start_attributes(self):
        """ Extracts ValueReference and Start attribute for all variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()")
        vals = self._xpatheval("//ScalarVariable/Attributes/*/Start/text()")
        
        return dict(keys,vals)
    
    def get_opt_variable_refs(self):
        refs = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Free=\"true\"]")
        return refs
    
    
class XMLValuesDoc(XMLdoc):
    """ Class representing a parsed XML file containing values for all independent parameters.
    """
                
    def get_iparam_values(self):
        """ Extracts ValueReference and value for all independent parameters in the XML document.
            
            @return: Dict with ValueReference as key and parameter value as value. 
        """

        keys = self._xpatheval("//ValueReference/text()")
        vals = self._xpatheval("//Value/text()")

        return dict(zip(keys,vals))
        
class XMLProblVariablesDoc(self):
    """ Class representing a parsed XML file containing Optimica problem specification meta data.
    """
    
    def get_starttime(self):
        return self._xpatheval("//IntervalStartTime/Value/text()")

    def get_starttime_free(self):
        free = self._xpatheval("//IntervalStartTime/Free/text()")
        if free.count('true') > 0:
            return 1;
        else:
            return 0;

    def get_finaltime(self):
        return self._xpatheval("//IntervalFinalTime/Value/text()")

    def get_finaltime_free(self):
        free = self._xpatheval("//IntervalFinalTime/Free/text()")
        if free.count('true') > 0:
            return 1;
        else:
            return 0;

    def get_timepoints(self):
        return self._xpatheval("//TimePoints/Value/text()")
    
     
class XMLException(Exception):
    pass