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
        
        return dict(zip(keys,vals))
    
    def get_p_opt_variable_refs(self):
        """ Extracts ValueReference for all free independent parameters.
        
        """
        refs = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        return refs
    
    def get_w_initial_guess_values(self):
        """ Extracts ValueReference and InitialGuess values for all algebraic variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"algebraic\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Attributes/RealAttributes/Category=\"algebraic\"]")
            
        return dict(zip(keys,vals))
    
    def get_u_initial_guess_values(self):
        """ Extracts ValueReference and InitialGuess values for all input variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Causality=\"input\"]")
            
        return dict(zip(keys,vals))
    
    def get_dx_initial_guess_values(self):
        """ Extracts ValueReference and InitialGuess values for all derivative variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Attributes/RealAttributes/Category=\"derivative\"]")
        
        return dict(zip(keys, vals))
    
    def get_x_initial_guess_values(self):
        """ Extracts ValueReference and InitialGuess values for all differentiated variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Attributes/RealAttributes/Category=\"state\"]")
        
        return dict(zip(keys, vals))
    
    def get_p_opt_initial_guess_values(self):
        """ Extracts ValueReference and InitialGuess values for all free independent parameters.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                                [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                                [../../../../Attributes/RealAttributes/Free=\"true\"]")
        
        return dict(zip(keys, vals))

    def get_w_lb_values(self):
        """ Extracts ValueReference and lower bound values for all algebraic variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"algebraic\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Attributes/RealAttributes/Category=\"algebraic\"]")
            
        return dict(zip(keys,vals))
    
    def get_u_lb_values(self):
        """ Extracts ValueReference and lower bound values for all input variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Causality=\"input\"]")
            
        return dict(zip(keys,vals))
    
    def get_dx_lb_values(self):
        """ Extracts ValueReference and lower bound values for all derivative variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Attributes/RealAttributes/Category=\"derivative\"]")
        
        return dict(zip(keys, vals))
    
    def get_x_lb_values(self):
        """ Extracts ValueReference and lower bound values for all differentiated variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Attributes/RealAttributes/Category=\"state\"]")
        
        return dict(zip(keys, vals))
    
    def get_p_opt_lb_values(self):
        """ Extracts ValueReference and lower bound values for all free independent parameters.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                               [../../../../Attributes/RealAttributes/Free=\"true\"]")
        
        return dict(zip(keys, vals))

    def get_w_ub_values(self):
        """ Extracts ValueReference and upper bound values for all algebraic variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"algebraic\"] ")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Attributes/RealAttributes/Category=\"algebraic\"]")
            
        return dict(zip(keys,vals))

    def get_u_ub_values(self):
        """ Extracts ValueReference and upper bound values for all input variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Causality=\"input\"]")
            
        return dict(zip(keys,vals))
    
    def get_dx_ub_values(self):
        """ Extracts ValueReference and upper bound values for all derivative variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Attributes/RealAttributes/Category=\"derivative\"]")
        
        return dict(zip(keys, vals))
    
    def get_x_ub_values(self):
        """ Extracts ValueReference and upper bound values for all differentiated variables.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Attributes/RealAttributes/Category=\"state\"]")
        
        return dict(zip(keys, vals))
    
    def get_p_opt_ub_values(self):
        """ Extracts ValueReference and upper bound values for all free independent parameters.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Attributes/RealAttributes/Category=\"independentParameter\"] \
                               [../../../../Attributes/RealAttributes/Free=\"true\"]")
                
        return dict(zip(keys, vals))
   
            
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
        
class XMLProblVariablesDoc(XMLdoc):
    """ Class representing a parsed XML file containing Optimica problem specification meta data.
    """
    
    def get_starttime(self):
        """ Extracts the interval start time.
        
        """
        time = self._xpatheval("//IntervalStartTime/Value/text()")
        if len(time) > 0:
            return time[0]
        else:
            return None

    def get_starttime_free(self):
        """ Extracts the start time free attribute value.
        
        """
        free = self._xpatheval("//IntervalStartTime/Free/text()")
        return bool(free.count('true'))
    
    def get_finaltime(self):
        """ Extracts the interval final time.
        
        """
        time = self._xpatheval("//IntervalFinalTime/Value/text()")
        if len(time) > 0:
            return time[0]
        else:
            return None

    def get_finaltime_free(self):
        """ Extracts the final time free attribute value.
        
        """
        free = self._xpatheval("//IntervalFinalTime/Free/text()")
        return bool(free.count('true'))

    def get_timepoints(self):
        """ Extracts all time points.
        
        """
        return self._xpatheval("//TimePoints/Value/text()")
        
     
class XMLException(Exception):
    pass