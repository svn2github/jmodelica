package org.jmodelica.ide.editor;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.plugin.ReconcilingStrategy;
import org.jastadd.plugin.registry.ASTRegistry;
import org.jmodelica.modelica.compiler.ASTNode;

public class GlobalCompilationResult extends CompilationResult {

private final ASTRegistry registry;
private final String key;
private final IProject project;
private final EditorFile editorFile;

public GlobalCompilationResult(EditorFile ef, Editor editor) {

    editorFile = ef;
    
    registry = org.jastadd.plugin.Activator.getASTRegistry();
    key = ef.toRegistryKey();
    project = ef.iFile().getProject();

    if (project != null)
        root = (ASTNode<?>) registry.lookupAST(key, project);
    
    registry.addListener(editor, project, key);
}

public void update(IProject projChanged, String keyChanged) {
    if (project == projChanged && keyChanged.equals(key)) {  
        root = (ASTNode<?>) registry.lookupAST(key, projChanged);
    }
}   

public void update(IProject projChanged) {
    this.update(projChanged, key);
}

public void destruct(Editor editor) {
    registry.removeListener(editor);
}

public void recompileLocal(IDocument doc, IFile file) { } 

public IReconcilingStrategy compilationStrategy() {
    ReconcilingStrategy strategy = new ReconcilingStrategy();
    strategy.setFile(editorFile.iFile());
    return strategy;
}

}