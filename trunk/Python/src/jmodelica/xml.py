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

def parseXML(filename, filepath='.', schemaname='', schemapath='.'):
    """ Parses and validates (optional) an XML file and returns an
        object representing the parsed XML.
    
        @param filename: 
            Name of XML file to parse.
        @param filepath: 
            Path (absolute or relative) to the XML file. Default is current folder.
        @param schemaname: 
            Name of XML Schema file (if any).
        @param schemapath: 
            Path (absolute or relative) to the XML Schema file (if any). 
            Default is current folder.
        
        @raise XMLException: 
            If the XML file can not be read or is not well-formed. If a schema is 
            present and if the schema file can not be read, is not well-formed 
            or if the validation fails. 
        
        @return: 
            XMLdoc, object representing the parsed XML file.
    """
    
    fpath = os.path.join(filepath,filename)
    schpath = os.path.join(schemapath,schemaname)
    
    try:
        xmldoc = etree.ElementTree(file=fpath)
    except etree.XMLSyntaxError, detail:
        raise XMLException("The XML file: %s is not well-formed. %s") %(filename,detail)
    except IOError, detail:
        raise XMLException("I/O error reading the XML file: %s %s") %(filename,detail)
    
    if schemaname:
        try:
            schemadoc = etree.ElementTree(file=schpath)
        except etree.XMLSyntaxError, detail:
            raise XMLException("The XMLSchema: %s is not well-formed. %s") %(schemaname,detail)
        except IOError, detail:
            raise XMLException("I/O error reading the XMLSchema file: %s %s") %(schemaname,detail)
         
            
        schema = etree.XMLSchema(schemadoc)
        
        result = schema.validate(xmldoc)
        
        if not result:
            raise XMLException("The XML file: %s is not valid according to the XMLSchema: %s.") %(filename,schemaname)
        
    return XMLdoc(doc)


class XMLdoc:
    """ Class representing a parsed XML file.
    """
    
    def __init__(self,doc):
        self._doc = doc
        self._xpatheval = etree.XPathEvaluator(doc)
        
    def _getRealStartAttributes(self):
        """ Help function which extracts the ValueReference and Start attribute of all Real
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """
        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Real\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Start/text()")
        
        return dict(zip(keys,vals))

    def _getIntStartAttributes(self):
        """ Help function which extracts the ValueReference and Start attribute of all Integer
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Integer\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/IntegerAttributes/Start/text()")
        
        return dict(zip(keys,vals))
    
    def _getStringStartAttributes(self):
        """ Help function which extracts the ValueReference and Start attribute of all String
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"String\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/StringAttributes/Start/text()")
        
        return dict(zip(keys,vals))

    def _getBooleanStartAttributes(self):
        """ Help function which extracts the ValueReference and Start attribute of all Boolean
            variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """

        keys=self._xpatheval("//ScalarVariable/ValueReference/text()[../../DataType=\"Boolean\"]")
        vals=self._xpatheval("//ScalarVariable/Attributes/BooleanAttributes/Start/text()")
        
        return dict(zip(keys,vals))

           
    def getStartAttributes(self):
        """ Extracts ValueReference and Start attribute of all variables in the XML document.
            
            @return: Dict with ValueReference as key and Start attribute as value. 
        """
        result=self._getRealStartAttributes()
        result.update(self._getIntStartAttributes())
        result.update(self._getStringStartAttributes())
        result.update(self._getBooleanStartAttributes())
        
        return result
    
        
class XMLException(Exception):
    pass