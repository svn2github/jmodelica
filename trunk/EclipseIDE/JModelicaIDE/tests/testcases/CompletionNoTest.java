package testcases;

import mock.MockFile;
import mock.MockProject;

import org.eclipse.core.resources.IProject;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.CompilationRoot;
import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.namecomplete.Lookup;
import org.jmodelica.ide.namecomplete.Recompiler;
import org.jmodelica.modelica.compiler.InstAccess;
import org.jmodelica.modelica.compiler.InstClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class CompletionNoTest {

public StoredDefinition make(String[] otherFiles, String file) {

    IProject proj = 
        new MockProject();
    ASTRegistry reg =
        new ASTRegistry();
    
    CompilationRoot cr = new CompilationRoot(proj);
    cr.parseDocs(otherFiles, new MockFile(proj));
    SourceRoot root = cr.root();

    reg.updateProjectAST(root, proj);
    
    Recompiler recompiler = new Recompiler();
    StoredDefinition def =
        recompiler.recompilePartial(
            new OffsetDocument(file), 
            Maybe.<SourceRoot>Just((SourceRoot)reg.lookupAST(null, proj)), 
            new MockFile(proj));
        
    def.root().printDebugInfo();
    
    return def;
}

public static void main(String[] args) {
    
    String[] otherFiles = 
        {
            "model otherFile \n " +
            "   Real otherReal;\n " +
            "end otherFile;"
            ,
            
            "model anotherFile\n" +
            "   Real anotherReal;\n" +
            "end anotherFile;"
        };

    String file = 
        "model test\n " +
        "   class m\n" +
        "       Real real;\n" +
        "   end m;\n" +
        "   m mm;\n" +
        "   Real real; \n " +
        "   otherFile.^\n" +
        "end test;";
    
    StoredDefinition def = 
        new CompletionNoTest().make(otherFiles, file);
    SourceRoot root = 
        (SourceRoot) def.root();
    InstClassDecl enc =
        new Lookup(root)
        .instClassDeclFromQualifiedName("test");
    
    enc.addDynamicComponentName(Util.createDotAccess("real").newInstAccess());
    InstAccess a = enc.getDynamicComponentName(enc.getNumDynamicComponentName()-1);   
    
    enc.addDynamicClassName(Util.createDotAccess("m").newInstAccess());
    InstAccess b = enc.getDynamicClassName(enc.getNumDynamicClassName()-1);   
    
    System.out.println(a.myInstComponentDecl());
    System.out.println(b.myInstComponentDecl());
    
}

}
