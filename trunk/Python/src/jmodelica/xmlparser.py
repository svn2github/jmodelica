# -*- coding: utf-8 -*-
"""
Module containing XML parser and validator providing an XML object which can be 
used to extract information from the parsed XML file using XPath queries.

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
            If the XML file can not be read or is not well-formed. If a schema is 
            present and if the schema file can not be read, is not well-formed or 
            if the validation fails. 
        
    Returns:
    
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
    
    """ Base class representing a parsed XML file."""
    
    def __init__(self, filename, schemaname=''):
        """ 
        Create an XML document object representation and an XPath evaluator.
        
        Parse an XML document and create an XML document object representation. 
        Validate against XML schema before parsing if the parameter schemaname 
        is set. Instantiates an XPath evaluator object for the parsed XML which 
        can be used to evaluate XPath expressions on the XML.
         
        """
        _doc = _parse_XML(filename, schemaname)
        self._xpatheval = etree.XPathEvaluator(_doc)

class XMLVariablesDoc(XMLdoc):
    
    """ Class representing a parsed XML file containing model variable meta data. """

    def get_variable_names(self):
        """
        Extract the names of the variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()")       
        return dict(zip(keys,vals))

    def get_derivative_names(self):
        """
        Extract the names of the derivatives in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text() [../../VariableCategory=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()[../../VariableCategory=\"derivative\"]")

        return dict(zip(keys,vals))

    def get_differentiated_variable_names(self):
        """
        Extract the names of the differentiated variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text() [../../VariableCategory=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()[../../VariableCategory=\"state\"]")
        return dict(zip(keys,vals))

    def get_input_names(self):
        """
        Extract the names of the inputs in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text() [../../VariableCategory=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()[../../VariableCategory=\"input\"]")       
        return dict(zip(keys,vals))

    def get_algebraic_variable_names(self):
        """
        Extract the names of the algebraic variables in a model.

        Returns:
            Dict with ValueReference as key and name as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text() [../../VariableCategory=\"algebraic\"]")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()[../../VariableCategory=\"algebraic\"]")       
        return dict(zip(keys,vals))

    def get_p_opt_names(self):
        """ 
        Extract the names for all optimized independent parameters.
        
        Returns:
            Dict with ValueReference as key and name as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/ScalarVariableName/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")       
        return dict(zip(keys,vals))

    def get_variable_descriptions(self):
        """
        Extract the descriptions of the variables in a model.

        Returns:
            Dict with ValueReference as key and description as value.
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()")
        vals = self._xpatheval("//ScalarVariable/Description/text() [../../Description]")
        return dict(zip(keys,vals))
    
    def get_start_attributes(self):
        """ 
        Extract ValueReference and Start attribute for all variables in the XML document.
            
        Returns:
            Dict with ValueReference as key and Start attribute as value.
             
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()")
        vals = self._xpatheval("//ScalarVariable/Attributes/*/Start/text()")       
        return dict(zip(keys,vals))
    
    def get_p_opt_variable_refs(self):
        """ 
        Extract ValueReference for all optimized independent parameters.
        
        Returns:
            List of ValueReferences for all optimized independent parameters.
            
        """
        refs = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        return refs
    
    def get_w_initial_guess_values(self):
        """ 
        Extract ValueReference and InitialGuess values for all algebraic 
        variables.
        
        Returns:
            Dict with ValueReference as key and InitialGuess as value.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"algebraic\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../VariableCategory=\"algebraic\"]")
        return dict(zip(keys,vals))
    
    def get_u_initial_guess_values(self):
        """ 
        Extract ValueReference and InitialGuess values for all input variables.
        
        Returns:
            Dict with ValueReference as key and InitialGuess as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../Causality=\"input\"]")
        return dict(zip(keys,vals))
    
    def get_dx_initial_guess_values(self):
        """ 
        Extract ValueReference and InitialGuess values for all derivative 
        variables.
        
        Returns:
            Dict with ValueReference as key and InitialGuess as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../VariableCategory=\"derivative\"]")
        return dict(zip(keys, vals))
    
    def get_x_initial_guess_values(self):
        """ 
        Extract ValueReference and InitialGuess values for all differentiated 
        variables.
        
        Returns:
            Dict with ValueReference as key and InitialGuess as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../VariableCategory=\"state\"]")
        return dict(zip(keys, vals))
    
    def get_p_opt_initial_guess_values(self):
        """ 
        Extract ValueReference and InitialGuess values for all optimized 
        independent parameters.
        
        Returns:
            Dict with ValueReference as key and InitialGuess as value.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                                [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/InitialGuess/text()[../../../../VariableCategory=\"independentParameter\"] \
                                [../../../../Attributes/RealAttributes/Free=\"true\"]")
        return dict(zip(keys, vals))

    def get_w_lb_values(self):
        """ 
        Extract ValueReference and lower bound values for all algebraic 
        variables.
        
        Returns:
            Dict with ValueReference as key and lower bound as value.
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"algebraic\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../VariableCategory=\"algebraic\"]")    
        return dict(zip(keys,vals))
    
    def get_u_lb_values(self):
        """ 
        Extract ValueReference and lower bound values for all input 
        variables.
        
        Returns:
            Dict with ValueReference as key and lower bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../Causality=\"input\"]")
            
        return dict(zip(keys,vals))
    
    def get_dx_lb_values(self):
        """ 
        Extract ValueReference and lower bound values for all derivative 
        variables.
        
        Returns:
            Dict with ValueReference as key and lower bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../VariableCategory=\"derivative\"]")
        
        return dict(zip(keys, vals))
    
    def get_x_lb_values(self):
        """ 
        Extract ValueReference and lower bound values for all differentiated 
        variables.
        
        Returns:
            Dict with ValueReference as key and lower bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../VariableCategory=\"state\"]")
        return dict(zip(keys, vals))
    
    def get_p_opt_lb_values(self):
        """ 
        Extract ValueReference and lower bound values for all optimized 
        independent parameters.
        
        Returns:
            Dict with ValueReference as key and lower bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Min/text()[../../../../VariableCategory=\"independentParameter\"] \
                               [../../../../Attributes/RealAttributes/Free=\"true\"]")
        return dict(zip(keys, vals))

    def get_w_ub_values(self):
        """ 
        Extract ValueReference and upper bound values for all algebraic variables.
        
        Returns:
            Dict with ValueReference as key and upper bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"algebraic\"] ")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../VariableCategory=\"algebraic\"]")
            
        return dict(zip(keys,vals))

    def get_u_ub_values(self):
        """ 
        Extract ValueReference and upper bound values for all input variables.
        
        Returns:
            Dict with ValueReference as key and upper bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../Causality=\"input\"]")    
        return dict(zip(keys,vals))
    
    def get_dx_ub_values(self):
        """ 
        Extract ValueReference and upper bound values for all derivative 
        variables.
        
        Returns:
            Dict with ValueReference as key and upper bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../VariableCategory=\"derivative\"]")
        return dict(zip(keys, vals))
    
    def get_x_ub_values(self):
        """ 
        Extract ValueReference and upper bound values for all differentiated 
        variables.
        
        Returns:
            Dict with ValueReference as key and upper bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../VariableCategory=\"state\"]")
        
        return dict(zip(keys, vals))
    
    def get_p_opt_ub_values(self):
        """ 
        Extract ValueReference and upper bound values for all optimized independent 
        parameters.
        
        Returns:
            Dict with ValueReference as key and upper bound as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/Attributes/RealAttributes/Max/text()[../../../../VariableCategory=\"independentParameter\"] \
                               [../../../../Attributes/RealAttributes/Free=\"true\"]")        
        return dict(zip(keys, vals))

    def get_w_lin_values(self):
        """ 
        Extract ValueReference and boolean value describing if variable appears 
        linearly in all equations and constraints for all algebraic variables.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.
            
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"algebraic\"] ")
        vals = self._xpatheval("//ScalarVariable/IsLinear/text()[../../VariableCategory=\"algebraic\"]")            
        return dict(zip(keys,vals))

    def get_u_lin_values(self):
        """ 
        Extract ValueReference and boolean value describing if variable appears 
        linearly in all equations and constraints for all input variables.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.

        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = self._xpatheval("//ScalarVariable/IsLinear/text()[../../Causality=\"input\"]")            
        return dict(zip(keys,vals))
    
    def get_dx_lin_values(self):
        """ 
        Extract ValueReference and boolean value describing if variable appears 
        linearly in all equations and constraints for all derivative variables.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.

        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"derivative\"]")
        vals = self._xpatheval("//ScalarVariable/IsLinear/text()[../../VariableCategory=\"derivative\"]")        
        return dict(zip(keys, vals))
    
    def get_x_lin_values(self):
        """ 
        Extract ValueReference and boolean value describing if variable appears 
        linearly in all equations and constraints for all differentiated variables.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.

        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"state\"]")
        vals = self._xpatheval("//ScalarVariable/IsLinear/text()[../../VariableCategory=\"state\"]")        
        return dict(zip(keys, vals))
    
    def get_p_opt_lin_values(self):
        """ 
        Extract ValueReference and boolean value describing if variable appears 
        linearly in all equations and constraints for all optimized independent 
        parameters.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.

        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")
        vals = self._xpatheval("//ScalarVariable/IsLinear/text()[../../VariableCategory=\"independentParameter\"] \
                               [../../Attributes/RealAttributes/Free=\"true\"]")                
        return dict(zip(keys, vals))

    def get_w_lin_tp_values(self):
        """ 
        Extract ValueReference and linear timed variables for all algebraic 
        variables.
        
        Returns:
            Dict with ValueReference as key and boolean isLinear as value.

        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"algebraic\"] ")
        vals = []
        for key in keys:
            tp = self._xpatheval("//ScalarVariable/IsLinearTimedVariables/TimePoint/@isLinear[../../../VariableCategory=\"algebraic\"] \
                [../../../ValueReference="+key+"]")
            vals.append(tp)        
        return dict(zip(keys,vals))

    def get_u_lin_tp_values(self):
        """ 
        Extract ValueReference and linear timed variables for all input 
        variables.
        
        Returns:
            Dict with ValueReference as key and list of linear time variables 
            as value. 
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../Causality=\"input\"]")
        vals = []
        for key in keys:
            tp = self._xpatheval("//ScalarVariable/IsLinearTimedVariables/TimePoint/@isLinear[../../../Causality=\"input\"] \
                [../../../ValueReference="+key+"]")
            vals.append(tp)
        return dict(zip(keys,vals))
    
    def get_dx_lin_tp_values(self):
        """ 
        Extract ValueReference and linear timed variables for all derivative 
        variables.

        Returns:
            Dict with ValueReference as key and list of linear time variables 
            as value. 
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"derivative\"]")
        vals = []
        for key in keys:
            tp = self._xpatheval("//ScalarVariable/IsLinearTimedVariables/TimePoint/@isLinear[../../../VariableCategory=\"derivative\"] \
                [../../../ValueReference="+key+"]")
            vals.append(tp)        
        return dict(zip(keys, vals))
    
    def get_x_lin_tp_values(self):
        """ 
        Extract ValueReference and linear timed variables for all differentiated 
        variables.

        Returns:
            Dict with ValueReference as key and list of linear time variables 
            as value. 
        
        """
        keys = self._xpatheval("//ScalarVariable/ValueReference/text()[../../VariableCategory=\"state\"]")
        vals = []        
        for key in keys:
            tp = self._xpatheval("//ScalarVariable/IsLinearTimedVariables/TimePoint/@isLinear[../../../VariableCategory=\"state\"] \
                [../../../ValueReference="+key+"]")
            vals.append(tp)
        return dict(zip(keys, vals))
            
