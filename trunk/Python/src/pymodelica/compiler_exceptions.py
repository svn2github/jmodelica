#!/usr/bin/env python
# -*- coding: utf-8 -*-

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

class JError(Exception):
    """ 
    Base class for exceptions specific to this module.
    """
    
    def __init__(self, message):
        """ 
        Create new error with a specific message. 
        
        Parameters::
        
            message --
                The error message.
        """
        self.message = message
        
    def __str__(self):
        """ 
        Print error message when class instance is printed.
         
        Override the general-purpose special method such that a string 
        representation of an instance of this class will be the error message.
        
        Returns::
        
            The error message.
        """
        return self.message
        
class IllegalCompilerArgumentError(JError):
    """
    Class for errors raised if the Compiler recives illegal arguments.
    """

class ModelicaClassNotFoundError(JError):
    """ 
    Class for errors raised if the Modelica model class to be compiled can not 
    be found.
    """
    pass

class OptimicaClassNotFoundError(JError):
    """ 
    Class for a errors raised if the Optimica model class to be compiled can
    not be found.
    """ 
    pass

class IllegalLogStringError(JError):
    """ 
    Class for a errors raised if the log string is invalid
    not be found.
    """ 
    pass

class CompilerError(JError):
    """ 
    Class representing a compiler error. Raised if there were one or more
    errors found during compilation of the model. If there are several errors
    in one model, they are collected and presented in one CompilerError.
    """

    def __init__(self, errors, warnings):
        """ 
        Create CompilerError with a list of error and warning messages. 
        """
        self.warnings = warnings
        self.errors = errors
    
    def get_compliance_errors(self):
        """
        Convenience method that only return compliance errors.
        
        Returns::
        
            Compliance errors.
        """
        errors = []
        for error in self.errors:
            if error.kind == 'compliance':
                errors.append(error)
        return errors
    
    def get_noncompliance_errors(self):
        """
        Convenience method that only return noncompliance errors.
        
        Returns::
        
            Noncompliance errors.
        """
        errors = []
        for error in self.errors:
            if error.kind != 'compliance':
                errors.append(error)
        return errors
    
    def __str__(self):
        """ 
        Print error and warning messages.
         
        Override the general-purpose special method such that a string 
        representation of an instance of this class will a string
        representation of the error messages.
        """
    
        problems = '\n' + str(len(self.errors)) + ' error(s) and ' + \
            str(len(self.warnings)) + ' warning(s) found:\n\n' 
        for problem in self.warnings + self.errors:
            problems += str(problem) + '\n'
        return problems

class CcodeCompilationError(JError):
    """ 
    Class for errors thrown when compiling a binary file from c code.
    """
    pass

class XPathExpressionError(JError):
    """ 
    Class representing errors in XPath expressions. 
    """
    pass

class ParserConfigurationError(JError):
    """ 
    Class for errors thrown when configuring XML parser. 
    """
    pass

class SAXError(JError):
    """ 
    Class representing a SAX error. 
    """
    pass

class UnknownOptionError(JError):
    """ 
    Class for error thrown when trying to access unknown compiler option. 
    """
    pass

class CompilationProblem():
    """
    Baseclass for representing a compiler problem.
    """
    def __init__(self, type, kind, file, line, column, message):
        """
        Constructor, takes the infromation about the compiler problem
        
        Parameters::
            type --
                The type of the problem, for example error.
            
            kind --
                What kind of problem, for example semantic.
            
            file --
                In what file did the problem occur.
            
            line --
                At what line did the problem occur.
            
            column --
                At what column did the problem occur
            
            message --
                The problem message that explain the problem in detail
        """
        self.type = type
        self.kind = kind
        self.file = file
        self.line = line
        self.column = column
        self.message = message
    
    def __str__(self):
        """
        Prints a nice textural representation of the problem
        """
        if self.kind.lower() == 'other':
            kind = 'At'
        else:
            kind = self.kind.title() + ' error at'
        return "%s: in file '%s':\n%s line %s, column %s:\n  %s\n" % ( \
            self.type.title(), self.file, kind, self.line, \
                self.column, self.message)
    
    def __repr__(self):
        """
        Prints a nice textural representation of the problem
        """
        return self.__str__()

class CompilationError(CompilationProblem):
    """
    Class for representing an error that occurs during compilation.
    See CompilationProblem for more documentation.
    """
    def __init__(self, kind, file, line, column, message):
        CompilationProblem.__init__(self, 'error', kind, \
            file, line, column, message)
    

class CompilationWarning(CompilationProblem):
    """
    Class for representing an warning that occurs during compilation.
    See CompilationProblem for more documentation.
    """
    def __init__(self, kind, file, line, column, message):
        CompilationProblem.__init__(self, 'warning', kind, file, \
            line, column, message)
        
