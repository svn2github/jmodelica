package org.jmodelica.ide.namecomplete;

import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;
import org.jmodelica.ide.ModelicaCompiler;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.indent.DocUtil;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;

public class Recompiler {

public final static ModelicaCompiler compiler = new ModelicaCompiler(
        Maybe.Just(new ModelicaParser.CollectingReport()));

/**
 * Recompile active file and add new AST to project AST
 */
public StoredDefinition recompilePartial(
        IDocument d, 
        SourceRoot projectRoot, 
        int caretOffset) 
{
    
    /* remove the current (partial) line when compiling, to make error
       recovery easier */
    String fileContents; {
        Document tmp = new Document(d.get());
        DocUtil.replaceLineAt(tmp, caretOffset, "");
        fileContents = tmp.get();
    }
    
    /* recompile and add new AST to project AST */
    StoredDefinition def; {
        def = compiler.recompile(fileContents);
        projectRoot.getProgram().dynamicAddStoredDefinition(def);
    }
    
    return def;
}

}