class XMLValuesDoc(XMLdoc):
    
    """ Class representing a parsed XML file containing values for all independent parameters. """
                
    def get_iparam_values(self):
        """ 
        Extract ValueReference and value for all independent parameters in the 
        XML document.
        
        Returns:   
            Dict with ValueReference as key and parameter as value.
            
        """
        keys = self._xpatheval("//ValueReference/text()")
        vals = self._xpatheval("//Value/text()")
        return dict(zip(keys,vals))
        
class XMLProblVariablesDoc(XMLdoc):
    
    """ Class representing a parsed XML file containing Optimica problem specification meta data. """
    
    def get_starttime(self):
        """ Extract the interval start time. """
        time = self._xpatheval("//IntervalStartTime/Value/text()")
        if len(time) > 0:
            return time[0]
        else:
            return None

    def get_starttime_free(self):
        """ Extract the start time free attribute value. """
        free = self._xpatheval("//IntervalStartTime/Free/text()")
        return bool(free.count('true'))
    
    def get_finaltime(self):
        """ Extract the interval final time. """
        time = self._xpatheval("//IntervalFinalTime/Value/text()")
        if len(time) > 0:
            return time[0]
        else:
            return None

    def get_finaltime_free(self):
        """ Extract the final time free attribute value. """
        free = self._xpatheval("//IntervalFinalTime/Free/text()")
        return bool(free.count('true'))

    def get_timepoints(self):
        """ Extract all time points. """
        return self._xpatheval("//TimePoints/Value/text()")       
     
class XMLException(Exception):
    
    """ Class for all XML related errors that can occur in this module. """
    
    pass
