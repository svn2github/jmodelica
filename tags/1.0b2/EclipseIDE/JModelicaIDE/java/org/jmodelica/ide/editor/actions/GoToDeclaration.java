package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.EclipseCruftinessWorkaroundClass;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.ide.namecomplete.Lookup;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.InstNode;


public class GoToDeclaration extends Action {

Editor editor;
ASTNode<?> fRoot;

public GoToDeclaration(Editor editor) {
    super();
    super.setActionDefinitionId("JModelicaIDE.GoToDeclarationCommand");
    super.setId(IDEConstants.ACTION_FOLLOW_REFERENCE_ID);
    this.editor = editor;
    this.fRoot = null;
}

public void run() {
    
    // not initialised, or not able to create AST.
    // TODO: if possible: if AST not yet created, wait for it to complete
    // TODO: apply bridge parsing to try get AST if failed 
    if (fRoot == null) 
        return;
    
    Maybe<InstNode> iNode = new Lookup(fRoot).declFromAccessAt(
            editor.getDocument(),
            editor.getSelection().getOffset());
    
    if (iNode.isNothing()) 
        return;
 
    String pathToDecl = iNode.value().retrieveFileName(); 
    
    Editor editor = 
        EclipseCruftinessWorkaroundClass.getModelicaEditorForFile(
        EclipseCruftinessWorkaroundClass.getFileForPath(pathToDecl)).value();
    
    editor.selectNode(iNode.value());
    
}

public void updateAST(ASTNode<?> root) {
    this.fRoot = root;
}
}
