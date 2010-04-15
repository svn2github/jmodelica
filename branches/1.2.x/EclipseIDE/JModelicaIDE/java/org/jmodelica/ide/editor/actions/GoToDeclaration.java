package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.OffsetDocument;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.EclipseSucks;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.Lookup;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstNode;


public class GoToDeclaration extends Action {

protected final Editor editor;

protected ASTNode<?> fRoot;

public GoToDeclaration(Editor editor) {
    
    super();
    super.setActionDefinitionId("JModelicaIDE.GoToDeclarationCommand");
    super.setId(IDEConstants.ACTION_FOLLOW_REFERENCE_ID);
    this.editor = editor;
    this.fRoot = null;
}

public void run() {
    
    // not initialised, or not able to create AST.

    if (fRoot == null) 
        return;
    
    Maybe<InstNode> iNode = new Lookup(fRoot).declarationFromAccessAt(
            new OffsetDocument(
                editor.document(),
                editor.selection().getOffset()));

    if (iNode.isNothing()) 
        return;
 
    String pathToDecl = iNode.value().retrieveFileName(); 
    
    try {
        
        Editor ed = 
            EclipseSucks.getModelicaEditorForFile(
                EclipseSucks
                    .getFileForPath(pathToDecl)
                    .value())
            .value();
        ed.selectNode(iNode.value());

    } catch (Exception e) { 
        e.printStackTrace(); 
    }
    
}

public void updateAST(ASTNode<?> root) {
    this.fRoot = root;
}

}
