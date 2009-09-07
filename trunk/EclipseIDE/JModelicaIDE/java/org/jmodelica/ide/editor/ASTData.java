package org.jmodelica.ide.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.ui.IFileEditorInput;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.modelica.compiler.ASTNode;

public class ASTData {

public ASTNode<?> root;
public IProject project;
public String key;
public ASTRegistry registry;
public Editor editor;

public ASTData(IFileEditorInput input, Editor editor) {

    this.editor = editor;
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

}