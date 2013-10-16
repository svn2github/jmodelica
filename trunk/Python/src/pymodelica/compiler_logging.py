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
"""
Internal module, handles log output from the compiler
"""
import xml.sax
from threading import Thread
from compiler_exceptions import *
import sys
import traceback

class LogErrorParser(xml.sax.ContentHandler):
    """
    Implementation of the xml.sax.ContentHandler class. This class looks for
    warnings and errors in the provided xml stream.
    
    parameters::
        errors --
            A list that all errors can be written to
        warnings --
            A list that all warnings can be written to
    """
    def __init__(self, problems):
        xml.sax.ContentHandler.__init__(self)
        self.problems = problems
        self.node = None
        self.state = None
        self.attribute = None
    def startElement(self, name, attrs):
        if self.state == 'error' or self.state == 'warning' or \
                self.state == 'exception':
            if name == 'value':
                self.attribute = attrs['name'].encode('utf-8')
                self.node[self.attribute] = '';
        else:
            if name == "Error":
                self.state = 'error'
                self.node = {'type':'error'}
            elif name == "Warning":
                self.state = 'warning'
                self.node = {'type':'warning'}
            elif name == "Exception":
                self.state = 'exception'
                self.node = {'type':'exception'}

    def endElement(self, name):
        if self.state == 'error' and name == "Error" or \
                self.state == 'warning' and name == "Warning" or \
                self.state == 'exception' and name == "Exception":
            problem = self._construct_problem_node(self.node)
            self.problems.append(problem)
            self.state = None
            self.node = None
        elif name == 'value':
            self.attribute = None
    
    def characters(self, content):
        if self.node is not None and self.attribute is not None:
            self.node[self.attribute] += content;
    
    def _construct_problem_node(self, node):
        if node['type'] == 'exception':
            return CompilationException(node['kind'], node['message'], node['stacktrace'])
        elif node['type'] == 'error':
            return CompilationError(node['kind'], node['file'], node['line'], \
                node['column'], node['message'])
        elif node['type'] == 'warning':
            return CompilationWarning(node['kind'], node['file'], node['line'], \
                node['column'], node['message'])

class LogHandlerThread(Thread):
    """
    A thread for reading the log stream
    Contains two attributes, errors and warnings that will be propagated with
    errors and warnings during the compilation.
    """
    def __init__(self, stream):
        """
        Creates the new LogHandlerThread
        
        Parameters::
            stream --
                An output stream that the logger can parse.
        
        """
        Thread.__init__(self)
        self.stream = stream
        self.problems = [];

    def run(self):
        """
        The thread.run() method that delegates to a SAX parser. 
        """
        try:
            xml.sax.parse(self.stream, LogErrorParser(self.problems))
        except:
            raise

class CompilerLogHandler:
    def __init__(self):
        """
        Create a compiler log handler. It will parse the xml stream that is
        outputted by the JModelica.org compiler.
        
        Normal call flow is as follows:
        stream = <<<an output stream from the compiler>>>
        log = CompilerLogHandler()
        log.start(stream)
        try:
            compiler.do_something()
        finally:
            stream.close()
            log.end()
        """
        self.loggerThread = None
    
    def _create_log_handler_thread(self, stream):
        """
        An internal util method for creating the log handeling thread.
        
        Returns::
        
            A LogHandlerThread object.
        """
        return LogHandlerThread(stream);
    
    def start(self, stream):
        """
        Starts a new logging session. A new thread is started internaly that
        will monitor the log stream that was given as argument. It will
        continously echo output and parse for warnings and errors.
        
        Parameters::
            stream --
                An output stream that the logger can parse.
        """
        self.loggerThread = self._create_log_handler_thread(stream)
        self.loggerThread.start()

    def end(self):
        """ 
        End the current logging session. It is important that the log stream
        has been closed before calling this method. Otherwise this method will
        block indefinitely. The reason for this is that this method will wait
        for the the log parser thread to finnish. It only does so when the log
        stream is closed.
        
        This method will proccess the errors and warnings that are given in the
        log stream. An appropriate Python error is raised if an exception was
        given by the compiler process.
        """
        if (self.loggerThread is None):
            print "Invalid call order!"
        self.loggerThread.join()
        problems = self.loggerThread.problems
        self.loggerThread = None
        
        exceptions = []
        errors = []
        warnings = []
        
        for problem in problems:
            if isinstance(problem, CompilationException):
                exceptions.append(problem)
            elif isinstance(problem, CompilationError):
                errors.append(problem)
            elif isinstance(problem, CompilationWarning):
                warnings.append(problem)
        if not exceptions:
            if not errors:
                return warnings
            else:
                raise CompilerError(errors, warnings)
        
        exception = exceptions[0]
        
        if exception.kind == 'org.jmodelica.util.exceptions.ModelicaClassNotFoundException':
            raise ModelicaClassNotFoundError(exception.message)
        
        if exception.kind == 'java.io.FileNotFoundException':
            raise IOError(exception.message)
        
        if exception.kind == 'org.jmodelica.util.logging.IllegalLogStringException':
            raise IllegalLogStringError(exception.message)
        
        if exception.kind == 'org.jmodelica.util.OptionRegistry$UnknownOptionException':
            raise UnknownOptionError(exception.message)
        
        if exception.kind == 'org.jmodelica.modelica.compiler.CcodeCompilationException' or \
            exception.kind == 'org.jmodelica.optimica.compiler.CcodeCompilationException':
            raise CcodeCompilationError(exception.message)
        
        raise JError("%s\n%s" % (exception.message, exception.stacktrace))

class CompilationException():
    """
    Temporary container class for exceptions that are thrown by the compiler
    and cought by the SAX parser. This class should only be used internaly in
    this module.
    """
    def __init__(self, kind, message, stacktrace):
        self.kind = kind
        self.message = message
        self.stacktrace = stacktrace
