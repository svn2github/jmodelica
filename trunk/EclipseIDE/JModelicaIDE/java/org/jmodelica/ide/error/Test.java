package org.jmodelica.ide.error;

import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;

public class Test {

    public static void main(String[] args) throws Exception {
    
        ModelicaCompiler mc = new ModelicaCompiler(
                Maybe.Just(new ModelicaParser.CollectingReport()));
        
        StoredDefinition root = mc.compileFileAt("test.mo");        
        
        root.printDebugInfo();

    }
    
}
