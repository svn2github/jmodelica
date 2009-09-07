package org.jmodelica.ide.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.text.Position;
import org.eclipse.ui.IFileEditorInput;
import org.jastadd.plugin.compiler.ast.IFoldingNode;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;
import org.jmodelica.modelica.compiler.BaseClassDecl;

public class ASTData {

private ASTNode<?> root;
private IProject project;
private String key;
private ASTRegistry registry;

public ASTData(IFileEditorInput input, Editor editor) {

    registry = org.jastadd.plugin.Activator.getASTRegistry();
    
    if (input == null || input.getFile() == null)
        return;
    
    IFile file = input.getFile();
    
    if (file != null) {
        key = Util.isInLibrary(file)
            ? Util.getLibraryPath(file)
            : file.getRawLocation().toOSString();
        project = file.getProject();
        root = (ASTNode<?>) registry.lookupAST(key, project);
        registry.addListener(editor, project, key);
    }   
}

public void childASTChanged(IProject pChanged, String keyChanged) {
    if (project == pChanged && keyChanged.equals(key))  
        root = (ASTNode<?>) registry.lookupAST(key, pChanged);
}   

public void projectASTChanged(IProject pChanged) {
    if (project == pChanged)  
        root = (ASTNode<?>) registry.lookupAST(key, project);
}

public boolean rootHasErrors() {
    return root == null || root.isError();
}

public boolean compiledLocal() {
    return root == null;
}

public void destruct(Editor editor) {
    registry.removeListener(editor);
}

public ASTNode<?> root() {
    return root;
}

public void setRoot(ASTNode<?> newRoot) {
    if (newRoot != null)
        root = newRoot;
}

public BaseClassDecl classContaining(ITextSelection selection) {
    if (root == null)
        return null;
    return root.containingClass(selection.getOffset(), selection.getLength());
}

public Iterable<Position> foldingPositions(IDocument document) {
    IFoldingNode node = root;
    return node.foldingPositions(document);
}

}