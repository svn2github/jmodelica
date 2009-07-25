package org.jmodelica.ide.editor.actions;

import java.util.HashSet;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.jastadd.plugin.compiler.ast.IJastAddNode;
import org.jmodelica.ide.editor.Editor;
import org.jmodelica.ide.helpers.EclipseCruftinessWorkaroundClass;
import org.jmodelica.ide.helpers.Maybe;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.StoredDefinition;


@SuppressWarnings("unchecked")
public class FollowReference extends Action {

Editor editor;
ASTNode fRoot;

public FollowReference(Editor editor) {
    this.editor = editor;
    this.fRoot = null;
    super.setActionDefinitionId("JModelicaIDE.FollowReferenceCommand");
}

public void run() {
    
    if (fRoot == null)  // not initialized, or not able to create AST
         return;
    
    IDocument d = editor.getDocument();
    ITextSelection sel = editor.getSelection();
    
    try {
        
        int line = sel.getStartLine() + 1; //getNodeAt() is one-based
        int col = sel.getOffset() - d.getLineOffset(line - 1);
 
        Maybe<ASTNode<ASTNode>> node = fRoot.getNodeAt(line, col);
        if (node.isNull()) {
            System.out.println("NOTHING");
            return;
        }
        
        HashSet<IJastAddNode> possibleNames = 
            node.value().getReference();

        if (possibleNames.size() != 1)
            return;
        
        ASTNode referencedNode = (ASTNode)possibleNames.iterator().next(); 
      
        //TODO: replace with call to definition in jastadd
        ASTNode fileNode = referencedNode;
        while (fileNode.getParent() != null && !(fileNode instanceof StoredDefinition))
            fileNode = fileNode.getParent();
        
        String filename = ((StoredDefinition)fileNode).getFileName();
        Maybe<Editor> mEditor = EclipseCruftinessWorkaroundClass
            .getModelicaEditorForFile(filename); 
        
        if (mEditor.hasValue()) {
            mEditor.value()
                   .getSourceOutlinePage()
                   .highlightNodeInEditor(referencedNode);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    
}

public void updateAST(ASTNode root) {
    this.fRoot = root;
}
}
