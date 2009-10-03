package org.jmodelica.ide.error;

import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.SourceRoot;

public class Test {

    public static void main(String[] args) {
    
        ModelicaCompiler mc = new ModelicaCompiler();
        
        SourceRoot root = mc.compileFileAt("test.mo");        
        
        for (ASTNode<?> node : root.getProgram())
            node.printASTqq("");
    }
    
}
