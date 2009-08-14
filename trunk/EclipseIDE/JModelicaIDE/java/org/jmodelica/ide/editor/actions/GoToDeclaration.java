package org.jmodelica.ide.editor.actions;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.ITextSelection;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;


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

    // not initialized, or not able to create AST.
    // TODO: if possible: if AST not yet created, wait for it to complete
    if (fRoot == null) 
         return;
    
    ITextSelection sel = editor.getSelection();
    
    try {
        Maybe<?> node = fRoot.getNodeAt(editor.getDocument(), sel.getOffset());
        if (node.isNull()) {
            System.out.println("got nothing");
            return;
        }
        System.out.println(node);
        //Access acc = (Access)node.value();
        
//        InstNode decl = Completions.lookup(acc, acc.enclosingClassDecl());
//        
//        if (decl != null)
//            editor.selectNode(decl);
                
    } catch (Exception e) {
        e.printStackTrace();
    }
    
}

public void updateAST(ASTNode<?> root) {
    this.fRoot = root;
}
}
