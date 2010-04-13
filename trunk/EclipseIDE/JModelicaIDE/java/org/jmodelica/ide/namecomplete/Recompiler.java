package org.jmodelica.ide.namecomplete;


import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.Document;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.modelica.compiler.List;
import org.jmodelica.modelica.compiler.Proxy;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;

public class Recompiler {

public final static ModelicaCompiler compiler =
    new ModelicaCompiler();

/**
 * Recompile active file and add new AST to project AST
 */
public StoredDefinition recompilePartial(
    OffsetDocument d, 
    Maybe<SourceRoot> mProjectRoot,
    IFile file) 
{
    /* remove the current (partial) line when compiling to make error
       recovery easier */
    String fileContents = 
        new DocUtil(
            new Document(d.get()))
        .replaceLineAt(d.offset, "")
        .get();

    /* re-parse and add new AST to project AST */
    StoredDefinition def
        = compiler.recompile(fileContents, file);

    System.out.println("--------------");
    System.out.println(mProjectRoot);
    System.out.println(mProjectRoot.getClass());
    System.out.println("--------------");
    
    if (mProjectRoot.hasValue()) {
        new Proxy(
            mProjectRoot.value(), 
            new List<StoredDefinition>(def));
    }

    return def;
}

}
