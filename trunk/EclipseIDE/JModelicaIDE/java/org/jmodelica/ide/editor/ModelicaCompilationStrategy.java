package org.jmodelica.ide.editor;

import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.jastadd.plugin.ReconcilingStrategy;

class ModelicaCompilationStrategy {

public ReconcilingStrategy normalStrategy;
public LocalReconcilingStrategy localStrategy;
public boolean compiledLocal;

public ModelicaCompilationStrategy(Editor editor) {
    normalStrategy = new ReconcilingStrategy();
    localStrategy = new LocalReconcilingStrategy(editor);
    compiledLocal = false;
}

public IReconcilingStrategy getStrategy() {
    return compiledLocal ? localStrategy : normalStrategy;
}

public void update(EditorFile fPath, ASTData ast) {
    normalStrategy.setFile(fPath.file()); 
    compiledLocal = ast.compiledLocal();
}

}
