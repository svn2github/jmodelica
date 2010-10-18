#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2010 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Import library for path manipulations
import os.path

# Import numerical libraries
import numpy as N
import ctypes as ct
import matplotlib.pyplot as plt
# Import JPype
import jpype

# Import the JModelica.org Python packages
import jmodelica
import jmodelica.jmi as jmi
from jmodelica.compiler import ModelicaCompiler

# Create a reference to the java package 'org'
org = jpype.JPackage('org')

def run_demo(with_plots=True):
    """
    This example demonstrates how the Python interface to the three different 
    ASTs in the compiler can be used. The JPype package is used to create Java 
    objects in a Java Virtual Machine which is seamlessly integrated with the 
    Python shell. The Java objects can be accessed interactively and methods of 
    the object can be invoked.

    For more information about the Java classes and their methods used in this 
    example, please consult the API documentation for the Modelica compiler, 
    <a href=http://www.jmodelica.org/page/22>. Notice however that the 
    documentation for the compiler front-ends is still very rudimentary. Also, 
    the interfaces to the source and instance AST will be made more user 
    friendly in upcoming versions.

    Three different usages of ASTs are shown:

    1. Count the number of classes in the Modelica standard library. In this 
       example, a Python function is defined to traverse the source AST which 
       results from parsing of the Modelica standard library.

    2. Instantiate the CauerLowPassAnalog model. The instance AST for this model 
       is dumped and it is demonstrated how the merged modification environments 
       can be accessed.

    3. Flatten the CauerLowPassAnalog model instance and print some statistics 
       of the flattened Model.
    """

    curr_dir = os.path.dirname(os.path.abspath(__file__));

    # Create a compiler
    mc = ModelicaCompiler()

    # Don't parse the file if it har already been parsed.
    try:
        source_root.getProgramRoot()
    except:
        # Parse the file CauerLowPassAnalog.mo and get the root node
        # of the source AST
        source_root = mc.parse_model(curr_dir+"/files/CauerLowPassAnalog.mo")
        
    # Don't load the standard library if it is already loaded
    try:
        modelica.getName().getID()
    except NameError, e:
        # Load the Modelica standard library and get the class
        # declaration AST node corresponding to the Modelica
        # package.
        modelica = source_root.getProgram().getLibNode(1). \
                   getStoredDefinition().getElement(0)
            
    def count_classes(class_decl,depth):
        """ 
        Count the number of classes hierarchically contained in a class 
        declaration.
        """
        
        # Get a list of local classes using the method ClassDecl.classes()
        # which returns a Java ArrayList object containing ClassDecl objects.
        local_classes = class_decl.classes()
        
        # Get the number of local classes.
        num_classes = local_classes.size()
        
        # Loop over all local classes
        for i in range(local_classes.size()):
            # Call count_classes recursively for all local classes
            num_classes = num_classes + \
                          count_classes(local_classes.get(i),depth + 1)

        # If the class declaration corresponds to a package, print
        # the number of hierarchically contained classes
        if class_decl.getRestriction().getNodeName() == 'MPackage' \
               and depth <= 1:
            print("The package %s has %d hierachically contained classes" \
                  %(class_decl.qualifiedName(),num_classes))
            
        # Return the number of hierachically contained classes
        return num_classes

    # Call count_classes for 'Modelica'
    num_classes = count_classes(modelica,0)
    
    print("")
                
    # Don't instantiate if instance has been computed already
    try:
        filter_instance.components()
    except:
        # Retrieve the node in the instance tree corresponding to the class
        # Modelica.Electrical.Analog.Examples.CauerLowPassAnalog
        filter_instance = mc.instantiate_model(source_root,"CauerLowPassAnalog")

    def dump_inst_ast(inst_node, indent):
        """
        Pretty print an instance node, including its merged enviroment.
        """
    
        # Get the merged environment of an instance node
        env = inst_node.getMergedEnvironment()
    
        # Create a string containing the type and name of the instance node
        str = indent + inst_node.prettyPrint("")
        str = str + " {"
        
        # Loop over all elements in the merged modification environment
        for i in range(env.size()):
            str = str + env.get(i).toString()
            if i<env.size()-1:
                str = str + ", "
            str = str + "}"
            
        # Print
        print(str)
    
        # Get all components and dump them recursively
        components = inst_node.instComponentDeclList
        for i in range(components.getNumChild()):
            # Assume that primitive variables are leafs in the instance AST
            if (inst_node.getClass() is \
                org.jmodelica.modelica.compiler.InstPrimitive) is False:
                dump_inst_ast(components.getChild(i),indent + "  ")

        # Get all extends clauses and dump them recursively    
        extends= inst_node.instExtendsList
        for i in range(extends.getNumChild()):
            # Assume that primitive variables are leafs in the instance AST
            if (inst_node.getClass() is \
                org.jmodelica.modelica.compiler.InstPrimitive) is False:
                dump_inst_ast(extends.getChild(i),indent + "  ")

    # Dump the filter instance
    dump_inst_ast(filter_instance,"")

    print("")

    # Flatten filter model

    # Don't flatten model if it already exists
    try:
        filter_flat_model.name()
    except:
        # Flatten the model instance filter_instance
        filter_flat_model = mc.flatten_model(filter_instance)
    
    print(filter_flat_model.prettyPrint(""))
    
    print("*** Model statistics for CauerLowPassAnalog *** ")
    print("Number of differentiated variables: %d" % filter_flat_model.numDifferentiatedRealVariables())
    print("Number of algebraic variables:      %d" % filter_flat_model.numAlgebraicRealVariables())
    print("Number of equations:                %d" % filter_flat_model.numEquations())
    print("Number of initial equation:         %d" % filter_flat_model.numInitialEquations())
